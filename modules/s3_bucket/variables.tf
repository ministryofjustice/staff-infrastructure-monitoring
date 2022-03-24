variable "acl" {
  type        = string
  description = "Canned ACL to use"
  default     = "private"
}

variable "encryption_enabled" {
  description = "Controls if S3 bucket should have server-side encryption"
  default     = true
  type        = bool
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "S3 bucket name"
  type        = string
}

variable "prefix_pttp" {
  type = string
}

variable "tags" {
  description = "Map of tags to attach to the bucket"
  type        = map(string)
}

variable "versioning_status" {
  description = "Controls if S3 bucket should have versioning enabled"
  default     = "Enabled"
  type        = string
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have a custom bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  default     = false
  type        = bool
}

variable "override_attach_mfa_delete_policy" {
  description = "Controls if S3 bucket should have MFA Delete (emulated) policy attached"
  type        = bool
  default     = false
}

variable "policy" {
  description = "(Optional) A valid custom bucket policy JSON document."
  type        = string
  default     = null
}

variable "is_production" {
  description = "Enforces Bucket Policy for Production Environments"
  type        = bool
}

variable "kms_key_arn" {
  type = string
}

variable "kms_key_id" {
  type = string
}
