variable "aws_region" {
  description = "AWS region for resources (matches aca-terraform-common)"
  type        = string
  default     = "eu-north-1"
}

variable "app_name" {
  description = "Application name identifier"
  type        = string
  default     = "aca-voting-app"
}

variable "environment" {
  description = "Environment name (e.g. production, staging, dev)"
  type        = string
  default     = "production"
}

# ==========================================
# SHARED RESOURCES CONFIGURATION
# ==========================================

variable "common_environment" {
  description = "Environment identifier of common base infrastructure (matches aca-terraform-common environment)"
  type        = string
  default     = "core"
}

variable "domain_name" {
  description = "Domain name for Route 53 zone hosted in aca-terraform-common"
  type        = string
  default     = "sergey.c-loud.am"
}

variable "vote_subdomain" {
  description = "Subdomain prefix for vote web app"
  type        = string
  default     = "vote"
}

variable "result_subdomain" {
  description = "Subdomain prefix for result web app"
  type        = string
  default     = "result"
}

# ==========================================
# APP CONTAINER CONFIGURATION
# ==========================================

variable "vote_image_tag" {
  description = "Image tag to deploy for the vote service"
  type        = string
  default     = "latest"
}

variable "result_image_tag" {
  description = "Image tag to deploy for the result service"
  type        = string
  default     = "latest"
}

variable "worker_image_tag" {
  description = "Image tag to deploy for the worker service"
  type        = string
  default     = "latest"
}

variable "container_cpu" {
  description = "CPU unit allocation for each ECS container task"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory allocation (MB) for each ECS container task"
  type        = number
  default     = 512
}

variable "vote_desired_count" {
  description = "Number of desired instances for the vote service"
  type        = number
  default     = 1
}

variable "result_desired_count" {
  description = "Number of desired instances for the result service"
  type        = number
  default     = 1
}

variable "worker_desired_count" {
  description = "Number of desired instances for the worker service"
  type        = number
  default     = 1
}

# ==========================================
# ECS AUTO SCALING CONFIGURATION
# ==========================================

variable "ecs_max_capacity" {
  description = "Maximum number of tasks to scale up to"
  type        = number
  default     = 2
}

variable "ecs_cpu_target_value" {
  description = "Target average CPU utilization percentage for scaling"
  type        = number
  default     = 70.0
}

variable "ecs_alb_request_target_value" {
  description = "Target ALB request count per target for scaling"
  type        = number
  default     = 1000.0
}

# ==========================================
# VALKEY (REDIS FORK) CONFIGURATION
# ==========================================

variable "valkey_username" {
  description = "Username for Valkey RBAC authentication"
  type        = string
  default     = "valkeyuser"
}

variable "valkey_password" {
  description = "Password for Valkey in-memory data store"
  type        = string
  default     = "valkeypassword"
  sensitive   = true
}

# ==========================================
# AURORA SERVERLESS POSTGRES CONFIGURATION
# ==========================================

variable "aurora_db_name" {
  description = "Database name for Aurora Serverless PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "aurora_master_username" {
  description = "Master username for Aurora Serverless PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "aurora_master_password" {
  description = "Master password for Aurora Serverless PostgreSQL"
  type        = string
  default     = "postgrespassword"
  sensitive   = true
}

variable "aurora_min_capacity" {
  description = "Minimum ACU for Aurora Serverless v2 (cost-optimized minimum)"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Maximum ACU for Aurora Serverless v2 (cost-optimized maximum)"
  type        = number
  default     = 1.0
}
