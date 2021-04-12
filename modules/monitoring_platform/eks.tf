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
