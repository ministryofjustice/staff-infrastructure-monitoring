terraform {
  required_version = "> 0.12.0"
}

provider "aws" {
  alias   = "env"
  version = "~> 2.68"
  profile = var.environment

}

module "label" {
  version = "0.16.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  name      = "IMA"
  namespace = "staff-infra"
  stage     = var.environment

  tags = {
    "business-unit"    = "MoJO"
    "environment-name" = "global"
    "owner"            = var.owner-email
    "application"      = "Infrastructure Monitoring and Alerting"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}
