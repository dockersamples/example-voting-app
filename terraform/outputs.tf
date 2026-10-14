output "aws_region" {
  description = "AWS region configured for the Voting App infrastructure"
  value       = var.aws_region
}

output "project_name" {
  description = "Name of the Voting App project"
  value       = var.project_name
}

output "artifacts_bucket_name" {
  description = "Name of the S3 artifacts bucket, once created"
  value       = aws_s3_bucket.voting_app_artifacts.bucket
}
