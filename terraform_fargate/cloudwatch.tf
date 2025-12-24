# =========================
# CloudWatch Log Group (ECS Logs)
# =========================
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi"
  retention_in_days = 7

  tags = {
    Name = "strapi-ecs-logs"
  }
}

# =========================
# CloudWatch Dashboard (OPTIONAL)
# =========================
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "strapi-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "akash-strapi-service", "ClusterName", "akash-strapi-cluster"],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "akash-strapi-service", "ClusterName", "akash-strapi-cluster"]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Strapi ECS CPU & Memory Utilization"
        }
      }
    ]
  })
}

# =========================
# CloudWatch Alarm (OPTIONAL – High CPU)
# =========================
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "strapi-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ServiceName = "akash-strapi-service"
    ClusterName = "akash-strapi-cluster"
  }

  alarm_description = "Triggers when ECS service CPU exceeds 80%"
}
