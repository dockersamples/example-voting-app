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
resource "aws_s3_bucket_public_access_block" "assessment_demo" {
  bucket = aws_s3_bucket.assessment_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "assessment_demo" {
  bucket = aws_s3_bucket.assessment_demo.id

  versioning_configuration {
    status = "Enabled"
  }
}
