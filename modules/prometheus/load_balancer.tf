resource "aws_alb" "main_prometheus" {
  name            = "${var.prefix}-prom-alb"
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.lb_prom.id]
  internal = true

  tags = var.tags
}

resource "aws_alb_target_group" "app_prometheus" {
  name        = "${var.prefix}-prom-tg"
  port        = var.fargate_port
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
  port              = var.fargate_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_prometheus.id
    type             = "forward"
  }
}
