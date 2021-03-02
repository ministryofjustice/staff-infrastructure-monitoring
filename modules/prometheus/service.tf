resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family = "${var.prefix_pttp}-prometheus"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = 4096
  memory             = 18432
  execution_role_arn = var.execution_role_arn
  task_role_arn      = aws_iam_role.task_role.arn
  tags               = var.tags

  volume {
    name = "prometheus_data"
  }

  volume {
    name = "thanos_receiver_data"
  }

  container_definitions = <<DEFINITION
  [{
    "name": "prometheus",
    "cpu": 1024,
    "memory": 512,
    "user": "root",
    "image": "${aws_ecr_repository.prometheus.repository_url}",
    "command": [
      "--config.file=/etc/prometheus/prometheus.yml",
      "--storage.tsdb.min-block-duration=2h",
      "--storage.tsdb.max-block-duration=2h",
      "--storage.tsdb.path=/var/lib/prometheus",
      "--web.enable-lifecycle"
    ],
    "mountPoints": [{
      "sourceVolume": "prometheus_data",
      "containerPath": "/var/lib/prometheus"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-prom",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-receiver",
    "cpu": 1024,
    "memory": 512,
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "receive",
      "--grpc-address=0.0.0.0:10903",
      "--http-address=0.0.0.0:10904",
      "--objstore.config=${local.storage_config}",
      "--tsdb.path=/var/lib/prometheus",
      "--receive.local-endpoint=127.0.0.1:10903",
      "--remote-write.address=0.0.0.0:10908"
    ],
    "mountPoints": [{
      "sourceVolume": "thanos_receiver_data",
      "containerPath": "/var/lib/prometheus"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-thsc",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-querier",
    "cpu": 1024,
    "memory": 512,
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "query",
      "--store=localhost:10903",
      "--store=localhost:20091"
    ],
    "portMappings": [{
      "hostPort": 10902,
      "containerPort": 10902
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-thqr",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  },
  {
    "name": "thanos-store",
    "cpu": 1024,
    "memory": 17408,
    "image": "quay.io/thanos/thanos:v0.15.0",
    "essential": false,
    "command": [
      "store",
      "--grpc-address=0.0.0.0:20091",
      "--http-address=0.0.0.0:20902",
      "--data-dir=/tmp/thanos/store",
      "--objstore.config=${local.storage_config}"
    ],
    "portMappings": [{
      "hostPort": 20902,
      "containerPort": 20902
    }],
    "ulimits": [{
      "name": "nofile",
      "softLimit": 409600,
      "hardLimit": 409600
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-thqr",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  }]
DEFINITION
}

resource "aws_ecs_service" "prometheus_ecs_service" {
  name = "${var.prefix_pttp}-prom-ecs-service"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  desired_count    = var.fargate_count
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.prometheus_task_definition.arn

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


resource "aws_ecs_task_definition" "thanos_compactor_task_definition" {
  family = "${var.prefix_pttp}-prometheus"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = 512
  memory             = 4096
  execution_role_arn = var.execution_role_arn
  task_role_arn      = aws_iam_role.task_role.arn
  tags               = var.tags


  container_definitions = <<DEFINITION
  [{
    "name": "thanos-compactor",
    "cpu": 512,
    "memory": 4096,
    "image": "quay.io/thanos/thanos:v0.15.0",
    "essential": true,
    "command": [
      "compact",
      "--data-dir=/tmp/thanos-compact",
      "--objstore.config=${local.storage_config}",
      "--wait",
      "--wait-interval=5m"
    ],
    "ulimits": [{
      "name": "nofile",
      "softLimit": 409600,
      "hardLimit": 409600
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-thqr",
        "awslogs-group" : "${aws_cloudwatch_log_group.prometheus_cloudwatch_log_group.name}"
      }
    }
  }]
DEFINITION
}

resource "aws_ecs_service" "thanos_compactor_ecs_service" {
  count = var.enable_compactor == "true" ? 1 : 0

  name = "${var.prefix_pttp}-comp-ecs-service"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  desired_count    = var.fargate_count
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.thanos_compactor_task_definition.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = ["${aws_security_group.ecs_prometheus_tasks.id}"]
  }
}

resource "aws_cloudwatch_log_group" "prometheus_cloudwatch_log_group" {
  name              = "${var.prefix}-prometheus-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}

locals {
  storage_config = templatefile("${path.module}/s3config.template.yml", {
    bucket_name = var.storage_bucket_arn
    endpoint    = "s3.eu-west-2.amazonaws.com"
    kms_key_id  = var.storage_key_id
  })
}
