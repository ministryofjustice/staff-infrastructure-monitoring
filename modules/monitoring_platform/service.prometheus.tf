resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family = "${var.prefix}-prometheus-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = aws_iam_role.cloudwatch_task_role.arn
  execution_role_arn = aws_iam_role.cloudwatch_execution_role.arn
  tags               = var.tags

  volume {
    name = "prometheus_data"
  }

  container_definitions = <<DEFINITION
  [{
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${var.prometheus_image}",
    "environment": [
    ],
    "command": [
      "--storage.tsdb.path=/prometheus",
      "--config.file=/etc/prometheus/prometheus.yml"
    ],
    "portMappings": [{
      "hostPort": ${var.prometheus_port},
      "containerPort": ${var.prometheus_port}
    }],
    "mountPoints": [{
      "sourceVolume": "prometheus_data",
      "containerPath": "/var/lib/prometheus"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  }]
  DEFINITION
}

resource "aws_ecs_service" "prometheus_ecs_service" {
  name = "${var.prefix}-prometheus-ecs-service"

  launch_type     = "FARGATE"
  desired_count   = var.fargate_count
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prometheus_task_definition.arn

  network_configuration {
    subnets         = aws_subnet.private.*.id
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
  }

  load_balancer {
    container_name   = "prometheus"
    container_port   = var.prometheus_port
    target_group_arn = aws_alb_target_group.prometheus.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_alb_listener.prometheus
  ]
}

resource "aws_cloudwatch_log_group" "prometheus_cloudwatch_log_group" {
  name              = "${var.prefix}-prometheus-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
