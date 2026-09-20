# Default ElastiCache User required for RBAC User Group
resource "aws_elasticache_user" "default" {
  user_id       = "${var.app_name}-default-user"
  user_name     = "default"
  engine        = "valkey"
  passwords     = [random_password.valkey_password.result]
  access_string = "on ~* +@all"

  tags = {
    Name = "${var.app_name}-default-user"
  }
}

# Application Valkey RBAC User
resource "aws_elasticache_user" "valkey_user" {
  user_id       = "${var.app_name}-valkey-user"
  user_name     = var.valkey_username
  engine        = "valkey"
  passwords     = [random_password.valkey_password.result]
  access_string = "on ~* +@all"

  tags = {
    Name = "${var.app_name}-valkey-user"
  }
}

# ElastiCache RBAC User Group for Valkey
resource "aws_elasticache_user_group" "valkey" {
  engine        = "valkey"
  user_group_id = "${var.app_name}-valkey-ug"
  user_ids      = [aws_elasticache_user.default.user_id, aws_elasticache_user.valkey_user.user_id]

  tags = {
    Name = "${var.app_name}-valkey-ug"
  }
}

# AWS ElastiCache Valkey Cluster using AWS Community Module
module "valkey" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.3"

  cluster_id               = "${var.app_name}-valkey"
  create_cluster           = false
  create_replication_group = true
  replication_group_id     = "${var.app_name}-valkey"
  description              = "AWS ElastiCache Valkey cluster for ${var.app_name}"

  engine               = "valkey"
  engine_version       = "7.2"
  node_type            = "cache.t4g.micro"
  num_cache_clusters   = 1
  port                 = 6379
  parameter_group_name = "default.valkey7"

  vpc_id                     = local.vpc_id
  subnet_ids                 = local.private_subnet_ids
  create_subnet_group        = true
  create_security_group      = false
  security_group_ids         = [aws_security_group.valkey.id]
  user_group_ids             = [aws_elasticache_user_group.valkey.user_group_id]
  transit_encryption_enabled = true

  tags = {
    Name = "${var.app_name}-valkey"
  }
}
