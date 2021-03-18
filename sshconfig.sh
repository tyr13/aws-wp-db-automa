#!/bin/bash
#To be able to SSH into the servers we need to setup our config file in the host machine.
echo "
# Config for Bastion host
Host $(cat ~/key/ip_ec2_wp)
    User ubuntu
    IdentityFile ~/key/MyNamedKeyPair.pem

# Config for Private host (wildcard, covers hosts in 10.0.0.0/24)
Host 10.0.0.*
    User ubuntu
    IdentityFile ~/key/MyNamedKeyPair.pem
    ProxyCommand ssh ubuntu@$(cat ~/key/ip_ec2_wp) -W %h:%p" > ~/.ssh/config