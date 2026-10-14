provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "voting_app_artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-artifacts-"

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
