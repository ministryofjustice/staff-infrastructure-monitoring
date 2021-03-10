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

output "cluster_endpoint" {
  value = module.monitoring_alerting_cluster.cluster_endpoint
}

output "cluster_certificate" {
  value = module.monitoring_alerting_cluster.cluster_certificate_authority_data
}

output "cluster_token" {
  value =  element(concat(data.aws_eks_cluster_auth.monitoring_alerting_cluster[*].token, list("")), 0)
}