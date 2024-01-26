output "cluster_name" {
  value       = module.eks.cluster_name
  description = "AWS EKS CLuster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "AWS EKS Cluster endpoint"
}

output "region" {
  value       = var.region
  description = "AWS EKS region"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security group ID for the AWS EKS"
}