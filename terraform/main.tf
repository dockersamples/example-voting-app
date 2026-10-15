
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "voting_app_artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-artifacts-"

  force_destroy = false

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "voting_app_artifacts" {
  bucket = aws_s3_bucket.voting_app_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}
