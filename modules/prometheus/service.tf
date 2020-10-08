resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family                   = "${var.prefix}-prometheus"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = 1024
  memory             = 2048
  execution_role_arn = var.execution_role_arn
  task_role_arn      = aws_iam_role.task_role.arn
  tags               = var.tags

  volume {
    name = "prometheus_data"
  }

  container_definitions = <<DEFINITION
  [{
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${aws_ecr_repository.prometheus.repository_url}",
    "mountPoints": [{
      "sourceVolume": "prometheus_data",
      "containerPath": "/var/lib/prometheus"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}-prom",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-sidecar",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "sidecar",
      "--prometheus.url=http://localhost:9090",
      "--grpc-address=0.0.0.0:10903",
      "--http-address=0.0.0.0:10904"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}-thsc",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-querier",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "query",
      "--store=0.0.0.0:10903"
    ],
    "portMappings": [{
      "hostPort": 10902,
      "containerPort": 10902
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}-thqr",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-store",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "quay.io/thanos/thanos:v0.15.0",
    "essential": false,
    "command": [
      "store",
      "--grpc-address=0.0.0.0:20091",
      "--http-address=0.0.0.0:20902",
      "--data-dir=/tmp/thanos/store",
      "--objstore.config=${data.template_file.storage_config.rendered}"
    ],
    "portMappings": [{
      "hostPort": 20902,
      "containerPort": 20902
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix}-thqr",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
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
    container_name   = "thanos-querier"
    container_port   = 10902
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

data "template_file" "storage_config" {
  template = file("${path.module}/s3config.template.yml")

  vars = {
    bucket_name = aws_s3_bucket.storage.bucket
    endpoint = "s3.eu-west-2.amazonaws.com"
  }
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.prefix}-thanos-storage"
  acl    = "private"

  tags = var.tags
}
