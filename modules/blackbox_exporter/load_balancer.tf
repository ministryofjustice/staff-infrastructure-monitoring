terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}

resource "aws_alb" "main_blackbox_exporter" {
  name = "${var.prefix_pttp}-bb-alb"

  internal        = true
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.lb_blackbox_exporter.id]

  access_logs {
    bucket  = var.lb_access_logging_bucket_name
    prefix  = "blackbox_exporter_access_logs"
    enabled = true
  }

  tags = var.tags
}

resource "aws_alb_target_group" "app_blackbox_exporter" {
  name        = "${var.prefix_pttp}-bb-tg"
  port        = var.fargate_port
  vpc_id      = var.vpc
  protocol    = "HTTP"
  target_type = "ip"

  tags = var.tags

  health_check {
    path = "/"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_blackbox_exporter" {
  load_balancer_arn = aws_alb.main_blackbox_exporter.id
  port              = var.fargate_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_blackbox_exporter.id
    type             = "forward"
  }
}
