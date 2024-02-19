# Fast-API CRUD Application with MongoDB - ECS TF edition

This branch contains a CI/CD pipeline for deploying the app in an ECS cluster using terraform for infra setup

## Overview

The terraform directory contains the (you guessed it) infrastructure setup. It consists of:

- **VPC/ALB/Security groups/**: VPC has 2 subnets, 1 route table and route table associations, 3 security groups (one for ALB to allow only certain IPs, in this case my own), one for the EC2 instances, and one for the DocumentDB cluster. Access works like this ALB SG -> EC2 SG -> DOcuDB SG

- **EC2 capacity provider**: I have defined custom capacity provider, instead of serverless fargate, we will be using EC2 instances. Because we are pulling image from private dockerhub repo, the credentials are stored in an S3 bucket, and are provisioned on each EC2 instance upon first boot according to this doc:
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth-container-instances.html
One issue i found is that every EC2 instance needs a reboot after becoming available, as ECS service that listens for API requests will be in status exited. Manual systemctl stop/start does not work, but a reboot does

- **ECS cluster**: Cluster created with task definition. 

- **DocuDB/route53**: My combo of documentDB cluster with endpoint added in a private route53 zone so that the connection string can be predicted (used in EKS branch also)

## Pipeline

- **Infra workflow**: The first workflow will be that of terraform, with an S3 bucket as backend. Only changes done in the Terraform directory will be counted when this workflow is deployed

- **App workflow**: Second workflow will deploy the app. In the workflow, a new taskdef file will be created and the newer image of the app replaced then deployed. This will kill the older container and deploy a new one

Useful stuff:

https://repost.aws/knowledge-center/ecs-instance-unable-join-cluster