terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.2"
    }
  }
}

resource "aws_alb" "main_grafana" {
  name = "${var.prefix_pttp}-graf-alb"

  internal        = false
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb_grafana.id]

  access_logs {
    bucket  = var.lb_access_logging_bucket_name
    prefix  = "grafana_access_logs"
    enabled = true
  }

  tags = var.tags
}

resource "aws_alb_target_group" "app_grafana" {
  name        = "${var.prefix_pttp}-graf-tg"
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

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate.grafana.arn

  default_action {
    target_group_arn = aws_alb_target_group.app_grafana.id
    type             = "forward"
  }

  depends_on = [aws_acm_certificate.grafana]

}

resource "aws_alb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_alb.main_grafana.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}

resource "aws_alb_listener_rule" "public_metrics_rule" {
  listener_arn = aws_alb_listener.front_end_grafana.arn
  action {
    type = "redirect"
    redirect {
      path        = "/"
      status_code = "HTTP_301"
    }
  }
  condition {
    path_pattern {
      values = ["/metrics"]
    }
  }
}

resource "aws_alb_listener_rule" "private_metrics_rule" {
  listener_arn = aws_alb_listener.front_end_grafana.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_grafana.arn
  }
  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = [var.vpc_cidr_range]
    }
  }
  condition {
    path_pattern {
      values = ["/metrics"]
    }
  }
}