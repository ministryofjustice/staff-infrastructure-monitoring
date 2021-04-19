resource "aws_ssm_parameter" "instance_private_key" {
  name        = "/ima/testing/bastion/private_key"
  type        = "SecureString"
  value       = tls_private_key.ec2.private_key_pem
  overwrite   = true
  description = "SSH key for IMA jumpbox"
}

resource "aws_ssm_parameter" "bastion_instance_ip" {
  name        = "/ima/testing/bastion/ip"
  type        = "SecureString"
  value       = aws_instance.corsham_testing_bastion.public_ip
  overwrite   = true
  description = "IP address of the Bastion server"
}
