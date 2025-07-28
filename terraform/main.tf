provider "aws" {
  region = "us-east-2"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

#hello
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "aryak-strapi-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "607700977843.dkr.ecr.us-east-2.amazonaws.com/aryak-strapi-app:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ],
      essential = true,
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
        name  = "DATABASE_URL"
        value = "postgresql://${var.db_username}:${var.db_password}@aryak-strapi-postgres.cbymg2mgkcu2.us-east-2.rds.amazonaws.com:5432/${var.db_name}"
        },
        {
          name  = "APP_KEYS"
          value = "H5mnz8odDwNsrPrHYZMK+w==,vflz6dcxdZtLmb/qr/38bg==,2RQzSRADDruCIWu1qHtkGw==,gwSyUiod2cNkoIifB1wClw=="
        },
        {
          name  = "JWT_SECRET"
          value = "EYw8dnO6uAJgieoP0V2QCA=="
        },
        {
          name  = "API_TOKEN_SALT"
          value = "ntITJUKq7KPLSs3yMDWmWw=="
        },
        {
          name  = "ADMIN_JWT_SECRET"
          value = "EYw8dnO6uAJgieoP0V2QCA=="
        },
        {
          name  = "TRANSFER_TOKEN_SALT"
          value = "6hJTsNusRF6kArOCiUI0aA=="
        },
        {
          name  = "ENCRYPTION_KEY"
          value = "oQQVoC1EbAsvD0UUeGNHDA=="
        },
        
      ]
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.strapi_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs/strapi"
  }
}

    }
  ])
}


resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-aryak" 
  retention_in_days = 14                 
  tags = {
    "Name" = "StrapiLogs"
  }
}
