resource "aws_security_group" "ecs_grafana_tasks" {
  name        = "${var.prefix_pttp}-ecs-grafana-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = ["${aws_security_group.lb_grafana.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "lb_grafana" {
  name        = "${var.prefix_pttp}-alb-grafana-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = var.host_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
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

resource "aws_security_group" "db_in" {
  name        = "${var.prefix_pttp}-db-in"
  description = "allow connections to the DB"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = var.db_port
    to_port     = var.db_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
