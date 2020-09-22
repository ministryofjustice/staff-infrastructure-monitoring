variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}
