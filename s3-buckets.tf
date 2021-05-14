module "blackbox_exporter_lb_access_logging" {
  source = "./modules/s3_bucket"

  name                           = "blackbox-exporter-lb-access-logging"
  prefix_pttp                    = module.label_pttp.id
  tags                           = module.label_pttp.tags
  versioning_enabled             = false
  encryption_enabled             = false
  attach_elb_log_delivery_policy = true
  is_production                  = var.is-production

  providers = {
    aws = aws.env
  }
}

module "grafana-image-storage" {
  source = "./modules/s3_bucket"

  name               = "grafana-image-storage"
  prefix_pttp        = module.label_pttp.id
  tags               = module.label_pttp.tags
  encryption_enabled = false
  versioning_enabled = false
  is_production      = var.is-production

  logging = {
    target_bucket = module.s3_access_logging.bucket_name
  }

  providers = {
    aws = aws.env
  }
}

module "grafana_lb_access_logging" {
  source = "./modules/s3_bucket"

  name                           = "grafana-lb-access-logging"
  prefix_pttp                    = module.label_pttp.id
  tags                           = module.label_pttp.tags
  versioning_enabled             = false
  encryption_enabled             = false
  attach_elb_log_delivery_policy = true
  is_production                  = var.is-production

  providers = {
    aws = aws.env
  }
}

module "prometheus_lb_access_logging" {
  source = "./modules/s3_bucket"

  name                           = "prometheus-lb-access-logging"
  prefix_pttp                    = module.label_pttp.id
  tags                           = module.label_pttp.tags
  versioning_enabled             = false
  encryption_enabled             = false
  attach_elb_log_delivery_policy = true
  is_production                  = var.is-production

  providers = {
    aws = aws.env
  }
}

module "prometheus-thanos-storage" {
  source = "./modules/s3_bucket"

  name          = "thanos-storage"
  prefix_pttp   = module.label_pttp.id
  tags          = module.label_pttp.tags
  is_production = var.is-production

  logging = {
    target_bucket = module.s3_access_logging.bucket_name
  }

  providers = {
    aws = aws.env
  }
}

module "s3_access_logging" {
  source = "./modules/s3_bucket"

  name               = "s3-access-logging"
  prefix_pttp        = module.label_pttp.id
  tags               = module.label_pttp.tags
  acl                = "log-delivery-write"
  versioning_enabled = false
  is_production      = var.is-production

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter_lb_access_logging" {
  source = "./modules/s3_bucket"

  name                           = "snmp-exporter-lb-access-logging"
  prefix_pttp                    = module.label_pttp.id
  tags                           = module.label_pttp.tags
  versioning_enabled             = false
  encryption_enabled             = false
  attach_elb_log_delivery_policy = true
  is_production                  = var.is-production

  providers = {
    aws = aws.env
  }
}

module "vpc_flow_logging" {
  source = "./modules/s3_bucket"

  name               = "vpc-flow-logging"
  prefix_pttp        = module.label_pttp.id
  tags               = module.label_pttp.tags
  acl                = "log-delivery-write"
  versioning_enabled = false
  is_production      = var.is-production

  providers = {
    aws = aws.env
  }
}

module "grafana_lb_access_logging_v2" {
  source = "./modules/s3_bucket"

  name                              = "grafana-lb-access-logging-v2"
  prefix_pttp                       = module.label_pttp.id
  tags                              = module.label_pttp.tags
  versioning_enabled                = false
  encryption_enabled                = false
  attach_elb_log_delivery_policy    = true
  is_production                     = var.is-production
  override_attach_mfa_delete_policy = true

  providers = {
    aws = aws.env
  }
}

module "prometheus_lb_access_logging_v2" {
  source = "./modules/s3_bucket"

  name                              = "prometheus-lb-access-logging-v2"
  prefix_pttp                       = module.label_pttp.id
  tags                              = module.label_pttp.tags
  versioning_enabled                = false
  encryption_enabled                = false
  attach_elb_log_delivery_policy    = true
  is_production                     = var.is-production
  override_attach_mfa_delete_policy = true

  providers = {
    aws = aws.env
  }
}

module "snmp_exporter_lb_access_logging_v2" {
  source = "./modules/s3_bucket"

  name                              = "snmp-exporter-lb-access-logging-v2"
  prefix_pttp                       = module.label_pttp.id
  tags                              = module.label_pttp.tags
  versioning_enabled                = false
  encryption_enabled                = false
  attach_elb_log_delivery_policy    = true
  is_production                     = var.is-production
  override_attach_mfa_delete_policy = true

  providers = {
    aws = aws.env
  }
}

module "blackbox_exporter_lb_access_logging_v2" {
  source = "./modules/s3_bucket"

  name                              = "blackbox-exporter-lb-access-logging-v2"
  prefix_pttp                       = module.label_pttp.id
  tags                              = module.label_pttp.tags
  versioning_enabled                = false
  encryption_enabled                = false
  attach_elb_log_delivery_policy    = true
  is_production                     = var.is-production
  override_attach_mfa_delete_policy = true

  providers = {
    aws = aws.env
  }
}