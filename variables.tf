variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-2"
}

variable "owner-email" {
  type    = string
  default = "pttp@justice.gov.uk"
}

variable "is-production" {
  type    = string
  default = "true"
}

variable "production_account_id" {
  type = string
}

variable "assume_role" {
  type = string
}

variable "grafana_image_repository_url" {
  type = string
}

variable "grafana_image_renderer_repository_url" {
  type = string
}

variable "grafana_url" {
  type = string
}

variable "grafana_admin_username" {
  type = string
}

variable "grafana_admin_password" {
  type = string
}

variable "grafana_db_name" {
  type = string
}

variable "grafana_db_endpoint" {
  type = string
}

variable "grafana_db_endpoint_v2" {
  type = string
}

variable "grafana_db_username" {
  type = string
}

variable "grafana_db_password" {
  type = string
}

variable "domain_prefix" {
  type = string
}

variable "vpn_hosted_zone_domain" {
  type = string
}

variable "vpn_hosted_zone_id" {
  type = string
}

variable "thanos_image_repository_url" {
  type = string
}

#################### Azure AD ####################
variable "azure_ad_client_id" {
  type = string
}

variable "azure_ad_client_secret" {
  type = string
}

variable "azure_ad_auth_url" {
  type = string
}

variable "azure_ad_token_url" {
  type = string
}

#################### Transit Gateway ####################
variable "enable_transit_gateway" {
  type    = bool
  default = false
}

variable "transit_gateway_id" {
  type = string
}

variable "transit_gateway_route_table_id" {
  type = string
}

#################### SMTP details ####################
variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "sns_subscribers" {
  type = string
}

variable "enable_test_bastion" {
  type    = bool
  default = false
}

variable "bastion_allowed_ingress_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "cloudwatch_exporter_access_role_arns" {
  description = "Cloudwatch exporter role arns for access to metric data"
  type        = string
  default     = ""
}

#################### Route53 details ####################

variable "enable_ima_dns_resolver" {
  type    = bool
  default = false
}

variable "gsi_domain" {
  type = string
}

variable "mojo_dns_ip_1" {
  type = string
}

variable "mojo_dns_ip_2" {
  type = string
}

variable "psn_team_protected_range_1" {
  type = string
}

variable "psn_team_protected_range_1" {
  type = string
}
