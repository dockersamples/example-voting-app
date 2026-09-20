output "shared_vpc_id" {
  description = "The ID of the shared VPC reused from aca-terraform-common"
  value       = local.vpc_id
  sensitive   = true
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by ALB"
  value       = local.public_subnet_ids
  sensitive   = true
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by ECS Tasks, Aurora, and ElastiCache"
  value       = local.private_subnet_ids
  sensitive   = true
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

output "vote_url" {
  description = "HTTP redirect URL for vote web app"
  value       = "http://${module.alb.dns_name}"
}

output "result_url" {
  description = "HTTPS URL to access result app directly on port 8443"
  value       = "https://${module.alb.dns_name}:8443"
}

output "vote_domain_url" {
  description = "Secure HTTPS domain URL for vote app"
  value       = "https://${var.vote_subdomain}.${var.domain_name}"
}

output "result_domain_url" {
  description = "Secure HTTPS domain URL for result app"
  value       = "https://${var.result_subdomain}.${var.domain_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM Certificate"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}

output "aurora_cluster_endpoint" {
  description = "Aurora Serverless v2 PostgreSQL cluster writer endpoint"
  value       = module.aurora.cluster_endpoint
}

output "elasticache_valkey_endpoint" {
  description = "Primary endpoint for AWS ElastiCache Valkey"
  value       = module.valkey.replication_group_primary_endpoint_address
}

output "secrets_manager_valkey_arn" {
  description = "Secrets Manager ARN storing Valkey credentials"
  value       = module.secrets_manager_valkey.secret_arn
}

output "secrets_manager_postgres_arn" {
  description = "Secrets Manager ARN storing PostgreSQL credentials"
  value       = module.secrets_manager_postgres.secret_arn
}

output "ecr_repository_vote_url" {
  description = "URL of the ECR repository for the vote service"
  value       = module.ecr_vote.repository_url
}

output "ecr_repository_result_url" {
  description = "URL of the ECR repository for the result service"
  value       = module.ecr_result.repository_url
}

output "ecr_repository_worker_url" {
  description = "URL of the ECR repository for the worker service"
  value       = module.ecr_worker.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_vote_name" {
  description = "Name of the vote ECS Service"
  value       = aws_ecs_service.vote.name
}

output "ecs_service_result_name" {
  description = "Name of the result ECS Service"
  value       = aws_ecs_service.result.name
}

output "ecs_service_worker_name" {
  description = "Name of the worker ECS Service"
  value       = aws_ecs_service.worker.name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch Custom Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "Direct AWS Console link to the CloudWatch Custom Dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
