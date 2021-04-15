
resource "aws_iam_policy" "s3_access_policy" {
  name = "${var.prefix}-thanos-worker-policy"

  policy = templatefile("${path.module}/policies/s3_access_policy.template.json", {
    bucket = var.storage_bucket_arn
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = module.monitoring_alerting_cluster.worker_iam_role_name
  count      = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_policy" "kms_access_policy" {
  name = "${var.prefix}-thanos-prometheus-kms-policy"

  policy = templatefile("${path.module}/policies/kms_access_policy.template.json", {
    kms_key_arn = var.storage_key_arn
  })
}

resource "aws_iam_role_policy_attachment" "kms_access_policy_attachment" {
  policy_arn = aws_iam_policy.kms_access_policy.arn
  role       = module.monitoring_alerting_cluster.worker_iam_role_name
  count      = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_policy" "cloudwatch_access_eks_policy" {
  name = "${var.prefix}-cloudwatch-access-eks-policy"

  policy = templatefile("${path.module}/policies/cloudwatch_access_policy.template.json", {})
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access_eks_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_access_eks_policy.arn
  role       = module.monitoring_alerting_cluster.worker_iam_role_name
  count      = var.is_eks_enabled ? 1 : 0
}

data "aws_iam_role" "production_role" {
  count = var.is_production && var.is_eks_enabled ? 1 : 0
  name  = "mojo-production-ima-cloudwatch-exporter-production-assume-role"
}

data "aws_iam_role" "pre_production_role" {
  count = var.is_production && var.is_eks_enabled ? 1 : 0
  name  = "mojo-pre-production-ima-cloudwatch-exporter-production-assume-role"
}

data "aws_iam_role" "development_role" {
  count = var.is_production && var.is_eks_enabled ? 1 : 0
  name  = "mojo-development-ima-cloudwatch-exporter-production-assume-role"
}

resource "aws_iam_role_policy" "assume_cross_account_roles" {
  count  = var.is_production && var.is_eks_enabled ? 1 : 0
  role   = module.monitoring_alerting_cluster.worker_iam_role_name
  policy = element(data.aws_iam_policy_document.assume_cross_account_roles.*.json, 0)
}

data "aws_iam_policy_document" "assume_cross_account_roles" {
  count = var.is_production && var.is_eks_enabled ? 1 : 0

  statement {
    actions   = ["sts:AssumeRole"]
    resources = [data.aws_iam_role.production_role[0].arn]
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = [data.aws_iam_role.pre_production_role[0].arn]
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = [data.aws_iam_role.development_role[0].arn]
  }
}
