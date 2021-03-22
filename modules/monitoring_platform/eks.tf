data "aws_eks_cluster_auth" "monitoring_alerting_cluster" {
  count = var.is_eks_enabled ? 1 : 0
  name  = module.monitoring_alerting_cluster.cluster_id
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.prefix}-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  count              = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role[0].name
  count      = var.is_eks_enabled ? 1 : 0
}
resource "aws_iam_role_policy_attachment" "service_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role[0].name
  count      = var.is_eks_enabled ? 1 : 0
}

locals {
  map_roles = [
    {
      rolearn  = var.is_eks_enabled ? aws_iam_role.cluster_role[0].arn : ""
      username = var.is_eks_enabled ? aws_iam_role.cluster_role[0].name : ""
      groups   = ["system:masters"]
    },
  ]
}

module "monitoring_alerting_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "10.0.0"
  create_eks                      = var.is_eks_enabled
  cluster_name                    = "${var.prefix}-cluster"
  cluster_version                 = "1.16"
  manage_aws_auth                 = false
  map_roles                       = local.map_roles
  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["api", "authenticator", "controllerManager"]

  subnets = concat(aws_subnet.private.*.id, aws_subnet.public.*.id)
  vpc_id  = aws_vpc.main.id

  worker_groups = [
    {
      name                 = "prometheus-worker-group"
      instance_type        = "t3.small"
      asg_desired_capacity = 2
    },
  ]
}