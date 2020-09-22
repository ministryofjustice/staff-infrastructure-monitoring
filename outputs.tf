output "grafana_hostname" {
  value = module.grafana.hostname
}

output "prometheus_hostname" {
  value = module.prometheus.hostname
}

output "snmp_exporter_hostname" {
  value = module.snmp_exporter.hostname
}

output "prometheus_ecr" {
  value = {
    registry_id    = module.prometheus.ecr.registry_id
    repository_url = module.prometheus.ecr.repository_url
  }
}

output "snmp_exporter_ecr" {
  value = {
    registry_id    = module.snmp_exporter.ecr.registry_id
    repository_url = module.snmp_exporter.ecr.repository_url
  }
}
