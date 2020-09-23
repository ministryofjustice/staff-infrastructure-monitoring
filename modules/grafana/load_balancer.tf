resource "aws_alb" "main_grafana" {
  name            = "${var.prefix}-grafana-alb"

  internal        = false
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb_grafana.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_grafana" {
  name        = "${var.prefix}-grafana-tg"
  port        = var.container_port
  vpc_id      = var.vpc
  protocol    = "HTTP"
  target_type = "ip"

  tags = var.tags

  health_check {
    path = "/login"
  }
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
