variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "clusterName" {
  description = "Name of ECS cluster"
  type        = string
  default     = "fast-api-ecs-cluster"
}

variable "serviceName" {
  description = "Fast-api service name"
  type        = string
  default     = "fast-api-cont"
}

variable "vpc_cidr" {
  description = "vpc ip block"
  type        = string
  default     = "10.0.0.0/16"
}