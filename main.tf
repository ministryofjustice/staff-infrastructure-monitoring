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

provider "grafana" {
  url  = var.grafana_url
  auth = "${var.grafana_admin_username}:${var.grafana_admin_password}"
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


