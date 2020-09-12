provider "grafana" {
  url  = "http://${aws_alb.main.dns_name}"
  auth = "${var.admin_username}:${var.admin_password}"
}

resource "grafana_data_source" "cloudwatch_data_source" {
  type = "cloudwatch"
  name = "${var.prefix}-cloudwatch"
  url  = "http://${aws_alb.main.dns_name}"

  json_data {
    default_region = var.aws_region
    auth_type      = "keys"
  }

  secure_json_data {
    access_key = var.aws_cloudwatch_access_key
    secret_key = var.aws_cloudwatch_secret
  }

  depends_on = [
    aws_alb.main
  ]
}
