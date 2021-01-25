resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_ssm_parameter" "ci_user_password" {
  name  = "/codebuild/pttp-ci-ima-pipeline/${terraform.workspace}/ci_user_password"
  type  = "SecureString"
  value = random_password.password.result
}

resource "grafana_user" "ci_user" {
  email    = "ci@monitoring-alerting.staff.service.justice.gov.uk"
  name     = "CI"
  login    = "ci"
  password = aws_ssm_parameter.ci_user_password.value
}

resource "grafana_organization" "administration" {
  name         = "Administration"
  admin_user   = "pttp"
  create_users = true
  admins = [
    "ci@monitoring-alerting.staff.service.justice.gov.uk"
  ]
}
