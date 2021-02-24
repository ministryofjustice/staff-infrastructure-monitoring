resource "aws_s3_bucket" "encrypted" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = "${var.prefix_pttp}-${var.name}"
  acl    = "private"

  tags = var.tags


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.this[0].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


resource "aws_s3_bucket" "non-encrypted" {
  count  = var.encryption_enabled ? 0 : 1
  bucket = "${var.prefix_pttp}-${var.name}"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_metric" "encrypted" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.encrypted[0].bucket
  name   = "EntireBucket"
}

resource "aws_s3_bucket_metric" "non-encrypted" {
  count  = var.encryption_enabled ? 0 : 1
  bucket = aws_s3_bucket.non-encrypted[0].bucket
  name   = "EntireBucket"
}

resource "aws_kms_key" "this" {
  count       = var.encryption_enabled ? 1 : 0
  description = "${var.prefix_pttp}-${var.name} encryption key"
}
