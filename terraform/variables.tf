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
