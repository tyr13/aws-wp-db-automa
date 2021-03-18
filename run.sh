#!/bin/bash
#Automa runs automatic VPC and Subnet creation with two instances in a public and a private subnet.
#Sshconfig sets ssh config in our host.
#Dockerize run one WP container in the public and one MySQL container in the private subnet.

./automa.sh
./sshconfig.sh
echo "Please wait for instances to stand up..."
sleep 60
./dockerize.sh