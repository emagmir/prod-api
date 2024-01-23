terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        aws = ">= 5.33.0"
    }

    random = {
        source = "hashicorp/random"
        version = ">= 3.6.0"
    }

    tls = {
        source = "hashicorp/tls"
        version = ">= 4.0.5"
    }

    cloudinit = {
        source = "hashicorp/cloudinit"
        version = ">= 2.3.3"
    }

    kubernetes = {
        source = "hashicorp/kubernetes"
        version = ">= 2.25.2"
    }
  }

  backend "s3" {
    bucket = "tf-prod-api-state"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
  
  required_version = ">= 1.6.0"
  
}
