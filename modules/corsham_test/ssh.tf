resource "tls_private_key" "ec2" {
  algorithm = "RSA"
}

resource "aws_key_pair" "testing_bastion_public_key_pair" {
  public_key = tls_private_key.ec2.public_key_openssh
  key_name   = "${var.prefix}-corsham-bastion"
  tags       = var.tags
}
