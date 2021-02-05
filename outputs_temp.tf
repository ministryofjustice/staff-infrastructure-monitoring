####################################### Hostnames #################################################

output "grafana_temp_hostname" {
  value = module.grafana_temp.domain
}

output "prometheus_temp_hostname" {
  value = module.prometheus_temp.hostname
}

output "snmp_exporter_temp_hostname" {
  value = module.snmp_exporter_temp.hostname
}

output "blackbox_exporter_temp_hostname" {
  value = module.blackbox_exporter_temp.hostname
}

##################################### repositories ##################################################
output "prometheus_temp_repository" {
  value = {
    registry_id    = module.prometheus_temp.repository.registry_id
    repository_url = module.prometheus_temp.repository.repository_url
  }
}