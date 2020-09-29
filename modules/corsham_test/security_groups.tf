
resource "aws_security_group" "corsham_test_bastion" {
  name        = "${var.prefix}-corsham-test-bastion"
  description = "Allow SSH into Corsham test bastion"

  vpc_id      = var.vpc

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

  tags = var.tags
}
