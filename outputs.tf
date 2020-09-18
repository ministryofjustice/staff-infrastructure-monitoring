output "grafana_hostname" {
  value = module.grafana.hostname
}

output "prometheus_ecr" {
  value = {
    repository_url = module.prometheus.ecr.repository_url
    registry_id = module.prometheus.ecr.registry_id
  }
}

output "snmp_exporter_ecr" {
  value = {
    repository_url = module.snmp_exporter.ecr.repository_url
    registry_id = module.snmp_exporter.ecr.registry_id
  }
}
