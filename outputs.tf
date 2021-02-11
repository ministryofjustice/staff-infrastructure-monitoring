####################################### Hostnames #################################################

output "grafana_hostname" {
  value = {
    old = module.grafana_old.domain
    new = module.grafana.domain
  }
}

output "prometheus_hostname" {
  value = {
    old = module.prometheus_old.hostname
    new = module.prometheus.hostname
  }
}

output "snmp_exporter_hostname" {
  value = {
    old = module.snmp_old.hostname
    new = module.snmp.hostname
  }
}

output "blackbox_exporter_hostname" {
  value = {
    old = module.blackbox_old.hostname
    new = module.blackbox.hostname
  }
}

####################################### Repositories #################################################

output "prometheus_repository" {
  value = {
    old_registry_id    = module.prometheus_old.repository.registry_id
    old_repository_url = module.prometheus_old.repository.repository_url
    registry_id        = module.prometheus.repository.registry_id
    repository_url     = module.prometheus.repository.repository_url
  }
}

output "snmp_exporter_repository" {
  value = {
    old_registry_id    = module.snmp_exporter_old.repository.registry_id
    old_repository_url = module.snmp_exporter_old.repository.repository_url
    registry_id        = module.snmp_exporter.repository.registry_id
    repository_url     = module.snmp_exporter.repository.repository_url
  }
}

output "blackbox_exporter_repository" {
  value = {
    old_registry_id    = module.blackbox_exporter_old.repository.registry_id
    old_repository_url = module.blackbox_exporter_old.repository.repository_url
    registry_id        = module.blackbox_exporter.repository.registry_id
    repository_url     = module.blackbox_exporter.repository.repository_url
  }
}

output "grafana_database_config" {
  value = {
    old_grafana_db_subnet_group_name    = module.grafana_old.grafana_db_subnet_group_name
    old_grafana_db_in_security_group_id = module.grafana_old.db_in_security_group_id
    old_rds_monitoring_role_arn         = module.monitoring_platform_old.rds_monitoring_role_arn
    grafana_db_subnet_group_name        = module.grafana.grafana_db_subnet_group_name
    grafana_db_in_security_group_id     = module.grafana.db_in_security_group_id
    rds_monitoring_role_arn             = module.monitoring_platform.rds_monitoring_role_arn
  }
}