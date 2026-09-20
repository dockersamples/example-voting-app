# CloudWatch Log Groups for Container Logging
resource "aws_cloudwatch_log_group" "valkey" {
  name              = "/ecs/${var.app_name}/valkey"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "vote" {
  name              = "/ecs/${var.app_name}/vote"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "result" {
  name              = "/ecs/${var.app_name}/result"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.app_name}/worker"
  retention_in_days = 7
}
