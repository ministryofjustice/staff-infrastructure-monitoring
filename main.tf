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

  transit_gateway_id             = var.transit_gateway_id
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  providers = {
    aws = aws.env
  }
}

module "grafana" {
  source = "./modules/grafana"

  aws_region                 = var.aws_region
  prefix                     = module.label.id
  tags                       = module.label.tags
  short_prefix               = module.label.stage

  vpc                        = module.monitoring_platform.vpc_id
  cluster_id                 = module.monitoring_platform.cluster_id
  public_subnet_ids          = module.monitoring_platform.public_subnet_ids
  private_subnet_ids         = module.monitoring_platform.private_subnet_ids

  task_role_arn              = module.monitoring_platform.task_role_arn
  execution_role_arn         = module.monitoring_platform.execution_role_arn
  rds_monitoring_role_arn    = module.monitoring_platform.rds_monitoring_role_arn

  db_username                = var.grafana_db_username
  db_password                = var.grafana_db_password
  admin_username             = var.grafana_admin_username
  admin_password             = var.grafana_admin_password

  vpn_hosted_zone_id         = var.vpn_hosted_zone_id
  vpn_hosted_zone_domain     = var.vpn_hosted_zone_domain
  domain_prefix              = var.domain_prefix

  azure_ad_auth_url          = var.azure_ad_auth_url
  azure_ad_token_url         = var.azure_ad_token_url
  azure_ad_client_id         = var.azure_ad_client_id
  azure_ad_client_secret     = var.azure_ad_client_secret

  providers = {
    aws = aws.env
  }
}

module "prometheus" {
  source = "./modules/prometheus"

  aws_region         = var.aws_region
  prefix             = module.label.id
  tags               = module.label.tags

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids

  execution_role_arn = module.monitoring_platform.execution_role_arn

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter" {
  source = "./modules/snmp_exporter"

  aws_region         = var.aws_region
  prefix             = module.label.id
  tags               = module.label.tags

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids

  execution_role_arn = module.monitoring_platform.execution_role_arn

  providers = {
    aws = aws.env
  }
}

module "blackbox_exporter" {
  source = "./modules/blackbox_exporter"

  aws_region         = var.aws_region
  prefix             = module.label.id
  tags               = module.label.tags

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids

  execution_role_arn = module.monitoring_platform.execution_role_arn

  providers = {
    aws = aws.env
  }
}
