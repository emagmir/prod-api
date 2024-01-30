module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "fast-api-eks-vpc"

  cidr = "172.20.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]
  public_subnets  = ["172.20.4.0/24", "172.20.5.0/24", "172.20.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  create_database_subnet_group = true

}

locals {
  private_subnet_ids = [for i, cidr in module.vpc.private_subnets : module.vpc.private_subnets[i].id]
}

resource "aws_docdb_subnet_group" "test_dubnet_group" {
  name       = "main"
  subnet_ids = local.private_subnet_ids

  tags = {
    Name = "My docdb subnet group"
  }
}