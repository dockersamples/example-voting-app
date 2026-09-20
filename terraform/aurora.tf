# Aurora Serverless v2 PostgreSQL cluster using AWS Community Module
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name            = "${var.app_name}-aurora"
  engine          = "aurora-postgresql"
  engine_version  = "15.14"
  master_username = var.aurora_master_username
  master_password = random_password.postgres_password.result
  database_name   = var.aurora_db_name

  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids

  # Deletion protection explicitly disabled for easy tear down
  deletion_protection = false
  skip_final_snapshot = true

  # Minimum resources: Aurora Serverless v2 scaling configuration
  serverlessv2_scaling_configuration = {
    min_capacity = var.aurora_min_capacity # 0.5 ACU
    max_capacity = var.aurora_max_capacity # 1.0 ACU
  }

  instance_class = "db.serverless"
  instances = {
    1 = {}
  }

  manage_master_user_password = false

  security_group_rules = {
    result_ingress = {
      description              = "Allow PostgreSQL traffic from Result task"
      type                     = "ingress"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.result_task.id
    }
    worker_ingress = {
      description              = "Allow PostgreSQL traffic from Worker task"
      type                     = "ingress"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.worker_task.id
    }
  }

  create_db_subnet_group = true

  tags = {
    Name = "${var.app_name}-aurora"
  }
}
