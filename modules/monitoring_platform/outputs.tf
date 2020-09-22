output "grafana_hostname" {
  value = aws_alb.grafana.dns_name
}

output "snmp_exporter_hostname" {
  value = aws_alb.snmp_exporter.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "task_role_arn" {
  value = aws_iam_role.cloudwatch_task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.cloudwatch_execution_role.arn
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
