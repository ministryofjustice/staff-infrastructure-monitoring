terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.0"
    }
  }
}

locals {
  attach_policy = var.attach_elb_log_delivery_policy || var.attach_policy || var.is_production
}

resource "aws_s3_bucket" "encrypted" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = "${var.prefix_pttp}-${var.name}"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
      versioning,
      logging,
      acl
    ]
  }
}

# resource "aws_s3_bucket_acl" "encrypted" {
#   bucket = "${var.prefix_pttp}-${var.name}"
#   acl    = var.acl
# }

resource "aws_s3_bucket_logging" "encrypted_logging" {
  count  = 0
  bucket = "${var.prefix_pttp}-${var.name}"

  target_bucket = var.target_bucket
  target_prefix = "logs/${var.name}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_s3" {
  count  = 0
  bucket = "${var.prefix_pttp}-${var.name}"

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# resource "aws_s3_bucket_versioning" "versioning_encrypted" {
#   bucket = "${var.prefix_pttp}-${var.name}"
#   versioning_configuration {
#     status = var.versioning_status
#   }
# }


resource "aws_s3_bucket" "non-encrypted" {
  count  = var.encryption_enabled ? 0 : 1
  bucket = "${var.prefix_pttp}-${var.name}"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      versioning,
      logging,
      acl
    ]
  }
}

# resource "aws_s3_bucket_acl" "non-encrypted" {
#   bucket = "${var.prefix_pttp}-${var.name}"
#   acl    = var.acl
# }

resource "aws_s3_bucket_logging" "non_encrypted_logging" {
  count  = 0
  bucket = "${var.prefix_pttp}-${var.name}"

  target_bucket = var.target_bucket
  target_prefix = "logs/${var.name}"
}

# resource "aws_s3_bucket_versioning" "versioning_non_encrypted" {
#   bucket = "${var.prefix_pttp}-${var.name}"
#   versioning_configuration {
#     status = var.versioning_status
#   }
# }

resource "aws_s3_bucket_metric" "encrypted" {
  count  = 0
  bucket = aws_s3_bucket.encrypted[0].bucket
  name   = "EntireBucket"
}

resource "aws_s3_bucket_metric" "non-encrypted" {
  count  = 0
  bucket = aws_s3_bucket.non-encrypted[0].bucket
  name   = "EntireBucket"
}


# resource "aws_kms_key" "this" {
#   count       = var.encryption_enabled ? 1 : 0
#   description = "${var.prefix_pttp}-${var.name} encryption key"
# }


# S3 Bucket Policy

resource "aws_s3_bucket_policy" "this" {
  count = 0

  bucket = var.encryption_enabled ? aws_s3_bucket.encrypted[0].id : aws_s3_bucket.non-encrypted[0].id
  policy = data.aws_iam_policy_document.combined[0].json
}

data "aws_caller_identity" "current" {
}

data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "combined" {
  count = local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.is_production ? (var.override_attach_mfa_delete_policy ? "" : data.aws_iam_policy_document.mfa_delete[0].json) : "",
    var.attach_policy ? var.policy : ""
  ])
}

# Pre-defined ELB Log Delivery Policy

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AllowELBPutObject"

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

# Pre-defined MFA Delete Policy

data "aws_iam_policy_document" "mfa_delete" {
  count = var.is_production ? (var.override_attach_mfa_delete_policy ? 0 : 1) : 0

  statement {
    sid = "DenyDeleteWithoutMFA"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    effect = "Deny"

    actions = [
      "s3:DeleteBucketPolicy",
      "s3:DeleteObjectVersion",
      "s3:PutBucketVersioning"
    ]

    resources = [
      var.encryption_enabled ? "${aws_s3_bucket.encrypted[0].arn}/*" : "${aws_s3_bucket.non-encrypted[0].arn}/*",
      var.encryption_enabled ? aws_s3_bucket.encrypted[0].arn : aws_s3_bucket.non-encrypted[0].arn,
    ]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        "false"
      ]
    }
  }
}
