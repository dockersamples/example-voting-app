terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60, < 7.0" # verify the current major version and pin it via the lock file
    }
  }

  backend "s3" {} # values come from backend.hcl (partial configuration)
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = var.github_owner
      ManagedBy   = "terraform"
      CostCenter  = "training"
    }
  }
}
