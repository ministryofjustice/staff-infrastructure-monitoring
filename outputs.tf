output "grafana_hostname" {
  value = module.grafana.hostname
}

output "prometheus_ecr" {
  value = {
    repository_url = module.prometheus.ecr.repository_url
    registry_id = module.prometheus.ecr.registry_id
  }
}
