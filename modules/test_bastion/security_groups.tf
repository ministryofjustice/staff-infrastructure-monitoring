
resource "aws_security_group" "test_bastion" {
  name        = "test-bastion"
  description = "Allow SSH into test bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_allowed_ingress_ip}/32"]
  }
}
