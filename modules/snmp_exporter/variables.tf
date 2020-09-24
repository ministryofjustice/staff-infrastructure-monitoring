#################### General ####################
variable "aws_region" {
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

variable "fargate_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 9116
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "fargate_count" {
  description = "Number of docker containers to run"
  default     = "1"
}
