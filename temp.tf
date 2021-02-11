module "label_mojo" {
  version = "0.16.0"
  source  = "cloudposse/label/null"

  delimiter = "-"
  name      = "IMA"
  namespace = "mojo"
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

  prefix = module.label_mojo.id
  tags   = module.label_mojo.tags

  transit_gateway_id             = var.transit_gateway_id
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  vpc_cidr_block             = "10.180.100.0/22"
  private_subnet_cidr_blocks = ["10.180.100.0/25", "10.180.100.128/25", "10.180.101.0/25"]
  public_subnet_cidr_blocks  = ["10.180.102.0/25", "10.180.102.128/25", "10.180.103.0/25"]

  providers = {
    aws = aws.env
  }
}

module "grafana" {
  source = "./modules/grafana"

  aws_region   = var.aws_region
  prefix_pttp  = module.label_mojo.id
  prefix       = module.label.id
  tags         = module.label_mojo.tags
  short_prefix = module.label_mojo.stage

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids

  execution_role_arn      = module.monitoring_platform.execution_role_arn
  rds_monitoring_role_arn = module.monitoring_platform.rds_monitoring_role_arn

  db_name        = var.grafana_db_name
  db_endpoint    = var.grafana_db_endpoint
  db_username    = var.grafana_db_username
  db_password    = var.grafana_db_password
  admin_username = var.grafana_admin_username
  admin_password = var.grafana_admin_password

  vpn_hosted_zone_id     = var.vpn_hosted_zone_id
  vpn_hosted_zone_domain = var.vpn_hosted_zone_domain
  domain_prefix          = var.domain_prefix

  azure_ad_auth_url      = var.azure_ad_auth_url
  azure_ad_token_url     = var.azure_ad_token_url
  azure_ad_client_id     = var.azure_ad_client_id
  azure_ad_client_secret = var.azure_ad_client_secret

  smtp_user     = var.smtp_user
  smtp_password = var.smtp_password

  sns_subscribers = split(",", var.sns_subscribers)

  providers = {
    aws = aws.env
  }
}

module "prometheus" {
  source = "./modules/prometheus"

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label.id
  tags        = module.label_mojo.tags

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids
  fargate_count      = 1

  execution_role_arn = module.monitoring_platform.execution_role_arn

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter" {
  source = "./modules/snmp_exporter"

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label.id
  tags        = module.label_mojo.tags

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

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label.id
  tags        = module.label_mojo.tags

  vpc                = module.monitoring_platform.vpc_id
  cluster_id         = module.monitoring_platform.cluster_id
  public_subnet_ids  = module.monitoring_platform.public_subnet_ids
  private_subnet_ids = module.monitoring_platform.private_subnet_ids

  execution_role_arn = module.monitoring_platform.execution_role_arn

  providers = {
    aws = aws.env
  }
}