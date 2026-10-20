variable "aws_region" {
  description = "AWS region for EKS deployment"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voting-app-cluster"
}

variable "eks_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "m7i-flex.large"
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.35"
}
