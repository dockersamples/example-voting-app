# ECS Cluster using AWS Community Module
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9"

  cluster_name = "${var.app_name}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = {
    Name = "${var.app_name}-cluster"
  }
}

# ==========================================
# 1. VOTE SERVICE
# ==========================================
resource "aws_ecs_task_definition" "vote" {
  family                   = "${var.app_name}-vote"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "vote"
      image     = "${module.ecr_vote.repository_url}:${var.vote_image_tag}"
      essential = true
      environment = [
        { name = "REDIS_HOST", value = module.valkey.replication_group_primary_endpoint_address },
        { name = "REDIS_PORT", value = "6379" },
        { name = "REDIS_SSL", value = "true" },
        { name = "OPTION_A", value = "Cats" },
        { name = "OPTION_B", value = "Dogs" }
      ]
      secrets = [
        {
          name      = "REDIS_USERNAME"
          valueFrom = "${module.secrets_manager_valkey.secret_arn}:username::"
        },
        {
          name      = "REDIS_PASSWORD"
          valueFrom = "${module.secrets_manager_valkey.secret_arn}:password::"
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.vote.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "vote"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "vote" {
  name            = "vote"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.vote.arn
  desired_count   = var.vote_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.vote_task.id]
    subnets          = local.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["vote"].arn
    container_name   = "vote"
    container_port   = 80
  }

  depends_on = [module.valkey]
}

# ==========================================
# 2. RESULT SERVICE
# ==========================================
resource "aws_ecs_task_definition" "result" {
  family                   = "${var.app_name}-result"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "result"
      image     = "${module.ecr_result.repository_url}:${var.result_image_tag}"
      essential = true
      environment = [
        { name = "POSTGRES_HOST", value = module.aurora.cluster_endpoint },
        { name = "POSTGRES_PORT", value = "5432" },
        { name = "POSTGRES_DB", value = var.aurora_db_name },
        { name = "POSTGRES_SSL", value = "true" },
        { name = "PORT", value = "80" }
      ]
      secrets = [
        {
          name      = "POSTGRES_USER"
          valueFrom = "${module.secrets_manager_postgres.secret_arn}:username::"
        },
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${module.secrets_manager_postgres.secret_arn}:password::"
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.result.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "result"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "result" {
  name            = "result"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.result.arn
  desired_count   = var.result_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.result_task.id]
    subnets          = local.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["result"].arn
    container_name   = "result"
    container_port   = 80
  }

  depends_on = [module.aurora]
}

# ==========================================
# 3. WORKER SERVICE
# ==========================================
resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "${module.ecr_worker.repository_url}:${var.worker_image_tag}"
      essential = true
      environment = [
        { name = "REDIS_HOST", value = module.valkey.replication_group_primary_endpoint_address },
        { name = "REDIS_PORT", value = "6379" },
        { name = "REDIS_SSL", value = "true" },
        { name = "POSTGRES_HOST", value = module.aurora.cluster_endpoint },
        { name = "POSTGRES_PORT", value = "5432" },
        { name = "POSTGRES_DB", value = var.aurora_db_name },
        { name = "POSTGRES_SSL", value = "true" }
      ]
      secrets = [
        {
          name      = "REDIS_USERNAME"
          valueFrom = "${module.secrets_manager_valkey.secret_arn}:username::"
        },
        {
          name      = "REDIS_PASSWORD"
          valueFrom = "${module.secrets_manager_valkey.secret_arn}:password::"
        },
        {
          name      = "POSTGRES_USER"
          valueFrom = "${module.secrets_manager_postgres.secret_arn}:username::"
        },
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${module.secrets_manager_postgres.secret_arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "worker"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.worker_task.id]
    subnets          = local.private_subnet_ids
    assign_public_ip = false
  }

  depends_on = [module.valkey, module.aurora]
}
