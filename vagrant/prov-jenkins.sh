#!/bin/bash

#jenkins LTS installation below
#check periodically the official page to update it if something changes
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

#Java installation
sudo apt install fontconfig openjdk-17-jre -y

#service enable/start
sudo systemctl enable jenkins
sudo systemctl start jenkins
