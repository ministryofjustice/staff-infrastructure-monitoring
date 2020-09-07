variable "is-production" {
  type    = bool
  default = "true"
}

variable "owner-email" {
  type    = string
  default = "pttp@madetech.com"
}

variable "shared_services_account_arn" {
  type = string
}