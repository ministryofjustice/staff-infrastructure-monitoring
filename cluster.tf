# Service
# Task definition
  # Docker image

resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = file("task-definitions/hello-world.json")
  requires_compatibilities = ["FARGATE"]
  memory = 512
  cpu = 256
  network_mode = "awsvpc"
}

resource "aws_ecs_service" "main" {
  name            = "tf-ecs-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.main.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.arn
    container_name   = "hello-world"
    container_port   = 80
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${module.label.id}-cluster"
}
