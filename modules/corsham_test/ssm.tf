resource "aws_ssm_parameter" "instance_private_key" {
  overwrite   = true
  type        = "SecureString"
  description = "SSH key for Corsham jumpbox"
  value       = tls_private_key.ec2.private_key_pem
  name        = "/corsham/testing/bastion/private_key"
  tags        = var.tags
}

resource "aws_ssm_parameter" "bastion_instance_ip" {
  overwrite   = true
  type        = "SecureString"
  name        = "/corsham/testing/bastion/ip"
  description = "IP address of the Bastion server"
  value       = aws_instance.corsham_testing_bastion.public_ip
  tags        = var.tags
}
