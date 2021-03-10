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
  value = element(concat(aws_eks_cluster.monitoring_alerting_cluster[*].endpoint, list("")), 0)
}

output "cluster_certificate" {
  value = base64decode(element(concat(aws_eks_cluster.monitoring_alerting_cluster[*].certificate_authority.0.data, list("")), 0))
}

output "cluster_token" {
  value =  element(concat(data.aws_eks_cluster_auth.monitoring_alerting_cluster[*].token, list("")), 0)
}