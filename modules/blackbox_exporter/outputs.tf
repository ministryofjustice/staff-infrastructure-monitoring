output "hostname" {
  value = aws_alb.main_blackbox_exporter.dns_name
}

output "repository" {
  value = {
    registry_id    = aws_ecr_repository.blackbox_exporter.registry_id
    repository_url = aws_ecr_repository.blackbox_exporter.repository_url
  }
}