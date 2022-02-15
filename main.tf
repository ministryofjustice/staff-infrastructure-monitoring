terraform {
  backend "s3" {
    region     = "eu-west-2"
    bucket     = "pttp-ci-infrastructure-ima-client-core-tf-state"
    lock_table = "pttp-ci-infrastructure-ima-client-core-tf-lock-table"
  }
}

provider "aws" {
  region  = var.aws_region
  alias   = "env"
  profile = terraform.workspace

  assume_role {
    role_arn = var.assume_role
  }
}

locals {
  vpc_cidr_range = "10.180.100.0/22"
}
provider "grafana" {
  url  = var.grafana_url
  auth = "${var.grafana_admin_username}:${var.grafana_admin_password}"
}

resource "aws_route53_zone" "internal" {
  name = terraform.workspace == "production" ? "mojo-ima.internal.justice.gov.uk" : "${module.label_mojo.id}.${"internal.justice.gov.uk"}"

  vpc {
    vpc_id = module.monitoring_platform_v2.vpc_id
  }

  tags = module.label_mojo.tags

  provider = aws.env
}

module "label_pttp" {
  source          = "./modules/label"
  label_namespace = "pttp"
  owner-email     = var.owner-email
  is-production   = var.is-production
  label_status    = "pre CIDR change infrastructure"
}

module "label" {
  source          = "./modules/label"
  label_namespace = "staff-infra"
  owner-email     = var.owner-email
  is-production   = var.is-production
}

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

  vpc_cidr_block              = local.vpc_cidr_range
  private_subnet_cidr_blocks  = [for cidr_block in cidrsubnets("10.180.100.0/22", 2, 2, 2) : cidrsubnets(cidr_block, 1, 1)[0]]
  public_subnet_cidr_blocks   = [for cidr_block in cidrsubnets("10.180.100.0/22", 2, 2, 2) : cidrsubnets(cidr_block, 1, 1)[1]]
  network_services_cidr_block = "10.180.104.0/22"

  is_eks_enabled = true
  is_production  = var.is-production == "true"

  storage_bucket_arn  = module.prometheus-thanos-storage.bucket_arn
  storage_bucket_name = module.prometheus-thanos-storage.bucket_name
  storage_key_arn     = module.prometheus-thanos-storage.kms_key_arn

  vpc_flow_log_bucket_arn = module.vpc_flow_logging.bucket_arn

  cloudwatch_exporter_access_role_arns = compact(split(",", trimspace(var.cloudwatch_exporter_access_role_arns)))

  enable_ima_dns_resolver    = var.enable_ima_dns_resolver
  gsi_domain                 = var.gsi_domain
  mojo_dns_ip_1              = var.mojo_dns_ip_1
  mojo_dns_ip_2              = var.mojo_dns_ip_2
  psn_team_protected_range_1 = var.psn_team_protected_range_1
  psn_team_protected_range_2 = var.psn_team_protected_range_2
  sop_oci_range              = var.sop_oci_range
  farnborough_5260_ip        = var.farnborough_5260_ip
  corsham_5260_ip            = var.corsham_5260_ip  

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
  vpc_cidr_range     = local.vpc_cidr_range
  cluster_id         = module.monitoring_platform_v2.cluster_id
  public_subnet_ids  = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids = module.monitoring_platform_v2.private_subnet_ids

  execution_role_arn      = module.monitoring_platform_v2.execution_role_arn
  rds_monitoring_role_arn = module.monitoring_platform_v2.rds_monitoring_role_arn

  grafana_image_repository_url          = var.grafana_image_repository_url
  grafana_image_renderer_repository_url = var.grafana_image_renderer_repository_url

  db_name        = var.grafana_db_name
  db_endpoint    = var.grafana_db_endpoint_v2
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

  storage_bucket_name = module.grafana-image-storage.bucket_name

  lb_access_logging_bucket_name = module.grafana_lb_access_logging.bucket_name

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

  storage_bucket_name = module.prometheus-thanos-storage.bucket_name
  storage_key_arn     = module.prometheus-thanos-storage.kms_key_arn
  storage_key_id      = module.prometheus-thanos-storage.kms_key_id

  lb_access_logging_bucket_name = module.prometheus_lb_access_logging.bucket_name

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

  vpc                    = module.monitoring_platform_v2.vpc_id
  cluster_id             = module.monitoring_platform_v2.cluster_id
  public_subnet_ids      = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids     = module.monitoring_platform_v2.private_subnet_ids
  vpc_subnet_cidr_blocks = concat(module.monitoring_platform_v2.private_subnet_cidr_blocks, module.monitoring_platform_v2.public_subnet_cidr_blocks)

  execution_role_arn = module.monitoring_platform_v2.execution_role_arn

  lb_access_logging_bucket_name = module.snmp_exporter_lb_access_logging.bucket_name

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

  vpc                    = module.monitoring_platform_v2.vpc_id
  cluster_id             = module.monitoring_platform_v2.cluster_id
  public_subnet_ids      = module.monitoring_platform_v2.public_subnet_ids
  private_subnet_ids     = module.monitoring_platform_v2.private_subnet_ids
  vpc_subnet_cidr_blocks = concat(module.monitoring_platform_v2.private_subnet_cidr_blocks, module.monitoring_platform_v2.public_subnet_cidr_blocks)

  execution_role_arn = module.monitoring_platform_v2.execution_role_arn

  lb_access_logging_bucket_name = module.blackbox_exporter_lb_access_logging.bucket_name

  providers = {
    aws = aws.env
  }
}

module "cloudwatch_exporter" {
  source                       = "./modules/cloudwatch_exporter"
  production_account_id        = var.production_account_id
  prefix                       = module.label_mojo.id
  cloudwatch_access_policy_arn = module.monitoring_platform_v2.cloudwatch_access_policy
  tags                         = module.label_mojo.tags

  providers = {
    aws = aws.env
  }
}

module "test_bastion" {
  source                     = "./modules/test_bastion"
  subnets                    = module.monitoring_platform_v2.public_subnet_ids
  vpc_id                     = module.monitoring_platform_v2.vpc_id
  tags                       = module.label_mojo.tags
  bastion_allowed_ingress_ip = var.bastion_allowed_ingress_ip

  depends_on = [
    module.monitoring_platform_v2
  ]

  providers = {
    aws = aws.env
  }

  count = var.enable_test_bastion == true ? 1 : 0
}
