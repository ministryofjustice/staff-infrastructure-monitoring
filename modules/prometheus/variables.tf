#################### General ####################
variable "aws_region" {
  type = string
}

variable "prefix_pttp" {
  type = string
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc" {
  type = string
}

variable "cluster_id" {
  type = string
}

#################### Networking ####################
variable "public_subnet_ids" {
  type = list
}

variable "private_subnet_ids" {
  type = list
}

#################### Fargate ####################
variable "execution_role_arn" {
  type = string
}

variable "fargate_count" {
  description = "Number of docker containers to run"
}
