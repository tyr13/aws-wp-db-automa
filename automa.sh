#!/bin/bash
#You need to install and configure the AWS CLI previously and set your IAM permissions to allow for Amazon EC2 access.

mkdir ~/key

#Create an IPv4 VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text | awk '{print $NF}' | head -n 1 >> ~/key/vpcId
aws ec2 create-tags --tags Key=Name,Value=NamedVPC --resources $(cat ~/key/vpcId)

#Create and tag subnet1 with CIDR 10.0.1.0/24 in VPC
aws ec2 create-subnet --vpc-id $(cat ~/key/vpcId) --cidr-block 10.0.1.0/24 --output text >> ~/key/subnet1
aws ec2 create-tags --tags Key=Name,Value=subnet1 --resources $(cat ~/key/subnet1 | grep -o 'subnet-.*[0-9]' | cut -b 1-24)

#Create and tag subnet2 with CIDR 10.0.0.0/24 in VPC
aws ec2 create-subnet --vpc-id $(cat ~/key/vpcId) --cidr-block 10.0.0.0/24 --output text >> ~/key/subnet2
aws ec2 create-tags --tags Key=Name,Value=subnet2 --resources $(cat ~/key/subnet2 | grep -o 'subnet-.*[0-9]' | cut -b 1-24)

#Create custom routing table
aws ec2 create-route-table --vpc-id $(cat ~/key/vpcId) --output text >> ~/key/customroute
aws ec2 create-tags --tags Key=Name,Value=customRoute --resources $(cat ~/key/customroute | grep -oE rtb-.* | cut -b 1-21)

#Associate all of your public subnets with the custom routing table, in this example subnet1 will be the public one
aws ec2 associate-route-table  --subnet-id $(cat ~/key/subnet1 | grep -o 'subnet-.*[0-9]' | cut -b 1-24) --route-table-id $(cat ~/key/customroute | grep -oE rtb-.* | cut -b 1-21)

#Allocate EIP
aws ec2 allocate-address --domain $(cat ~/key/vpcId) >> ~/key/eip

#Create NAT-GTW and associate with EIP and subnet1
aws ec2 create-nat-gateway --subnet-id $(cat ~/key/subnet1 | grep -o 'subnet-.*[0-9]' | cut -b 1-24) --allocation-id $(cat ~/key/eip | grep -oE eipal.* | cut -b 1-17) --output text >> ~/key/natgtw
aws ec2 create-tags --tags Key=Name,Value=myNatGtw --resources $(cat ~/key/natgtw | grep -o nat-.* | cut -b 1-21)

#Create and tag INT-GTW and attach it to VPC
aws ec2 create-internet-gateway --output text >> ~/key/igw
aws ec2 create-tags --tags Key=Name,Value=myInternetGTW --resources $(cat ~/key/igw | grep -oE igw-.* | cut -b 1-21)
aws ec2 attach-internet-gateway --vpc-id $(cat ~/key/vpcId) --internet-gateway-id $(cat ~/key/igw | grep -oE igw-.* | cut -b 1-21)

#Create a route in the custom route table that points all traffic (0.0.0.0/0) to the Internet gateway
aws ec2 create-route --route-table-id $(cat ~/key/customroute | grep -oE rtb-.* | cut -b 1-21) --destination-cidr-block 0.0.0.0/0 --gateway-id $(cat ~/key/igw | grep -oE igw-.* | cut -b 1-21)

#Main route table tagging
aws ec2 create-tags --tags Key=Name,Value=mainRoute --resources $(aws ec2 describe-route-tables | grep -B 19 $(cat ~/key/vpcId) | grep -A 2 '"Main": true' | tail -1 | tr -s " " | cut -b 19-39)

#Create a route in the main route table that points all traffic (0.0.0.0/0) to the NAT gateway
aws ec2 create-route --route-table-id $(aws ec2 describe-route-tables | grep -B 12 '"Value": "mainRoute"' | grep rtb-* | tr -s " " | cut -b 19-39) --destination-cidr-block 0.0.0.0/0 --gateway-id $(cat ~/key/natgtw | grep -o nat-.* | cut -b 1-21) 

#Create security groups
aws ec2 create-security-group --group-name security1 --description "HTTP 80 and SSH 22" --vpc-id $(cat ~/key/vpcId) --output text >> ~/key/security1
aws ec2 authorize-security-group-ingress --group-id $(cat ~/key/security1) --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $(cat ~/key/security1) --protocol tcp --port 22 --cidr 0.0.0.0/0


aws ec2 create-security-group --group-name security2 --description "MySQL 3306 and SSH 22" --vpc-id $(cat vpcId) --output text >> ~/key/security2
aws ec2 authorize-security-group-ingress --group-id $(cat ~/key/security2) --protocol tcp --port 3306 --source-group $(cat ~/key/security1)
aws ec2 authorize-security-group-ingress --group-id $(cat ~/key/security2) --protocol tcp --port 22 --cidr 0.0.0.0/0

#Creating key-pair
aws ec2 create-key-pair --key-name MyNamedKeyPair --query 'KeyMaterial' --output text > ~/key/MyNamedKeyPair.pem

#Launching an EC2 instance with Ubuntu 18.04 AMI ( ami-0e0102e3ff768559b ) with security1 in subnet1 (public subnet)
aws ec2 run-instances --image-id ami-0e0102e3ff768559b --count 1 --instance-type t2.micro --key-name MyNamedKeyPair --security-group-ids $(cat ~/key/security1) --subnet-id $(cat ~/key/subnet1 | grep -o 'subnet-.*[0-9]' | cut -b 1-24) --associate-public-ip-address --output text >> ~/key/ec2_wp
aws ec2 create-tags --tags Key=Name,Value=ec2_wp --resources $(cat ~/key/ec2_wp | grep -Eo i-.* | head -1 | tr -s " " | cut -b 21-39)
aws ec2 describe-instances --instance-ids $(cat ~/key/ec2_wp | grep -Eo i-.* | head -1 | tr -s " " | cut -b 21-39) | grep PublicIpAddress.* | tr -s " " | cut -d " " -f3 | tr -d '"&&,&& ' >> ~/key/ip_ec2_wp

#Launching an EC2 instance with Ubuntu 18.04 AMI ( ami-0e0102e3ff768559b ) with security2 in subnet2 (private subnet)
aws ec2 run-instances --image-id ami-0e0102e3ff768559b --count 1 --instance-type t2.micro --key-name MyNamedKeyPair --security-group-ids $(cat ~/key/security2) --subnet-id $(cat ~/key/subnet2 | grep -o 'subnet-.*[0-9]' | cut -b 1-24) --output text >> ~/key/ec2_mysql
aws ec2 create-tags --tags Key=Name,Value=ec2_mysql --resources $(cat ~/key/ec2_mysql | grep -Eo i-.* | head -1 | tr -s " " | cut -b 21-39)

#https://docs.aws.amazon.com/vpc/latest/userguide/vpc-subnets-commands-example.html