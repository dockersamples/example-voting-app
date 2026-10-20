terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "voting-app-tfstate-038884640469"
    key          = "eks/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "voting-app-capstone"
      ManagedBy = "terraform"
    }
  }
}