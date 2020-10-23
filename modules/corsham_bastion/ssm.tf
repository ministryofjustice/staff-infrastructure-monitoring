resource "aws_ssm_parameter" "instance_private_key" {
  overwrite   = true
  type        = "SecureString"
  description = "Corsham Bastion - SSH Key"
  name        = "/${var.prefix}/corsham/bastion/private_key"
  value       = tls_private_key.corsham_bastion.private_key_pem
  tags        = var.tags
}

resource "aws_ssm_parameter" "bastion_instance_ip" {
  overwrite   = true
  type        = "SecureString"
  description = "Corsham Bastion - IP Address"
  name        = "/${var.prefix}/corsham/bastion/ip"
  value       = aws_instance.corsham_bastion.public_ip
  tags        = var.tags
}
