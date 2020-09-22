resource "aws_ecs_task_definition" "grafana_task_definition" {
  family = "${var.prefix}-grafana-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = aws_iam_role.cloudwatch_task_role.arn
  execution_role_arn = aws_iam_role.cloudwatch_execution_role.arn
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
      {"name": "GF_USERS_ALLOW_SIGN_UP", "value": "false"},
      {"name": "GF_DATABASE_USER", "value": "${var.db_username}"},
      {"name": "GF_DATABASE_PASSWORD", "value": "${var.db_password}"},
      {"name": "GF_DATABASE_NAME", "value": "${aws_db_instance.db.name}"},
      {"name": "GF_SECURITY_ADMIN_USER", "value": "${var.admin_username}"},
      {"name": "GF_DATABASE_HOST", "value": "${aws_db_instance.db.endpoint}"},
      {"name": "GF_SECURITY_ADMIN_PASSWORD", "value": "${var.admin_password}"}
    ],
    "portMappings": [{
      "hostPort": ${var.grafana_port},
      "containerPort": ${var.grafana_port}
    }],
    "mountPoints": [{
      "sourceVolume": "grafana_data",
      "containerPath": "/var/lib/grafana"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}",
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
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana_task_definition.arn

  network_configuration {
    subnets         = aws_subnet.private.*.id
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
  }

  load_balancer {
    container_name   = "grafana"
    container_port   = var.grafana_port
    target_group_arn = aws_alb_target_group.grafana.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_alb_listener.grafana
  ]
}

resource "aws_cloudwatch_log_group" "grafana_cloudwatch_log_group" {
  name              = "${var.prefix}-grafana-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
