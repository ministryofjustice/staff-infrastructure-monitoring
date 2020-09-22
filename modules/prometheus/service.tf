resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family                   = "${var.prefix}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.execution_role_arn

  volume {
    name = "prometheus_data"
  }


#todo paramaterize image name?
  container_definitions = <<DEFINITION
[
  {
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.prometheus.repository_url}",
    "memory": ${var.fargate_memory},
    "environment": [],
    "portMappings": [{
      "hostPort": 9090,
      "containerPort": 9090
    }],
    "command": [
      "--storage.tsdb.path=/prometheus",
      "--config.file=/etc/prometheus/prometheus.yml"
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus_data",
        "containerPath": "/prometheus"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "eu-west-2",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}",
        "awslogs-stream-prefix": "${var.prefix}-prom"
      }
    }
  }
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "prometheus_ecs_service" {
  name            = "${var.prefix}-prom-ecs-service"

  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.prometheus_task_definition.arn
  desired_count   = 1

  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_prometheus_tasks.id}"]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app_prometheus.id
    container_name   = "prometheus"
    container_port   = 9090
  }

  depends_on = [
    aws_alb_listener.front_end_prometheus
  ]
}

resource "aws_cloudwatch_log_group" "prometheus_cloudwatch_log_group" {
  name              = "${var.prefix}-prometheus-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
