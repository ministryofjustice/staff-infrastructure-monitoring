resource "aws_ecs_task_definition" "prometheus_task_definition" {
  family                   = "${var.prefix}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.grafana_execution_role.arn

  volume {
    name = "prometheus_data"
  }


#todo paramaterize image name?
  container_definitions = <<DEFINITION
[
  {
    "name": "prometheus",
    "cpu": ${var.fargate_cpu},
    "image": "068084030754.dkr.ecr.eu-west-2.amazonaws.com/pttp-development-ima-prometheus:latest",
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

  cluster         = aws_ecs_cluster.grafana_ecs_cluster.id
  task_definition = aws_ecs_task_definition.prometheus_task_definition.arn
  desired_count   = 1

  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_prometheus_tasks.id}"]
    subnets         = aws_subnet.private.*.id
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

resource "aws_alb" "main_prometheus" {
  name            = "${var.prefix}-prom-alb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb_prom.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_prometheus" {
  name        = "${var.prefix}-prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/graph"
  }

  tags = var.tags
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_prometheus" {
  load_balancer_arn = aws_alb.main_prometheus.id
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_prometheus.id
    type             = "forward"
  }
}

resource "aws_security_group" "ecs_prometheus_tasks" {
  name        = "${var.prefix}-ecs-prom-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 9090
    to_port         = 9090
    security_groups = ["${aws_security_group.lb_prom.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "lb_prom" {
  name        = "${var.prefix}-alb-prom-sg"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}