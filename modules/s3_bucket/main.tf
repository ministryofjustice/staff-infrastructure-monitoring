resource "aws_s3_bucket" "this" {
  bucket = "${var.prefix_pttp}-${var.name}"
  acl    = "private"

  tags = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.this.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_metric" "this" {
  bucket = aws_s3_bucket.this.bucket
  name   = "EntireBucket"
}

resource "aws_kms_key" "this" {
  description = "${var.prefix_pttp}-${var.name} encryption key"
}
