module "monitoring_alerting_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.30.2"
  create                          = var.is_eks_enabled
  cluster_name                    = "${var.prefix}-cluster"
  cluster_version                 = "1.21"
  manage_aws_auth_configmap       = false
  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["api", "authenticator", "controllerManager"]
  tags                            = var.tags

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private.*.id
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  create = var.is_eks_enabled

  name                     = "${var.prefix}-eks-mng"
  iam_role_use_name_prefix = false
  cluster_name             = module.monitoring_alerting_cluster.cluster_id
  cluster_version          = module.monitoring_alerting_cluster.cluster_version

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private.*.id

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = module.monitoring_alerting_cluster.cluster_primary_security_group_id
  cluster_security_group_id         = module.monitoring_alerting_cluster.node_security_group_id

  min_size     = 4
  max_size     = 5
  desired_size = 4

  instance_types = ["t3.medium"]

  tags = var.tags
}
