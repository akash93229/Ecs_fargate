# ==========================
# ECS CLUSTER
# ==========================
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "akash-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "akash-strapi-cluster"
  }
}

# ==========================
# CLOUDWATCH LOG GROUP
# ==========================
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/akashstrapi"
  retention_in_days = 7

  tags = {
    Name = "akash-strapi-logs"
  }
}

# ==========================
# TASK DEFINITION
# ==========================
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "akash-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

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
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },

        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.akash_strapi_postgres.address },
        { name = "DATABASE_PORT", value = tostring(aws_db_instance.akash_strapi_postgres.port) },
        { name = "DATABASE_NAME", value = var.db_name },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "DATABASE_SSL", value = "true" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" },

        { name = "APP_KEYS", value = var.app_keys },
        { name = "API_TOKEN_SALT", value = var.api_token_salt },
        { name = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
        { name = "JWT_SECRET", value = var.jwt_secret }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:1337/_health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 120
      }
    }
  ])

  tags = {
    Name = "akash-strapi-task"
  }
}

resource "aws_ecs_service" "strapi_service" {
  name    = "akash-strapi-service"
  cluster = aws_ecs_cluster.strapi_cluster.id

  desired_count = 1
  launch_type   = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = local.subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      capacity_provider_strategy
    ]
  }

  depends_on = [
    aws_lb_listener.strapi_listener,
    aws_db_instance.akash_strapi_postgres
  ]

  tags = {
    Name = "akash-strapi-service"
  }
}
