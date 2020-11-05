variable "environment" {
  type = string
}

variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-2"
}

variable "owner-email" {
  type    = string
  default = "pttp@justice.gov.uk"
}

variable "grafana_db_username" {
  type = string
}

variable "grafana_db_password" {
  type = string
}

variable "grafana_db_subnet_group_name" {
  type = string
}

variable "grafana_db_in_security_group_id" {
  type = string
}

variable "rds_monitoring_role_arn" {
  type = string
}
