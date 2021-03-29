module "monitoring_alerting_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "14.0.0"
  create_eks                      = var.is_eks_enabled
  cluster_name                    = "${var.prefix}-cluster"
  cluster_version                 = "1.19"
  manage_aws_auth                 = false
  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["api", "authenticator", "controllerManager"]

  subnets = concat(aws_subnet.private.*.id, aws_subnet.public.*.id)
  vpc_id  = aws_vpc.main.id

  worker_groups = [
    {
      name                 = "prometheus-worker-group"
      instance_type        = "t3.medium"
      asg_desired_capacity = 3
      root_volume_type     = "gp2"
    },
  ]
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
  name = "${var.prefix_pttp}-thanos-prometheus-kms-policy"

  policy = templatefile("${path.module}/policies/kms_access_policy.template.json", {
    kms_key_arn = var.storage_key_arn
  })
}

resource "aws_iam_role_policy_attachment" "kms_access_policy_attachment" {
  policy_arn = aws_iam_policy.kms_access_policy.arn
  role       = module.monitoring_alerting_cluster.worker_iam_role_name
  count      = var.is_eks_enabled ? 1 : 0
}