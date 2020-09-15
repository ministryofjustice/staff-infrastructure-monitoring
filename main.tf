terraform {
  required_version = "> 0.12.0"

  backend "s3" {
    region     = "eu-west-2"
    bucket     = "pttp-ci-infrastructure-ima-client-core-tf-state"
    lock_table = "pttp-ci-infrastructure-ima-client-core-tf-lock-table"
  }
}

provider "aws" {
  version = "~> 2.68"
  alias   = "env"
  assume_role {
    role_arn = var.assume_role
  }
}

module "label" {
  version = "0.16.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  namespace = "pttp"
  name      = "IMA"
  stage     = terraform.workspace

  tags = {
    "business-unit"    = "MoJO"
    "application"      = "Infrastructure Monitoring and Alerting"
    "owner"            = var.owner-email
    "environment-name" = "global"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}

module "grafana" {
  source = "./modules/grafana"

  prefix                     = module.label.id
  admin_password             = var.grafana_admin_password
  db_username                = var.grafana_db_username
  db_password                = var.grafana_db_password
  db_backup_retention_period = var.grafana_db_backup_retention_period
  tags                       = module.label.tags

  app_count = 2

  providers = {
    aws = aws.env
  }
}
