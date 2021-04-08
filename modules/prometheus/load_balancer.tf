resource "aws_alb" "main_prometheus" {
  name = "${var.prefix_pttp}-prom-alb"

  internal        = true
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.lb_prom.id]

  access_logs {
    bucket  = var.lb_access_logging_bucket_name
    prefix  = "prometheus_access_logs"
    enabled = true
  }

  tags = var.tags
}

resource "aws_alb_target_group" "app_prometheus" {
  name        = "${var.prefix_pttp}-prom-tg"
  port        = 10902
  vpc_id      = var.vpc
  protocol    = "HTTP"
  target_type = "ip"

  tags = var.tags

  health_check {
    path = "/graph"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_prometheus" {
  load_balancer_arn = aws_alb.main_prometheus.id
  port              = 10902
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_prometheus.id
    type             = "forward"
  }
}

