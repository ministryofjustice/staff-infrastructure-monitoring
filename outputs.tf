output "grafana_hostname" {
  value = module.grafana.hostname
}

output "prometheus_hostname" {
  value = module.prometheus.hostname
}

output "snmp_exporter_hostname" {
  value = module.snmp_exporter.hostname
}

output "prometheus_repository" {
  value = {
    registry_id    = module.prometheus.repository.registry_id
    repository_url = module.prometheus.repository.repository_url
  }
}

output "snmp_exporter_repository" {
  value = {
    registry_id    = module.snmp_exporter.repository.registry_id
    repository_url = module.snmp_exporter.repository.repository_url
  }
}
