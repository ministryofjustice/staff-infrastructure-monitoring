resource "aws_ecs_cluster" "grafana_ecs_cluster" {
  name = "${var.prefix}-ecs-cluster"

  tags = var.tags
}

resource "aws_ecs_task_definition" "grafana_task_definition" {
  family                   = "${var.prefix}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.grafana_execution_role.arn
  task_role_arn            = aws_iam_role.grafana_task_role.arn

  volume {
    name = "grafana_data"
  }

  container_definitions = <<DEFINITION
[
  {
    "name": "grafana",
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "environment": [
      {"name": "GF_SECURITY_ADMIN_USER", "value": "${var.admin_username}"},
      {"name": "GF_SECURITY_ADMIN_PASSWORD", "value": "${var.admin_password}"},
      {"name": "GF_USERS_ALLOW_SIGN_UP", "value": "false"},
      {"name": "GF_DATABASE_TYPE", "value": "postgres"},
      {"name": "GF_DATABASE_HOST", "value": "${aws_db_instance.db.endpoint}"},
      {"name": "GF_DATABASE_NAME", "value": "${aws_db_instance.db.name}"},
      {"name": "GF_DATABASE_USER", "value": "${var.db_username}"},
      {"name": "GF_DATABASE_PASSWORD", "value": "${var.db_password}"}
    ],
    "mountPoints": [
      {
        "sourceVolume": "grafana_data",
        "containerPath": "/var/lib/grafana"
      }
    ],
    "portMappings": [{
      "hostPort": ${var.app_port},
      "containerPort": ${var.app_port}
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "eu-west-2",
        "awslogs-group" : "${aws_cloudwatch_log_group.grafana_cloudwatch_log_group.name}",
        "awslogs-stream-prefix": "${var.prefix}"
      }
    }
  }
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "grafana_ecs_service" {
  name            = "${var.prefix}-ecs-service"

  cluster         = aws_ecs_cluster.grafana_ecs_cluster.id
  task_definition = aws_ecs_task_definition.grafana_task_definition.arn
  desired_count   = var.app_count

  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "grafana"
    container_port   = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end
  ]
}

resource "aws_cloudwatch_log_group" "grafana_cloudwatch_log_group" {
  name              = "${var.prefix}-grafana-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
