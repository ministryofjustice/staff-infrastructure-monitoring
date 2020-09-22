resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family                   = "${var.prefix}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.execution_role_arn
  tags = var.tags

  volume {
    name = "prometheus_data"
  }


  #todo paramaterize image name?
  container_definitions = <<DEFINITION
  [{
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${aws_ecr_repository.prometheus.repository_url}",
    "environment": [],
    "portMappings": [{
      "hostPort": "${var.fargate_port}",
      "containerPort": "${var.fargate_port}"
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
        "awslogs-stream-prefix": "${var.prefix}-prom"
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}",
      }
    }
  }]
  DEFINITION
}

resource "aws_ecs_service" "prometheus_ecs_service" {
  name = "${var.prefix}-prom-ecs-service"

  launch_type     = "FARGATE"
  desired_count   = var.fargate_count
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.prometheus_task_definition.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = ["${aws_security_group.ecs_prometheus_tasks.id}"]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app_prometheus.id
    container_name   = "prometheus"
    container_port   = var.fargate_port
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
