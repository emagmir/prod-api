resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.clusterName

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}



resource "aws_ecs_service" "mongo" {
  name            = var.serviceName
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 3
  iam_role        = aws_iam_role.foo.arn
  depends_on      = [aws_iam_role_policy.foo]


  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "mongo"
    container_port   = 8080
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}