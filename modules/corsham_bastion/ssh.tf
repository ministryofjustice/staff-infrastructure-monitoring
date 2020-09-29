resource "tls_private_key" "corsham_bastion" {
  algorithm = "RSA"
}

resource "aws_key_pair" "corsham_bastion" {
  public_key = tls_private_key.corsham_bastion.public_key_openssh
  key_name   = "${var.prefix}-corsham-bastion"
  tags       = var.tags
}
