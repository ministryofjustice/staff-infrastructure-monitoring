####################################### Hostnames #################################################

output "grafana_hostname_v2" {
  value = module.grafana_v2.domain
}

output "prometheus_hostname_v2" {
  value = module.prometheus_v2.hostname
}

output "snmp_exporter_hostname_v2" {
  value = module.snmp_exporter_v2.hostname
}

output "blackbox_exporter_hostname_v2" {
  value = module.blackbox_exporter_v2.hostname
}

####################################### Repositories #################################################

output "prometheus_repository_v2" {
  value = {
    registry_id    = module.prometheus_v2.repository.registry_id
    repository_url = module.prometheus_v2.repository.repository_url
  }
}

output "snmp_exporter_repository_v2" {
  value = {
    registry_id    = module.snmp_exporter_v2.repository.registry_id
    repository_url = module.snmp_exporter_v2.repository.repository_url
  }
}

output "blackbox_exporter_repository_v2" {
  value = {
    registry_id    = module.blackbox_exporter_v2.repository.registry_id
    repository_url = module.blackbox_exporter_v2.repository.repository_url
  }
}

output "grafana_database_config_v2" {
  value = {
    grafana_db_subnet_group_name    = module.grafana_v2.grafana_db_subnet_group_name
    grafana_db_in_security_group_id = module.grafana_v2.db_in_security_group_id
    rds_monitoring_role_arn         = module.monitoring_platform_v2.rds_monitoring_role_arn

  }
}

############################################ EKS Cluser ##################################

output "eks_cluster_id" {
  value = module.monitoring_platform_v2.eks_cluster_id
}

output "eks_cluster_endpoint" {
  value = module.monitoring_platform_v2.eks_cluster_endpoint
}

output "eks_cluster_worker_iam_role_arn" {
  value = module.monitoring_platform_v2.eks_cluster_worker_iam_role_arn
}