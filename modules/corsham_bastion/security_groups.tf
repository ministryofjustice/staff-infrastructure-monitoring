
resource "aws_security_group" "corsham_bastion" {
  name        = "${var.prefix}-corsham-bastion"
  description = "Allow SSH into Corsham bastion"

  vpc_id      = var.vpc
  tags        = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
