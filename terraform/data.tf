# ==========================================
# UNIFIED DATA SOURCING VIA SSM PARAMETER STORE
# ==========================================

# VPC ID
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.common_environment}/vpc/id"
}

# Public Subnet IDs List
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.common_environment}/subnets/public_ids"
}

# Private Subnet IDs List
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.common_environment}/subnets/private_ids"
}

# Route 53 Zone ID
data "aws_ssm_parameter" "route53_zone_id" {
  name = "/${var.common_environment}/route53/zone_id"
}

# Route 53 Zone Name
data "aws_ssm_parameter" "route53_zone_name" {
  name = "/${var.common_environment}/route53/zone_name"
}

# Local helpers for unified, typed data sourcing across all files
locals {
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  public_subnet_ids  = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  route53_zone_id    = data.aws_ssm_parameter.route53_zone_id.value
  route53_zone_name  = data.aws_ssm_parameter.route53_zone_name.value
}
