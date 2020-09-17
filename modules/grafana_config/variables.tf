variable "aws_region" {
  description = "The AWS region to create things in."
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

variable "cloudwatch_data_source_name" {
  type = string
}
