
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

# Identify existing public subnets for the Voting App EKS cluster.
resource "aws_ec2_tag" "eks_cluster_subnet_a" {
  resource_id = "subnet-073da4d7e92dc34ad"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

resource "aws_ec2_tag" "eks_cluster_subnet_b" {
  resource_id = "subnet-0961a5f5b1f0a3750"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

resource "aws_ec2_tag" "eks_cluster_subnet_c" {
  resource_id = "subnet-0a8d7c8667f511e5d"
  key         = "kubernetes.io/cluster/${var.project_name}-${var.environment}"
  value       = "shared"
}

# Mark the subnets as public for AWS load-balancer discovery.
resource "aws_ec2_tag" "public_subnet_elb_a" {
  resource_id = "subnet-073da4d7e92dc34ad"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_b" {
  resource_id = "subnet-0961a5f5b1f0a3750"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_c" {
  resource_id = "subnet-0a8d7c8667f511e5d"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
