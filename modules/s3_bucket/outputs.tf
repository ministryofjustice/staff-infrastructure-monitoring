output "bucket_arn" {
    value = var.encryption_enabled ? concat(aws_s3_bucket.encrypted.*.bucket, [""])[0] : concat(aws_s3_bucket.non-encrypted.*.bucket, [""])[0]
}

output "bucket_name" {
  value = var.encryption_enabled ? concat(aws_s3_bucket.encrypted.*.id, [""])[0] : concat(aws_s3_bucket.non-encrypted.*.id, [""])[0]
}

output "kms_key_arn" {
   value = concat(aws_kms_key.this.*.arn, [""])[0]
}

output "kms_key_id" {
   value = concat(aws_kms_key.this.*.key_id, [""])[0]
}