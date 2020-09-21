output "grafana_hostname" {
  value = aws_alb.grafana.dns_name
}

output "snmp_exporter_hostname" {
  value = aws_alb.snmp_exporter.dns_name
}
