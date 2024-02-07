FASTAPI used for who knows what

This branch will have 2 github actions workflows:

 - > Terraform code for Infrastructure in AWS
 - > Application deployment using k8s and helm in an EKS cluster

For application we use the following connection string:
 - "mongodb://pythonadmin:pythonadmin@db.fastmongo.com:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"

In route 53 there will be a private DNS record, mapped to the VPC of the whole infrastructure.
A CNAME record will map db.fastmongo.com to the endpoint of the DocumentDB cluster for accessing the DB.

The Infrastructure will use VPC and EKS modules for easier deployment, and resources for documentDB, route53 records, security groups (documentDB security group will permit the EKS nodegroup security group for traffic)

Using Helm provider, and a few other resources that will allow the IAM to use the RBAC k8s system (iam-oidc.tf, iam-controller.tf) we will also deploy AWS loadbalancer controller which will allow for helm to deploy an Ingress controller that will be mapped to an ALB in AWS

A few annotations were made, for healthcheck path, and allowed IP in ingress security group (currently my personal IP):

    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/inbound-cidrs: 86.121.90.68/32
    alb.ingress.kubernetes.io/tags: Environment=dev,Team=test
    alb.ingress.kubernetes.io/healthcheck-path: /health

Image URI and tag will be provided in the workflow from the github secrets. If local deployment is required, i suggest making a temporary file, and using the --values file.yaml for providing these 2 variables:

image: {{ .Values.appimage}}:{{ .Values.apptag}}