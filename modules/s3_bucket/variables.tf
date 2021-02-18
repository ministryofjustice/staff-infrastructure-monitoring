variable "name" {
  description = "S3 bucket name"
  type = string
}

variable "prefix_pttp" {
  type = string
}

variable "tags" {
  type = map(string)
}
