module "monitoring_alerting_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.24.0"
  create_eks                      = var.is_eks_enabled
  cluster_name                    = "${var.prefix}-cluster"
  cluster_version                 = "1.21"
  manage_aws_auth                 = false
  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["api", "authenticator", "controllerManager"]
  tags                            = var.tags

  subnets = aws_subnet.private.*.id
  vpc_id  = aws_vpc.main.id

  worker_groups = [
    {
      name                 = "prometheus-worker-group"
      instance_type        = "t3.medium"
      asg_desired_capacity = 4
      root_volume_type     = "gp2"
    },
  ]
}
