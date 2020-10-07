resource "aws_ecs_task_definition" "grafana_task_definition" {
  family = "${var.prefix}-grafana"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = var.task_role_arn
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
    "image": "${var.fargate_image}",
    "environment": [
      {"name": "GF_DATABASE_TYPE", "value": "postgres"},
      {"name": "GF_USERS_ALLOW_SIGN_UP", "value": "false"},
      {"name": "GF_DATABASE_USER", "value": "${var.db_username}"},
      {"name": "GF_DATABASE_PASSWORD", "value": "${var.db_password}"},
      {"name": "GF_DATABASE_NAME", "value": "${aws_db_instance.db.name}"},
      {"name": "GF_SECURITY_ADMIN_USER", "value": "${var.admin_username}"},
      {"name": "GF_DATABASE_HOST", "value": "${aws_db_instance.db.endpoint}"},
      {"name": "GF_SECURITY_ADMIN_PASSWORD", "value": "${var.admin_password}"},
      {"name": "GF_SERVER_ROOT_URL", "value": "https://${aws_route53_record.grafana.name}"},
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
      {"name": "GF_SMTP_FROM_ADDRESS", "value": "no-reply@${aws_ses_domain_mail_from.grafana_email_from.mail_from_domain}"}
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
        "awslogs-stream-prefix": "${var.prefix}-grafana",
        "awslogs-group" : "${aws_cloudwatch_log_group.grafana_cloudwatch_log_group.name}"
      }
    }
  }]
  DEFINITION
}

resource "aws_ecs_service" "grafana_ecs_service" {
  name = "${var.prefix}-grafana-ecs-service"

  launch_type     = "FARGATE"
  desired_count   = var.fargate_count
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.grafana_task_definition.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = ["${aws_security_group.ecs_grafana_tasks.id}"]
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
