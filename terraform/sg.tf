# ==========================================
# DEDICATED SECURITY GROUPS PER ECS TASK
# ==========================================

# 1. Vote Task Security Group
resource "aws_security_group" "vote_task" {
  name        = "${var.app_name}-vote-task-sg"
  description = "Allow inbound traffic from ALB to Vote service and outbound access"
  vpc_id      = local.vpc_id

  ingress {
    description     = "HTTP inbound traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    description = "Allow all outbound traffic for Valkey and AWS API access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-vote-task-sg"
  }
}

# 2. Result Task Security Group
resource "aws_security_group" "result_task" {
  name        = "${var.app_name}-result-task-sg"
  description = "Allow inbound traffic from ALB to Result service and outbound access"
  vpc_id      = local.vpc_id

  ingress {
    description     = "HTTP inbound traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    description = "Allow all outbound traffic for Aurora PostgreSQL and AWS API access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-result-task-sg"
  }
}

# 3. Worker Task Security Group (No Inbound Required)
resource "aws_security_group" "worker_task" {
  name        = "${var.app_name}-worker-task-sg"
  description = "Background worker service security group (No inbound access required)"
  vpc_id      = local.vpc_id

  egress {
    description = "Allow all outbound traffic for Valkey, Aurora PostgreSQL, and AWS API access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-worker-task-sg"
  }
}

# 4. ElastiCache Valkey Security Group
resource "aws_security_group" "valkey" {
  name        = "${var.app_name}-valkey-sg"
  description = "Security group for AWS ElastiCache Valkey (Allows Vote and Worker tasks)"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Valkey traffic from Vote task"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.vote_task.id]
  }

  ingress {
    description     = "Valkey traffic from Worker task"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_task.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-valkey-sg"
  }
}
