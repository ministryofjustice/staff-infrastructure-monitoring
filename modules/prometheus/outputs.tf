output "ecr" {
  value = {
    repository_url = aws_ecr_repository.prometheus.repository_url
    registry_id    = aws_ecr_repository.prometheus.registry_id
  }
}

output "hostname" {
  value = aws_alb.main_prometheus.dns_name
}
