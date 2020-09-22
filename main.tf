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
  version = "~> 2.68"
  profile = terraform.workspace

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
    "is-production"    = var.is-production
    "application"      = "Infrastructure Monitoring and Alerting"
    "source-code"      = "https://github.com/ministryofjustice/staff-infrastructure-monitoring"
  }
}

module "monitoring_platform" {
  source = "./modules/monitoring_platform"

  prefix = module.label.id
  tags   = module.label.tags

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

  prefix             = module.label.id
  tags               = module.label.tags
  vpc                = module.monitoring_platform.vpc_id
  execution_role_arn = module.monitoring_platform.execution_role_arn
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids
  cluster_id         = module.monitoring_platform.cluster_id

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter" {
  source = "./modules/snmp_exporter"

  prefix             = module.label.id
  tags               = module.label.tags
  vpc                = module.monitoring_platform.vpc_id
  task_role_arn      = module.monitoring_platform.task_role_arn
  execution_role_arn = module.monitoring_platform.execution_role_arn
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids
  cluster_id         = module.monitoring_platform.cluster_id

  providers = {
    aws = aws.env
  }
}
