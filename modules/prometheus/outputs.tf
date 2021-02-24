output "hostname" {
  value = aws_alb.main_prometheus.dns_name
}

output "repository" {
  value = {
    registry_id    = aws_ecr_repository.prometheus.registry_id
    repository_url = aws_ecr_repository.prometheus.repository_url
  }
}
