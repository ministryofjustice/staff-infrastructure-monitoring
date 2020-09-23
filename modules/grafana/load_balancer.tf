resource "aws_alb" "main_grafana" {
  name            = "${var.prefix}-grafana-alb"
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb_grafana.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_grafana" {
  name        = "${var.prefix}-grafana-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    path = "/login"
  }

  tags = var.tags
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_grafana" {
  load_balancer_arn = aws_alb.main_grafana.id
  port              = var.host_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_grafana.id
    type             = "forward"
  }
}
