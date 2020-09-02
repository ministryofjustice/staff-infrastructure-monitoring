terraform {
  required_version = "> 0.12.23"
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.52"
  profile = terraform.workspace
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.16.0"

  namespace = "pttp"
  stage     = terraform.workspace
  name      = "monitoring"
  delimiter = "-"

  tags = {
    "business-unit" = "MoJO"
    "application"   = "monitoring-and-alerting",
    "is-production" = tostring(var.is-production),
    "owner"         = var.owner-email

    "environment-name" = "global"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}
