output "deploy_role_arn" {
  description = "Put this in the GitHub secret AWS_DEPLOY_ROLE_ARN"
  value       = aws_iam_role.deploy.arn
}

output "deploy_role_name" {
  description = "Used by the cluster stack for the EKS access entry"
  value       = aws_iam_role.deploy.name
}

output "plan_role_arn" {
  description = "Put this in the GitHub secret AWS_PLAN_ROLE_ARN"
  value       = aws_iam_role.plan.arn
}

output "ecr_registry" {
  description = "Registry hostname"
  value       = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "ecr_repository_urls" {
  value = { for k, r in aws_ecr_repository.repos : k => r.repository_url }
}
