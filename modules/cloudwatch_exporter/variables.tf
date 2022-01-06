variable "production_account_id" {
  type = string
}

variable "cloudwatch_access_policy_arn" {
  type = string
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}