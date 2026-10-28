variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used in tags and resource names"
  type        = string
  default     = "voting-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub user or organisation that owns the repo"
  type        = string
  default     = "Abrahamnosa23"
}

variable "github_repo" {
  description = "Repository allowed to assume the roles"
  type        = string
  default     = "example-voting-app"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster the deploy role may describe"
  type        = string
  default     = "capstone-eks"
}

variable "ecr_repositories" {
  description = "ECR repositories to create"
  type        = list(string)
  default     = ["voting-app/vote", "voting-app/result", "voting-app/worker"]
}

variable "github_sub_prefix" {
  description = "OIDC subject prefix. This repo uses GitHub's immutable format (owner and repo IDs)."
  type        = string
  default     = "repo:Abrahamnosa23@177690640/example-voting-app@1434175792"
}
