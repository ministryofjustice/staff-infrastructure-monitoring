locals {
  any_cloudwatch_exporter_roles = length(var.cloudwatch_exporter_access_role_arns) > 0
}
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

resource "aws_iam_role_policy" "assume_cross_account_roles" {
  count  = local.any_cloudwatch_exporter_roles && var.is_eks_enabled ? 1 : 0
  role   = module.monitoring_alerting_cluster.worker_iam_role_name
  policy = element(data.aws_iam_policy_document.assume_cross_account_roles.*.json, 0)
}

data "aws_iam_policy_document" "assume_cross_account_roles" {
  count = local.any_cloudwatch_exporter_roles && var.is_eks_enabled ? 1 : 0
  statement {
    actions   = ["sts:AssumeRole"]
    resources = var.cloudwatch_exporter_access_role_arns
  }
}
