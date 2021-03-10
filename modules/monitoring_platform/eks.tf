data "aws_eks_cluster_auth" "monitoring_alerting_cluster" {
  count = var.is_eks_enabled ? 1 : 0
  name  = module.monitoring_alerting_cluster.cluster_id
}

module "monitoring_alerting_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "10.0.0"
  create_eks      = var.is_eks_enabled
  cluster_name    = "${var.prefix}-cluster"
  cluster_version = "1.15"


  subnets = aws_subnet.private.*.id
  vpc_id  = aws_vpc.main.id

  worker_groups = [
    {
      name                 = "prometheus-worker-group"
      instance_type        = "t3.small"
      asg_desired_capacity = 2
    },
  ]
}