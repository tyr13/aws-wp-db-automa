#!/bin/bash

#Installing Docker
sudo apt-get update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get install -y docker-compose

cd ~/key

#Setup and run MySQL container
echo "
FROM mysql:5.7
ENV MYSQL_ROOT_PASSWORD=wordpress
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wordpress
ENV MYSQL_PASSWORD=wordpress 
VOLUME "/var/lib/mysql"
EXPOSE 3306 3306
" > Dockerfile

sudo docker build . > ~/key/build

sudo docker run -p 3306:3306 -d $(cat build | grep Successfully | cut -d " " -f 3)
