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

variable "thanos_image_repository_url" {
  type = string
}

#################### Long-Term S3 Storage ####################

variable "storage_bucket_arn" {
  description = "ARN of the S3 Bucket to be used for long-term storage"
  type        = string
}

variable "storage_key_arn" {
  description = "ARN of the long-term storage S3 Bucket KMS Key"
  type        = string
}

variable "storage_key_id" {
  description = "ID of the long-term storage S3 Bucket KMS Key"
  type        = string
}

################## Load Balancer Access Logging Bucket ####################

variable "lb_access_logging_bucket_name" {
  description = "Load balancer access logging AWS S3 bucket"
  type        = string
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

// This flag can be removed once everying is migrated over to the correct cidr range
// we don't want to run two instances against the same bucket whilst everything is doubled up
variable "enable_compactor" {
  type = string
}
