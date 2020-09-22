#################### Grafana ####################

resource "aws_alb" "grafana" {
  name            = "${var.prefix}-grafana"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]

  tags = var.tags
}

resource "aws_alb_target_group" "grafana" {
  name        = "${var.prefix}-grafana"
  vpc_id      = aws_vpc.main.id
  protocol    = "HTTP"
  target_type = "ip"
  port        = 80

  health_check {
    path = "/login"
  }

  tags = var.tags
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "grafana" {
  load_balancer_arn = aws_alb.grafana.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.grafana.id
    type             = "forward"
  }
}

#################### SNMP Exporter ####################

resource "aws_alb" "snmp_exporter" {
  name            = "${var.prefix}-snmp"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]

  tags = var.tags
}

resource "aws_alb_target_group" "snmp_exporter" {
  name        = "${var.prefix}-snmp"
  vpc_id      = aws_vpc.main.id
  protocol    = "HTTP"
  target_type = "ip"
  port        = 80

  health_check {
    path = "/"
  }

  tags = var.tags
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "snmp_exporter" {
  load_balancer_arn = aws_alb.snmp_exporter.id
  protocol          = "HTTP"
  port              = "80"

  default_action {
    target_group_arn = aws_alb_target_group.snmp_exporter.id
    type             = "forward"
  }
}
