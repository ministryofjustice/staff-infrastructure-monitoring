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

variable "assume_role" {
  type = string
}

variable "grafana_admin_username" {
  type = string
}

variable "grafana_admin_password" {
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
