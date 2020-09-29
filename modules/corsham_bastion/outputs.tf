output "hostname" {
  value = aws_instance.corsham_bastion.public_ip
}

output "private_key" {
  value = tls_private_key.corsham_bastion.private_key_pem
}
