resource "aws_s3_bucket" "storage" {
  bucket = "${var.prefix_pttp}-thanos-storage"
  acl    = "private"

  tags = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.storage_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_metric" "storage" {
  bucket = aws_s3_bucket.storage.bucket
  name   = "EntireBucket"
}

resource "aws_kms_key" "storage_key" {
  description             = "${var.prefix_pttp}-thanos-storage encryption key"
}
