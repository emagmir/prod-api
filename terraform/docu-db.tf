resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "my-docdb-cluster"
  engine                          = "docdb"
  master_username                 = "pythonadmin"
  master_password                 = "pythonadmin"
  backup_retention_period         = 1
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  port                            = 27017
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.no-tls.name
  vpc_security_group_ids          = [aws_security_group.allow_only_ec2.id]
  availability_zones = module.vpc.azs
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster_parameter_group" "no-tls" {
  family      = "docdb5.0"
  name        = "no-tls"
  description = "bye bye tls (who needs security anyway)"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}