resource "aws_alb" "main_prometheus" {
  name            = "${var.prefix}-prom-alb"
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb_prom.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_prometheus" {
  name        = "${var.prefix}-prom-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc
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
