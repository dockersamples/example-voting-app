variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "voting-app"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  type    = string
  default = "capstone-eks"
}

variable "kubernetes_version" {
  description = "Check: aws eks describe-cluster-versions --region us-east-1"
  type        = string
  default     = "1.35"
}

variable "azs" {
  description = "Availability zones whose default subnets are used"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "api_public_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. GitHub runners need it reachable, so it is open by default. Access still requires IAM authentication."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND (stable) or SPOT (cheaper, can be interrupted mid-demo)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_min" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 4
}

variable "node_disk_size" {
  type    = number
  default = 30
}

variable "deploy_role_name" {
  description = "IAM role created by the bootstrap stack"
  type        = string
  default     = "voting-app-gha-deploy"
}
