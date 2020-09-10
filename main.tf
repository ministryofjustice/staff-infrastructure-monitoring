terraform {
  required_version = "> 0.12.0"

  backend "s3" {
    region     = "eu-west-2"
    bucket     = "pttp-ci-infrastructure-ima-client-core-tf-state"
    lock_table = "pttp-ci-infrastructure-ima-client-core-tf-lock-table"
  }
}

provider "aws" {
  alias   = "env"
  version = "~> 2.52"

  assume_role {
    role_arn = var.assume_role
  }
}

module "label" {
  version = "0.16.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  name      = "IMA"
  namespace = "pttp"
  stage     = terraform.workspace

  tags = {
    "business-unit"    = "MoJO"
    "environment-name" = "global"
    "owner"            = var.owner-email
    "application"      = "Infrastructure Monitoring and Alerting"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}

module "grafana" {
  source = "./modules/grafana"

  prefix                     = module.label.id
  tags                       = module.label.tags
  db_username                = var.grafana_db_username
  db_password                = var.grafana_db_password
  admin_username             = var.grafana_admin_username
  admin_password             = var.grafana_admin_password
  db_backup_retention_period = var.grafana_db_backup_retention_period
}
