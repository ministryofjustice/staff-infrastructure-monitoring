terraform {
  required_version = "> 0.12.0"

  backend "s3" {
    region     = "eu-west-2"
    key        = "terraform/v1/state"
    bucket     = "pttp-global-monitoring-tf-remote-state"
    lock_table = "pttp-global-monitoring-terrafrom-remote-state-lock-dynamo"
  }
}

provider "aws" {
  version = "~> 2.52"
}

module "label" {
  version = "0.16.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  namespace = "pttp"
  name      = "IMA"
  stage     = terraform.workspace

  tags = {
    "business-unit" = "MoJO"
    "application"   = "Infrastructure Monitoring and Alerting"
    "owner"         = var.owner-email
    "environment-name" = "global"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}

module "grafana" {
  source = "./modules/grafana"

  prefix = module.label.id
  admin_password = var.grafana_admin_password
}
