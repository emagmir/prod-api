#!/bin/bash 
sudo yum install aws-cli -y
aws s3 cp s3://ecs-ec2-docker-creds/creds/docker-creds.txt /etc/ecs/ecs.config
sudo systemctl restart ecs