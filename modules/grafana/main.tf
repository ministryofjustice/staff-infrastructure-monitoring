# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

### ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "name": "grafana",
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "portMappings": [{
      "hostPort": ${var.app_port},
      "containerPort": ${var.app_port}
    }]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "${var.prefix}-ecs-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.grafana.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "grafana"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    aws_alb_listener.front_end
  ]
}
