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