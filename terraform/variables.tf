variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "az_ids" {
  description = "Two AZ IDs. use1-az3 is excluded because EKS does not support it."
  type        = list(string)
  default     = ["eun1-az1", "eun1-az2"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "voting-app"
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "m7i-flex.large"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}
