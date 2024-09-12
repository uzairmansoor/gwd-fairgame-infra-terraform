#!/bin/bash
sudo su
cd /home/ubuntu
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nodejs -y
node -v
sudo apt-get install npm -y
npm -v
sudo apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
cd /home/ubuntu
sudo apt-get install -y ruby wget
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo service codedeploy-agent status
sudo npm install -g pm2
pm2 --version