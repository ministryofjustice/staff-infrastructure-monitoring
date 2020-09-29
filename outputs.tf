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

####################################### Bastion #################################################

output "corsham_bastion" {
  value = {
    public_ip   = module.corsham_bastion.hostname
    private_key = module.corsham_bastion.private_key
  }
}