data "aws_eks_cluster_auth" "monitoring_alerting_cluster" {
  count = var.is_eks_enabled ? 1 : 0
  name = module.monitoring_alerting_cluster.cluster_id
}

# This cluster will not be created
module "monitoring_alerting_cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "10.0.0"
  create_eks = var.is_eks_enabled
  cluster_name    = "${var.prefix}-cluster"
  cluster_version = "1.14"


  subnets         = aws_subnet.private.*.id
  vpc_id = aws_vpc.main.id

  worker_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 2
    }
  ]
}