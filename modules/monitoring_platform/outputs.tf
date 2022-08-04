output "vpc_id" {
  value = aws_vpc.main.id
}

output "task_role_arn" {
  value = aws_iam_role.cloudwatch_task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.cloudwatch_execution_role.arn
}

output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring_role.arn
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.public.*.cidr_block
}

output "private_subnet_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "eks_cluster_id" {
  value = module.monitoring_alerting_cluster.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.monitoring_alerting_cluster.cluster_endpoint
}

output "eks_cluster_worker_iam_role_arn" {
  value = module.eks_managed_node_group.iam_role_arn
}

output "cloudwatch_access_policy" {
  value = aws_iam_policy.cloudwatch_access_eks_policy.arn
}
