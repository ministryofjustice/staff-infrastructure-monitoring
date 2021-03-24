module "label_mojo" {
  source          = "./modules/label"
  label_namespace = "mojo"
  owner-email     = var.owner-email
  is-production   = var.is-production
}

module "monitoring_platform_v2" {
  source = "./modules/monitoring_platform"

  prefix = module.label_mojo.id
  tags   = module.label_mojo.tags

  transit_gateway_id             = var.transit_gateway_id
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  vpc_cidr_block             = "10.180.100.0/22"
  private_subnet_cidr_blocks = ["10.180.100.0/25", "10.180.100.128/25", "10.180.101.0/25"]
  public_subnet_cidr_blocks  = ["10.180.102.0/25", "10.180.102.128/25", "10.180.103.0/25"]

  is_eks_enabled = true

  providers = {
    aws = aws.env
  }
}

module "grafana_v2" {
  source = "./modules/grafana"

  aws_region   = var.aws_region
  prefix_pttp  = module.label_mojo.id
  prefix       = module.label_mojo.id
  tags         = module.label_mojo.tags
  short_prefix = module.label_mojo.stage

  vpc                = module.monitoring_platform_v2.vpc_id
  cluster_id         = module.monitoring_platform_v2.cluster_id
  public_subnet_ids  = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids = module.monitoring_platform_v2.private_subnet_ids

  execution_role_arn      = module.monitoring_platform_v2.execution_role_arn
  rds_monitoring_role_arn = module.monitoring_platform_v2.rds_monitoring_role_arn

  db_name        = var.grafana_db_name
  db_endpoint    = var.grafana_db_endpoint_v2
  db_username    = var.grafana_db_username
  db_password    = var.grafana_db_password
  admin_username = var.grafana_admin_username
  admin_password = var.grafana_admin_password

  vpn_hosted_zone_id     = var.vpn_hosted_zone_id
  vpn_hosted_zone_domain = var.vpn_hosted_zone_domain
  domain_prefix          = "${var.domain_prefix}-v2"

  azure_ad_auth_url      = var.azure_ad_auth_url
  azure_ad_token_url     = var.azure_ad_token_url
  azure_ad_client_id     = var.azure_ad_client_id
  azure_ad_client_secret = var.azure_ad_client_secret

  smtp_user     = var.smtp_user
  smtp_password = var.smtp_password

  sns_subscribers = split(",", var.sns_subscribers)

  storage_bucket_arn = module.grafana-image-storage.bucket_arn

  providers = {
    aws = aws.env
  }
}

module "prometheus_v2" {
  source = "./modules/prometheus"

  enable_compactor = "true"

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label_mojo.id
  tags        = module.label_mojo.tags

  vpc                = module.monitoring_platform_v2.vpc_id
  cluster_id         = module.monitoring_platform_v2.cluster_id
  public_subnet_ids  = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids = module.monitoring_platform_v2.private_subnet_ids
  fargate_count      = 1

  execution_role_arn = module.monitoring_platform_v2.execution_role_arn

  thanos_image_repository_url = var.thanos_image_repository_url

  storage_bucket_arn = module.prometheus-thanos-storage.bucket_arn
  storage_key_arn    = module.prometheus-thanos-storage.kms_key_arn
  storage_key_id     = module.prometheus-thanos-storage.kms_key_id

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter_v2" {
  source = "./modules/snmp_exporter"

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label_mojo.id
  tags        = module.label_mojo.tags

  vpc                = module.monitoring_platform_v2.vpc_id
  cluster_id         = module.monitoring_platform_v2.cluster_id
  public_subnet_ids  = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids = module.monitoring_platform_v2.private_subnet_ids

  execution_role_arn = module.monitoring_platform_v2.execution_role_arn

  providers = {
    aws = aws.env
  }
}

module "blackbox_exporter_v2" {
  source = "./modules/blackbox_exporter"

  aws_region  = var.aws_region
  prefix_pttp = module.label_mojo.id
  prefix      = module.label_mojo.id
  tags        = module.label_mojo.tags

  vpc                = module.monitoring_platform_v2.vpc_id
  cluster_id         = module.monitoring_platform_v2.cluster_id
  public_subnet_ids  = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids = module.monitoring_platform_v2.private_subnet_ids

  execution_role_arn = module.monitoring_platform_v2.execution_role_arn

  providers = {
    aws = aws.env
  }
}
