output "region" {
  value       = var.region
  description = "AWS EKS region"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security group ID for the AWS EKS"
}