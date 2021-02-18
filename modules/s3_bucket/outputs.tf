output "bucket_arn" {
    value = aws_s3_bucket.this.bucket
}

output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "kms_key_arn" {
    value = aws_kms_key.this.arn
}

output "kms_key_id" {
    value = aws_kms_key.this.key_id
}