resource "aws_security_group" "ssh_from_home" {
  name        = "ssh_from_home"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_home" {
  security_group_id = aws_security_group.ssh_from_home.id
  cidr_ipv4         = "my ip"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ssh_from_home.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "allow_only_ec2" {
  name        = "allow_only_ec2"
  description = "Allow EC2 inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "allow_ec2"
  }
}


resource "aws_security_group_rule" "allow_ingress_from_node_group" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_only_ec2.id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "allow_ingress_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_only_ec2.id
  source_security_group_id = module.eks.cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_docudb" {
  security_group_id = aws_security_group.allow_only_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}