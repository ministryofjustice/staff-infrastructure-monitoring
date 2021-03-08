resource "aws_eks_cluster" "monitoring_alerting_cluster" {
  name     = "${var.prefix}-cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.service_role_policy_attachment,
  ]
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
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "service_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}