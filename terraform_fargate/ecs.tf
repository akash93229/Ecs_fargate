
# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "akash-strapi-cluster"

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }

  tags = {
    Name = "akash-strapi-cluster"
  }
}

# CloudWatch Log Group
# resource "aws_cloudwatch_log_group" "strapi_logs" {
#   name              = "/ecs/akash-strapi"
#   retention_in_days = 7
#
#   tags = {
#     Name = "akash-strapi-logs"
#   }
# }

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "akash-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"  # 2 vCPU
  memory                   = "4096"  # 4 GB
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  #task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.docker_image
      essential = true

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "HOST"
          value = "0.0.0.0"
        },
        {
          name  = "PORT"
          value = "1337"
        },
        {
          name  = "DATABASE_CLIENT"
          value = "postgres"
        },
        {
          name  = "DATABASE_HOST"
          value = aws_db_instance.akash_strapi_postgres.address
        },
        {
          name  = "DATABASE_PORT"
          value = tostring(aws_db_instance.akash_strapi_postgres.port)
        },
        {
          name  = "DATABASE_NAME"
          value = var.db_name
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.db_username
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DATABASE_SSL"
          value = "true"
        },
        {
          name  = "DATABASE_SSL_REJECT_UNAUTHORIZED"
          value = "false"
        },
        {
          name  = "APP_KEYS"
          value = var.app_keys
        },
        {
          name  = "API_TOKEN_SALT"
          value = var.api_token_salt
        },
        {
          name  = "ADMIN_JWT_SECRET"
          value = var.admin_jwt_secret
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        }
      ]

      # logConfiguration = {
      #   logDriver = "awslogs"
      #   options = {
      #     "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name
      #     "awslogs-region"        = var.aws_region
      #     "awslogs-stream-prefix" = "ecs"
      #   }
      # }

      # healthCheck = {
      #   command     = ["CMD-SHELL", "curl -f http://localhost:1337/_health || exit 1"]
      #   interval    = 30
      #   timeout     = 5
      #   retries     = 3
      #   startPeriod = 60
      # }
    }
  ])

  tags = {
    Name = "akash-strapi-task"
  }
}

# ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "akash-strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.strapi_tg.arn
  #   container_name   = "strapi"
  #   container_port   = 1337
  # }

  depends_on = [
    # aws_lb_listener.strapi_listener,
    aws_db_instance.akash_strapi_postgres
  ]

  tags = {
    Name = "akash-strapi-service"
  }
}

# Auto Scaling Target
# resource "aws_appautoscaling_target" "ecs_target" {
#   max_capacity       = 3
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.strapi_cluster.name}/${aws_ecs_service.strapi_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# Auto Scaling Policy - CPU Based
# resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
#   name               = "akash-strapi-cpu-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
# 
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = 70.0
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 60
#   }
# }

# Auto Scaling Policy - Memory Based
# resource "aws_appautoscaling_policy" "ecs_memory_policy" {
#   name               = "akash-strapi-memory-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
# 
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     target_value       = 80.0
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 60
#   }
# }
