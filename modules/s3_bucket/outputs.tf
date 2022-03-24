output "bucket_arn" {
  value = var.encryption_enabled ? concat(aws_s3_bucket.encrypted.*.arn, [""])[0] : concat(aws_s3_bucket.non-encrypted.*.arn, [""])[0]
}

output "bucket_name" {
  value = var.encryption_enabled ? concat(aws_s3_bucket.encrypted.*.id, [""])[0] : concat(aws_s3_bucket.non-encrypted.*.id, [""])[0]
}

output "kms_key_arn" {
  value = var.kms_key_arn
}

output "kms_key_id" {
  value = var.kms_key_id
}

