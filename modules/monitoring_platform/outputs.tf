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
  value = module.monitoring_alerting_cluster.worker_iam_role_arn
}
