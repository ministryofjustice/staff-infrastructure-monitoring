variable "encryption_enabled" {
  description = "Boolean for enabling server-side encryption"
  default     = true
  type        = bool
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
