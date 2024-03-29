variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "3"
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "is_production" {
  type    = bool
  default = false
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

variable "byoip_pool_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
}

variable "network_services_cidr_block" {
  type = string
}

variable "is_eks_enabled" {
  type    = bool
  default = false
}

variable "storage_bucket_name" {
  type    = string
  default = ""
}

variable "storage_bucket_arn" {
  type    = string
  default = ""
}

variable "storage_key_arn" {
  description = "ARN of the long-term storage S3 Bucket KMS Key"
  type        = string
}


variable "vpc_flow_log_bucket_arn" {
  type = string
}

variable "cloudwatch_exporter_access_role_arns" {
  description = "Cloudwatch exporter role arns for access to metric data"
  type        = set(string)
  default     = []
}

variable "enable_ima_dns_resolver" {
  type = bool
}

variable "gsi_domain" {
  type = string
}

variable "mojo_dns_ip_1" {
  type = string
}

variable "mojo_dns_ip_2" {
  type = string
}

variable "dom1_dns_range_1" {
  type = string
}

variable "dom1_dns_range_2" {
  type = string
}

variable "quantum_dns_range_1" {
  type = string
}

variable "quantum_dns_range_2" {
  type = string
}

variable "quantum_dns_ip_1" {
  type = string
}

variable "quantum_dns_ip_2" {
  type = string
}

variable "psn_team_protected_range_1" {
  type = string
}

variable "psn_team_protected_range_2" {
  type = string
}

variable "sop_oci_range" {
  type = string
}

variable "farnborough_5260_ip" {
  type = string
}

variable "corsham_5260_ip" {
  type = string
}

variable "corsham_mgmt_range" {
  type = string
}

variable "farnborough_mgmt_range" {
  type = string
}

