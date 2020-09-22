resource "aws_alb" "main_snmp_exporter" {
  name            = "${var.prefix}-snmp-alb"
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb_snmp_exporter.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_snmp_exporter" {
  name        = "${var.prefix}-snmp-tg"
  port        = var.fargate_port
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = var.tags
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_snmp_exporter" {
  load_balancer_arn = aws_alb.main_snmp_exporter.id
  port              = var.fargate_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_snmp_exporter.id
    type             = "forward"
  }
}
