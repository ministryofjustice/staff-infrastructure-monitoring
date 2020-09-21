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

module "monitoring_platform" {
  source = "./modules/monitoring_platform"

  prefix                     = module.label.id
  tags                       = module.label.tags

  db_username                = var.grafana_db_username
  db_password                = var.grafana_db_password
  admin_username             = var.grafana_admin_username
  admin_password             = var.grafana_admin_password
  db_backup_retention_period = var.grafana_db_backup_retention_period

  providers = {
    aws = aws.env
  }
}

module "prometheus" {
  source = "./modules/prometheus"

  prefix                     = module.label.id
  tags                       = module.label.tags

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter" {
  source = "./modules/snmp_exporter"

  prefix                     = module.label.id
  tags                       = module.label.tags

  providers = {
    aws = aws.env
  }
}
