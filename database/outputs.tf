output "grafana_db_name" {
  value = aws_db_instance.grafana.name
}

output "grafana_db_endpoint" {
  value = aws_db_instance.grafana.endpoint
}
