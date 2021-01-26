resource "grafana_user" "ci_user" {
  email    = "ci@monitoring-alerting.staff.service.justice.gov.uk"
  name     = "CI"
  login    = var.ci_user_login
  password = var.ci_user_password
}

resource "grafana_organization" "administration" {
  name       = "Administration"
  admin_user = "pttp"
  admins = [
    grafana_user.ci_user.email
  ]
}
