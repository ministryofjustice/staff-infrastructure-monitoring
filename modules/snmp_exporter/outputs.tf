output "ecr" {
  value = {
    repository_url = aws_ecr_repository.snmp_exporter.repository_url
    registry_id = aws_ecr_repository.snmp_exporter.registry_id
  }
}
