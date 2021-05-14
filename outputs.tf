###################################### Env #################################################

output "assume_role" {
  value = var.assume_role
}

output "env" {
  value = terraform.workspace
}

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

output "internal_hosted_zone_domain" {
  value = {
    name = aws_route53_zone.internal.name
    id   = aws_route53_zone.internal.zone_id
  }
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

########################################### EKS Cluser ##################################

output "eks_cluster_id" {
  value = module.monitoring_platform_v2.eks_cluster_id
}

output "eks_cluster_endpoint" {
  value = module.monitoring_platform_v2.eks_cluster_endpoint
}

output "eks_cluster_worker_iam_role_arn" {
  value = module.monitoring_platform_v2.eks_cluster_worker_iam_role_arn
}

output "prometheus_thanos_storage_bucket_name" {
  value = module.prometheus-thanos-storage.bucket_name
}

output "prometheus_thanos_storage_kms_key_id" {
  value = module.prometheus-thanos-storage.kms_key_id
}

output "cloudwatch_exporter_assume_role_arn" {
  value = module.cloudwatch_exporter.assume_role_arn
}

output "cloudwatch_exporter_access_role_arns" {
  value = var.cloudwatch_exporter_access_role_arns
}

output "ses_mail_from_domain" {
  value = module.grafana_v2.ses_mail_from_domain
}
