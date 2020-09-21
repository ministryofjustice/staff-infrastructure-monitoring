resource "aws_ecs_task_definition" "snmp_exporter_task_definition" {
  family = "${var.prefix}-snmp_exporter-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = aws_iam_role.cloudwatch_task_role.arn
  execution_role_arn = aws_iam_role.cloudwatch_execution_role.arn
  tags               = var.tags

  volume {
    name = "snmp_exporter_data"
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "snmp_exporter",
      "cpu": ${var.fargate_cpu},
      "memory": ${var.fargate_memory},
      "image": "${var.snmp_exporter_image}",
      "environment": [
      ],
      "mountPoints": [
        {
          "sourceVolume": "snmp_exporter_data",
          "containerPath": "/var/lib/snmp_exporter"
        }
      ],
      "portMappings": [{
        "hostPort": ${var.snmp_exporter_port},
        "containerPort": ${var.snmp_exporter_port}
      }],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix": "${var.prefix}",
          "awslogs-group" : "${aws_cloudwatch_log_group.snmp_exporter_cloudwatch_log_group.name}"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "snmp_exporter_ecs_service" {
  name = "${var.prefix}-snmp_exporter-ecs-service"

  launch_type     = "FARGATE"
  desired_count   = var.fargate_count
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.snmp_exporter_task_definition.arn

  network_configuration {
    subnets         = aws_subnet.private.*.id
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
  }

  load_balancer {
    container_name   = "snmp_exporter"
    container_port   = var.snmp_exporter_port
    target_group_arn = aws_alb_target_group.snmp_exporter.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_alb_listener.snmp_exporter
  ]
}

resource "aws_cloudwatch_log_group" "snmp_exporter_cloudwatch_log_group" {
  name              = "${var.prefix}-snmp_exporter-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
