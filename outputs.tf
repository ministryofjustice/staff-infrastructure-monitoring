####################################### Hostnames #################################################

output "grafana_hostname" {
  value = module.grafana.domain
}

output "prometheus_hostname" {
  value = module.prometheus.hostname
}

output "snmp_exporter_hostname" {
  value = module.snmp_exporter.hostname
}

output "blackbox_exporter_hostname" {
  value = module.blackbox_exporter.hostname
}

####################################### Repositories #################################################

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

output "blackbox_exporter_repository" {
  value = {
    registry_id    = module.blackbox_exporter.repository.registry_id
    repository_url = module.blackbox_exporter.repository.repository_url
  }
}

output "grafana_db_name" {
  value = module.grafana.db_name
}

output "grafana_db_endpoint" {
  value = module.grafana.db_endpoint
}
