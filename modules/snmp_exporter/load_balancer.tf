resource "aws_alb" "main_snmp_exporter" {
  name            = "${var.prefix}-snmp-alb"

  internal        = true
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.lb_snmp_exporter.id]

  tags = var.tags
}

resource "aws_alb_target_group" "app_snmp_exporter" {
  name        = "${var.prefix}-snmp-tg"
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
resource "aws_alb_listener" "front_end_snmp_exporter" {
  load_balancer_arn = aws_alb.main_snmp_exporter.id
  port              = var.fargate_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_snmp_exporter.id
    type             = "forward"
  }
}
