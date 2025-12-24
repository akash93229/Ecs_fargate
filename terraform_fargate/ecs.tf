# =========================
# ECS CLUSTER (Metrics Enabled)
# =========================
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
resource "aws_ecs_cluster_capacity_providers" "strapi_spot" {
  cluster_name = aws_ecs_cluster.strapi_cluster.name
 
  capacity_providers = ["FARGATE_SPOT"]
 
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}
# =========================
# ECS TASK DEFINITION (CloudWatch Logs Enabled)
# =========================
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "akash-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"  # 2 vCPU
  memory                   = "4096"  # 4 GB
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

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

      # 🔥 CloudWatch Logs Configuration (TASK 8 CORE)
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs/strapi"
        }
      }
    }
  ])

  tags = {
    Name = "akash-strapi-task"
  }
}

# =========================
# ECS SERVICE
# =========================
resource "aws_ecs_service" "strapi_service" {
  name            = "akash-strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_db_instance.akash_strapi_postgres,
    aws_ecs_cluster_capacity_providers.strapi_spot,
 
  ]

  tags = {
    Name = "akash-strapi-service"
  }
}
