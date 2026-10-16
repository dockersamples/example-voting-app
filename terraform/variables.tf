variable "aws_region" {
  description = "AWS region for the Voting App infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the DevOps capstone project"
  type        = string
  default     = "voting-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.36"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Public IPv4 CIDRs allowed to access the Kubernetes API"
  type        = list(string)
}
