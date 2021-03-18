# aws-wp-db-automa
This script installs a WP instances and a DB instances in a public and private subnet in AWS.

To use this script you need to install and configure the AWS CLI previously and set your IAM permissions to allow for Amazon EC2 access.**

# Automa.sh
- Create an IPv4 VPC and outputs a file vpcId with the ID.
- Create and tag two subnets, named subnet1 and subnet 2 with CIDR 10.0.1.0/24 and CIDR 10.0.0.0/24 in VPC. Outputs two files subnet1 and subnet 2 with the descriptions  of the subnets.
-
- Create and tag a custom routing table and outputs description into a file named customroute.
- Associate the public subnet with the custom routing table.

- Allocate an EIP and create an output file named eip.
- Create a NAT-GTW and associate the public subnet and the EIP with it. Output file is named natgtw.
- Create and tag an INT-GTW and attach it to the VPC. Output file is igw.

- Create a route in the custom route table that points all traffic (0.0.0.0/0) to the Internet gateway.

- Tags the main route table.

- Create a route in the main route table that points all traffic (0.0.0.0/0) to the NAT gateway.

- Create a security group named security1 with HTTP 80 and SSH 22. Output is security1.
- Create a security group named security2 with HTTP 3306 and SSH 22. Output is security2.
- You can't reach private network only from security1.

- Create an SSH key with name MyNamedKeyPair.pem

- Launch an EC2 in the public subnet with output file named ec2_wp.
- You can check the public ip of this instances in the file ip_ec2_wp.

- Launch an EC2 in the private subnet with output file named ec2_mysql.

# Sshconfig.sh
- Create an ssh config file in the host machine in order to be able to securely ssh into the private network.

# Docker_wp.sh
- Create and run a Wordpress docker container.
- If you insist you can modify the part of this file which creates the wp-config file to upload it with your credentials. Otherwise you will need to manually config your Wordpress.

# Docker_db.sh
- Create and run a MySQL docker container.

# Dockerize.sh
- Runs docker_wp.sh and docker_db.sh via SSH on the two EC2.

# Run.sh
- Simply runs above scripts in order. 
- After the scripts finished you will see the database name, user and password with the IP of the current MySQL instance. With these you can easily setup your Wordpress via browser.
-:))
