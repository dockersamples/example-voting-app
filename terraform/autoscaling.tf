# ==========================================
# ECS SERVICE DYNAMIC AUTO SCALING (1 to 2 Tasks)
# ==========================================

# ------------------------------------------
# 1. VOTE SERVICE AUTO SCALING
# ------------------------------------------
resource "aws_appautoscaling_target" "vote" {
  max_capacity       = var.ecs_max_capacity   # 2
  min_capacity       = var.vote_desired_count # 1
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.vote.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Vote Service Target Tracking Scaling Policy: CPU Utilization
resource "aws_appautoscaling_policy" "vote_cpu" {
  name               = "${var.app_name}-vote-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.vote.resource_id
  scalable_dimension = aws_appautoscaling_target.vote.scalable_dimension
  service_namespace  = aws_appautoscaling_target.vote.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cpu_target_value # 70.0%
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Vote Service Target Tracking Scaling Policy: ALB Request Count Per Target
resource "aws_appautoscaling_policy" "vote_alb" {
  name               = "${var.app_name}-vote-alb-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.vote.resource_id
  scalable_dimension = aws_appautoscaling_target.vote.scalable_dimension
  service_namespace  = aws_appautoscaling_target.vote.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["vote"].arn_suffix}"
    }

    target_value       = var.ecs_alb_request_target_value # 1000.0 requests
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ------------------------------------------
# 2. RESULT SERVICE AUTO SCALING
# ------------------------------------------
resource "aws_appautoscaling_target" "result" {
  max_capacity       = var.ecs_max_capacity     # 2
  min_capacity       = var.result_desired_count # 1
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.result.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Result Service Target Tracking Scaling Policy: CPU Utilization
resource "aws_appautoscaling_policy" "result_cpu" {
  name               = "${var.app_name}-result-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.result.resource_id
  scalable_dimension = aws_appautoscaling_target.result.scalable_dimension
  service_namespace  = aws_appautoscaling_target.result.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cpu_target_value # 70.0%
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Result Service Target Tracking Scaling Policy: ALB Request Count Per Target
resource "aws_appautoscaling_policy" "result_alb" {
  name               = "${var.app_name}-result-alb-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.result.resource_id
  scalable_dimension = aws_appautoscaling_target.result.scalable_dimension
  service_namespace  = aws_appautoscaling_target.result.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["result"].arn_suffix}"
    }

    target_value       = var.ecs_alb_request_target_value # 1000.0 requests
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ------------------------------------------
# 3. WORKER SERVICE AUTO SCALING
# ------------------------------------------
resource "aws_appautoscaling_target" "worker" {
  max_capacity       = var.ecs_max_capacity     # 2
  min_capacity       = var.worker_desired_count # 1
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Worker Service Target Tracking Scaling Policy: CPU Utilization
resource "aws_appautoscaling_policy" "worker_cpu" {
  name               = "${var.app_name}-worker-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cpu_target_value # 70.0%
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
