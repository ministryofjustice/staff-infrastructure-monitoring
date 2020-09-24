resource "aws_alb" "main_grafana" {
  name = "${var.prefix}-grafana-alb"

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

resource "aws_alb_listener" "front_end_grafana" {
  load_balancer_arn = aws_alb.main_grafana.id
  port              = var.host_port
  protocol          = "HTTPS"
  
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.grafana.arn

  default_action {
    target_group_arn = aws_alb_target_group.app_grafana.id
    type             = "forward"
  }

  depends_on        = [aws_acm_certificate.grafana]
}
