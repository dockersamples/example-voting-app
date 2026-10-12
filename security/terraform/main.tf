terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "assessment_demo" {
  bucket_prefix = "sysdig-iac-assessment-"

  tags = {
    Project = "SysdigAssessment"
    Purpose = "SecurityScanningDemo"
  }
}
