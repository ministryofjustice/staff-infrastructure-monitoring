variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "public_subnet_ids" {
  type = list
}

variable "private_subnet_ids" {
  type = list
}

variable "cluster_id" {
  type = string
}
