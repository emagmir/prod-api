resource "aws_security_group" "ssh_from_home" {
  name        = "ssh_from_home"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_home" {
  security_group_id = aws_security_group.ssh_from_home.id
  cidr_ipv4         = "86.121.90.68/32"
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
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ec2_traffic" {
  security_group_id = aws_security_group.allow_only_ec2.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_docudb" {
  security_group_id = aws_security_group.allow_only_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}