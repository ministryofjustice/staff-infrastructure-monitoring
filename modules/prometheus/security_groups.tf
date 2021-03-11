resource "aws_security_group" "ecs_prometheus_tasks" {
  name        = "${var.prefix_pttp}-ecs-prom-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc

  ingress {
    protocol        = "tcp"
    from_port       = 10902
    to_port         = 10902
    security_groups = ["${aws_security_group.lb_prom.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

data "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_ids)

  id = var.private_subnet_ids[count.index]
}

resource "aws_security_group" "lb_prom" {
  name        = "${var.prefix_pttp}-alb-prom-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 10902
    to_port     = 10902
    cidr_blocks = data.aws_subnet.private_subnets.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
