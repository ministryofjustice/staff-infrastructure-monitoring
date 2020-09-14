provider "grafana" {
  url  = "http://${aws_alb.main.dns_name}"
  auth = "${var.admin_username}:${var.admin_password}"
}

resource "grafana_data_source" "cloudwatch_data_source" {
  type = "cloudwatch"
  name = "${var.prefix}-cloudwatch"
  url  = "http://${aws_alb.main.dns_name}"

  json_data {
    default_region  = var.aws_region
    auth_type       = "arn"
    assume_role_arn = aws_iam_role.cloudwatch_read_role.arn
  }

  depends_on = [
    aws_alb.main
  ]
}
