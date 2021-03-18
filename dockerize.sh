#!/bin/bash

#Running docker_wp.sh in public instance.
ssh ubuntu@$(cat ip_ec2_wp) 'mkdir ~/key'
scp -i MyNamedKeyPair.pem ~/key/ec2_mysql ubuntu@$(cat ip_ec2_wp):/home/ubuntu/key/ec2_mysql
cat docker_wp.sh | ssh ubuntu@$(cat ip_ec2_wp) 'bash -s'

#Running docker_db.sh in the private instance.
ssh ubuntu@$(cat ec2_mysql | grep PRIVATEIP | cut -f 3) 'mkdir ~/key'
cat docker_db.sh | ssh ubuntu@$(cat ec2_mysql | grep PRIVATEIP | cut -f 3) 'bash -s'

echo "
Dear User,

Please open $(cat ip_ec2_wp) in your web browser where you can configure your Wordpress.
Please use the following credentials.

Database name: wordpress
Database user: wordpress
Database password: wordpress
Database host: $(cat ec2_mysql | grep PRIVATEIP | cut -f 3):3306
"