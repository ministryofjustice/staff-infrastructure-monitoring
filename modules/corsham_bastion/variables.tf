variable "prefix" {
  type = string
}

variable "vpc" {
  type = string
}

variable "public_subnet_ids" {
  type = list
}

variable "tags" {
  type = map(string)
}