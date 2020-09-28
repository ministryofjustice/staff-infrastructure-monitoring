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

variable "enable_transit_gateway" {
  type    = bool
  default = false
}

variable "transit_gateway_id" {
  type = string
}

variable "transit_gateway_route_table_id" {
  type = string
}