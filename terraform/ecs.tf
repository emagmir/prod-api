resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.clusterName

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

