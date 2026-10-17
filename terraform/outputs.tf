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

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.voting_app.name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.voting_app.endpoint
}

output "eks_node_group_name" {
  description = "Name of the managed EKS worker node group"
  value       = aws_eks_node_group.voting_app.node_group_name
}
