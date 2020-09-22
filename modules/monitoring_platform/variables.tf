# General

variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "fargate_count" {
  description = "Number of docker containers to run"
  default     = "1"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

# User Details

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_backup_retention_period" {
  type        = number
  description = "The days to retain Grafana database backups for"
}

# Images

variable "grafana_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "grafana/grafana:6.5.0"
}

variable "grafana_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "snmp_exporter_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "068084030754.dkr.ecr.eu-west-2.amazonaws.com/pttp-development-ima-snmp-exporter"
}

variable "snmp_exporter_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 9116
}
