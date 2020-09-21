variable "assume_role" {
  type = string
}

variable "owner-email" {
  type    = string
  default = "pttp@justice.gov.uk"
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

variable "grafana_db_backup_retention_period" {
  type    = number
  default = 7
}