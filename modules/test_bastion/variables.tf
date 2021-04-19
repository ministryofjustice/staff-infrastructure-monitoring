variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "bastion_allowed_ingress_ip" {
  type = string
  default = "0.0.0.0"
}
