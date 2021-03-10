data "aws_eks_cluster_auth" "monitoring_alerting_cluster" {
  count = var.is_eks_enabled ? 1 : 0
  name = element(concat(aws_eks_cluster.monitoring_alerting_cluster[*].name, list("")), 0)
}
resource "aws_eks_cluster" "monitoring_alerting_cluster" {
  name     = "${var.prefix}-cluster"
  role_arn = aws_iam_role.cluster_role[0].arn

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.service_role_policy_attachment,
  ]

  count = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_role" "cluster_role" {
  name = "${var.prefix}-cluster-role"

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

  count = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role[0].name
  count      = var.is_eks_enabled ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "service_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role[0].name
  count      = var.is_eks_enabled ? 1 : 0
}