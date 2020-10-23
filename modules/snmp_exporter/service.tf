resource "aws_ecs_task_definition" "snmp_exporter_task_definition" {
  family = "${var.prefix_pttp}-snmp_exporter-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  execution_role_arn = var.execution_role_arn
  tags               = var.tags

  container_definitions = <<DEFINITION
  [{
    "name": "snmp_exporter",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${aws_ecr_repository.snmp_exporter.repository_url}",
    "portMappings": [{
      "hostPort": ${var.fargate_port},
      "containerPort": ${var.fargate_port}
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region" : "${var.aws_region}",
        "awslogs-stream-prefix": "${var.prefix_pttp}-snmp",
        "awslogs-group" : "${aws_cloudwatch_log_group.snmp_exporter_cloudwatch_log_group.name}"
      }
    }
  }]
  DEFINITION
}

resource "aws_ecs_service" "snmp_exporter_ecs_service" {
  name = "${var.prefix_pttp}-snmp_exporter-ecs-service"

  launch_type     = "FARGATE"
  desired_count   = var.fargate_count
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.snmp_exporter_task_definition.arn

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = ["${aws_security_group.ecs_snmp_exporter_tasks.id}"]
  }

  load_balancer {
    container_name   = "snmp_exporter"
    container_port   = var.fargate_port
    target_group_arn = aws_alb_target_group.app_snmp_exporter.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_alb_listener.front_end_snmp_exporter
  ]
}

resource "aws_cloudwatch_log_group" "snmp_exporter_cloudwatch_log_group" {
  name              = "${var.prefix_pttp}-snmp_exporter-cloudwatch-log-group"
  retention_in_days = 7

  tags = var.tags
}
