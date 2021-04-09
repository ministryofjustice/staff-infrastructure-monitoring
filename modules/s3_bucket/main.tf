resource "aws_s3_bucket" "encrypted" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = "${var.prefix_pttp}-${var.name}"
  acl    = var.acl

  tags = var.tags

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = "logs/${var.name}"
    }
  }

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.mfa_delete_enabled
  }

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
  acl    = var.acl

  tags = var.tags

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = "logs/${var.name}"
    }
  }

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.mfa_delete_enabled
  }


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

resource "aws_s3_bucket_policy" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  bucket = var.encryption_enabled ? aws_s3_bucket.encrypted[0].id : aws_s3_bucket.non-encrypted[0].id
  policy = data.aws_iam_policy_document.elb_log_delivery[0].json
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${var.encryption_enabled ? aws_s3_bucket.encrypted[0].arn : aws_s3_bucket.non-encrypted[0].arn}/*",
    ]
  }
}