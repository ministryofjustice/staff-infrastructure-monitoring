resource "aws_ecs_task_definition" "grafana_task_definition" {
  family = "${var.prefix_pttp}-grafana"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu * 2
  memory             = var.fargate_memory * 2
  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = var.execution_role_arn
  tags               = var.tags

  volume {
    name = "grafana_data"
  }

  container_definitions = <<DEFINITION
  [{
    "name": "grafana",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${var.grafana_image}",
    "environment": [
      {"name": "GF_DATABASE_TYPE", "value": "postgres"},
      {"name": "GF_DATABASE_USER", "value": "${var.db_username}"},
      {"name": "GF_DATABASE_PASSWORD", "value": "${var.db_password}"},
      {"name": "GF_DATABASE_NAME", "value": "${var.db_name}"},
      {"name": "GF_DATABASE_HOST", "value": "${var.db_endpoint}"},
      {"name": "GF_USERS_ALLOW_SIGN_UP", "value": "false"},
      {"name": "GF_SECURITY_ADMIN_USER", "value": "${var.admin_username}"},
      {"name": "GF_SECURITY_ADMIN_PASSWORD", "value": "${var.admin_password}"},
      {"name": "GF_SERVER_ROOT_URL", "value": "https://${aws_route53_record.grafana.name}"},
      {"name": "GF_AUTH_LOGIN_MAXIMUM_INACTIVE_LIFETIME_DURATION", "value": "8h"},
      {"name": "GF_AUTH_LOGIN_MAXIMUM_LIFETIME_DURATION", "value": "12h"},
      {"name": "GF_AUTH_AZUREAD_ENABLED", "value": "true"},
      {"name": "GF_AUTH_AZUREAD_CLIENT_ID", "value": "${var.azure_ad_client_id}"},
      {"name": "GF_AUTH_AZUREAD_CLIENT_SECRET", "value": "${var.azure_ad_client_secret}"},
      {"name": "GF_AUTH_AZUREAD_AUTH_URL", "value": "${var.azure_ad_auth_url}"},
      {"name": "GF_AUTH_AZUREAD_TOKEN_URL", "value": "${var.azure_ad_token_url}"},
      {"name": "GF_SMTP_HOST", "value": "email-smtp.eu-west-2.amazonaws.com:465"},
      {"name": "GF_SMTP_USER", "value": "${var.smtp_user}"},
      {"name": "GF_SMTP_PASSWORD", "value": "${var.smtp_password}"},
      {"name": "GF_SMTP_SKIP_VERIFY", "value": "true"},
      {"name": "GF_SMTP_ENABLED", "value": "true"},
      {"name": "GF_SMTP_FROM_ADDRESS", "value": "no-reply@${aws_ses_domain_mail_from.grafana_email_from.mail_from_domain}"},
      {"name": "GF_EXTERNAL_IMAGE_STORAGE_PROVIDER", "value": "s3"},
      {"name": "GF_EXTERNAL_IMAGE_STORAGE_S3_ENDPOINT", "value": "s3.eu-west-2.amazonaws.com"},
      {"name": "GF_EXTERNAL_IMAGE_STORAGE_S3_BUCKET", "value": "${var.storage_bucket_arn}"},
      {"name": "GF_EXTERNAL_IMAGE_STORAGE_S3_REGION", "value": "${var.aws_region}"},
      {"name": "GF_RENDERING_SERVER_URL", "value": "http://localhost:8081/render"},
      {"name": "GF_RENDERING_CALLBACK_URL", "value": "http://localhost:3000"},
      {"name": "GF_INSTALL_PLUGINS", "value": "alexanderzobnin-zabbix-app"},
      {"name": "GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS", "value": "alexanderzobnin-zabbix-datasource"}
    ],
    "portMappings": [{
      "hostPort": ${var.container_port},
      "containerPort": ${var.container_port}
    }],
    "mountPoints": [{
      "sourceVolume": "grafana_data",
      "containerPath": "/var/lib/grafana"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-grafana",
        "awslogs-group" : "${aws_cloudwatch_log_group.grafana_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "grafana-image-renderer",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${var.grafana_image_renderer}",
    "environment": [
      {"name": "LOG_LEVEL", "value": "debug"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-grafana-image-renderer",
        "awslogs-group" : "${aws_cloudwatch_log_group.grafana_cloudwatch_log_group.name}"
      }
    }
  }]
  DEFINITION
}

resource "aws_ecs_service" "grafana_ecs_service" {
  name = "${var.prefix_pttp}-grafana-ecs-service"

  platform_version = "1.3.0"
  launch_type      = "FARGATE"
  desired_count    = var.fargate_count
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.grafana_task_definition.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_grafana_tasks.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app_grafana.id
    container_name   = "grafana"
    container_port   = var.container_port
  }

  depends_on = [
    aws_alb_listener.front_end_grafana
  ]
}

resource "aws_cloudwatch_log_group" "grafana_cloudwatch_log_group" {
  name              = "${var.prefix}-grafana-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
