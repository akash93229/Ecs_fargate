# output "alb_dns_name" {
#   description = "DNS name of the Application Load Balancer"
#   value       = aws_lb.strapi_alb.dns_name
# }

# output "strapi_url" {
#   description = "URL to access Strapi application"
#   value       = "http://${aws_lb.strapi_alb.dns_name}"
# }

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.strapi_service.name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.akash_strapi_postgres.endpoint
  sensitive   = true
}

# output "cloudwatch_log_group" {
#   description = "CloudWatch log group for ECS tasks"
#   value       = aws_cloudwatch_log_group.strapi_logs.name
# }