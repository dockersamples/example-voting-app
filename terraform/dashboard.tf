# Custom AWS CloudWatch Dashboard for System Metrics & Connections
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: ALB Traffic & Response Times
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.alb.arn_suffix, { period = 60, stat = "Sum", label = "Total Requests" }],
            [".", "HTTPCode_Target_2XX_Count", ".", ".", { period = 60, stat = "Sum", label = "2XX Success" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { period = 60, stat = "Sum", label = "4XX Client Errors" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { period = 60, stat = "Sum", label = "5XX Server Errors" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🌐 Application Load Balancer Traffic & HTTP Status Codes"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.alb.arn_suffix, { period = 60, stat = "Average", label = "Avg Response Time (s)" }],
            [".", "TargetResponseTime", ".", ".", { period = 60, stat = "p95", label = "p95 Response Time (s)" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "⚡ ALB Target Response Times (Latency)"
        }
      },

      # Row 2: Database Connection Requests & Capacity (Aurora & Valkey)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", module.aurora.cluster_id, { period = 60, stat = "Average", label = "PostgreSQL Active Connections" }],
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", "${var.app_name}-valkey-001", { period = 60, stat = "Average", label = "Valkey Active Client Connections" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🔌 Database & Cache Active Connection Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ServerlessDatabaseCapacity", "DBClusterIdentifier", module.aurora.cluster_id, { period = 60, stat = "Average", label = "Aurora ACUs Capacity" }],
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", module.aurora.cluster_id, { period = 60, stat = "Average", label = "Aurora CPU %" }],
            ["AWS/ElastiCache", "EngineCPUUtilization", "CacheClusterId", "${var.app_name}-valkey-001", { period = 60, stat = "Average", label = "Valkey Engine CPU %" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "📉 Aurora Serverless v2 Capacity & DB Engine CPU"
        }
      },

      # Row 3: ECS Fargate Services CPU & Memory Utilization
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", module.ecs.cluster_name, "ServiceName", aws_ecs_service.vote.name, { period = 60, stat = "Average", label = "Vote Service CPU %" }],
            [".", "CPUUtilization", ".", ".", "ServiceName", aws_ecs_service.result.name, { period = 60, stat = "Average", label = "Result Service CPU %" }],
            [".", "CPUUtilization", ".", ".", "ServiceName", aws_ecs_service.worker.name, { period = 60, stat = "Average", label = "Worker Service CPU %" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "💻 ECS Fargate Tasks CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", module.ecs.cluster_name, "ServiceName", aws_ecs_service.vote.name, { period = 60, stat = "Average", label = "Vote Service Memory %" }],
            [".", "MemoryUtilization", ".", ".", "ServiceName", aws_ecs_service.result.name, { period = 60, stat = "Average", label = "Result Service Memory %" }],
            [".", "MemoryUtilization", ".", ".", "ServiceName", aws_ecs_service.worker.name, { period = 60, stat = "Average", label = "Worker Service Memory %" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🧠 ECS Fargate Tasks Memory Utilization"
        }
      },

      # Row 4: Valkey Cache Hit Ratio & Storage Throughput
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CacheHits", "CacheClusterId", "${var.app_name}-valkey-001", { period = 60, stat = "Sum", label = "Valkey Cache Hits" }],
            [".", "CacheMisses", ".", ".", { period = 60, stat = "Sum", label = "Valkey Cache Misses" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🚀 Valkey Cache Hits vs Misses"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ReadThroughput", "DBClusterIdentifier", module.aurora.cluster_id, { period = 60, stat = "Average", label = "Aurora Read Throughput (B/s)" }],
            [".", "WriteThroughput", ".", ".", { period = 60, stat = "Average", label = "Aurora Write Throughput (B/s)" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "💾 PostgreSQL Aurora Storage I/O Throughput"
        }
      }
    ]
  })
}
