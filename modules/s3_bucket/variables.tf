variable "acl" {
  type = string
  description = "Canned ACL to use"
  default = "private"
}

variable "encryption_enabled" {
  description = "Boolean for enabling server-side encryption"
  default     = true
  type        = bool
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "mfa_delete_enabled" {
  default = false
  type    = bool
}

variable "name" {
  description = "S3 bucket name"
  type        = string
}

variable "prefix_pttp" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "versioning_enabled" {
  default = true
  type    = bool
}
