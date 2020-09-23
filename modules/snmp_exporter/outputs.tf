output "hostname" {
  value = aws_alb.main_snmp_exporter.dns_name
}

output "repository" {
  value = {
    registry_id    = aws_ecr_repository.snmp_exporter.registry_id
    repository_url = aws_ecr_repository.snmp_exporter.repository_url
  }
}
