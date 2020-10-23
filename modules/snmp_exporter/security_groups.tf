resource "aws_security_group" "ecs_snmp_exporter_tasks" {
  name        = "${var.prefix_pttp}-ecs-snmp-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc

  ingress {
    protocol        = "tcp"
    from_port       = var.fargate_port
    to_port         = var.fargate_port
    security_groups = ["${aws_security_group.lb_snmp_exporter.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "lb_snmp_exporter" {
  name        = "${var.prefix_pttp}-alb-snmp-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = var.fargate_port
    to_port     = var.fargate_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
