resource "aws_efs_file_system" "foobar" {
  tags = {
    Name = "${var.prefix_pttp}-ECS-EFS-FS"
  }
}

resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "ecs_loopback_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  description       = "Loopback"
  security_group_id = "${aws_security_group.efs.id}"
}


resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.foobar.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.foobar.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "mount_foobar" {
  count = "${length(var.private_subnet_ids)}"

  file_system_id = aws_efs_file_system.foobar.id
  subnet_id      = "${element(var.private_subnet_ids, count.index)}"

  security_groups = [
    "${aws_security_group.efs.id}"
  ]
}


resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family = "${var.prefix_pttp}-prometheus"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = 1024
  memory             = 2048
  execution_role_arn = var.execution_role_arn
  task_role_arn      = aws_iam_role.task_role.arn
  tags               = var.tags

  volume {
    name = "prometheus_data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.foobar.id
      root_directory = "/"
    }
  }

  //TODO: DON'T MERGE WITH THE DOCKER HUB PROMETHEUS IMAGE
  container_definitions = <<DEFINITION
  [{
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "user": "root",
    "image": "prom/prometheus",
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
    "name": "thanos-sidecar",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "sidecar",
      "--prometheus.url=http://localhost:9090",
      "--tsdb.path=/var/lib/prometheus",
      "--grpc-address=0.0.0.0:10903",
      "--http-address=0.0.0.0:10904",
      "--objstore.config=${data.template_file.storage_config.rendered}"
    ],
    "mountPoints": [{
      "sourceVolume": "prometheus_data",
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
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "quay.io/thanos/thanos:v0.15.0",
    "command": [
      "query",
      "--store=0.0.0.0:10903",
      "--store=0.0.0.0:20091"
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
    security_groups = ["${aws_security_group.ecs_prometheus_tasks.id}", "${aws_security_group.efs.id}"]
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
    endpoint    = "s3.eu-west-2.amazonaws.com"
    kms_key_id  = aws_kms_key.storage_key.key_id
  }
}
