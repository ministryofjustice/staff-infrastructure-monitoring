provider "grafana" {
  url  = var.grafana_url
  auth = "${var.grafana_admin_username}:${var.grafana_admin_password}"
}

resource "grafana_data_source" "cloudwatch_data_source" {
  type = "cloudwatch"
  name = "${var.cloudwatch_data_source_name}"
  url  = var.grafana_url

  json_data {
    default_region = var.aws_region
    auth_type      = "credentials"
  }
}
