#################### General ####################
variable "aws_region" {
  type = string
}

variable "prefix" {
  type = string
}

variable "short_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc" {
  type = string
}

variable "vpn_hosted_zone_domain" {
  type = string
}

variable "vpn_hosted_zone_id" {
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
variable "task_role_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}
variable "host_port" {
  description = "Port exposed by the load balancer for the service"
  default     = 443
}

variable "container_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "fargate_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "grafana/grafana:7.2.0"
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
  default     = "2"
}

#################### Database ####################
variable "db_port" {
  default = 5432
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_backup_retention_period" {
  description = "The days to retain database backups for"
  default     = 7
}

variable "rds_monitoring_role_arn" {
  type = string
}

#################### User details ####################
variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}
