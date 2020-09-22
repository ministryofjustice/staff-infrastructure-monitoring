output "hostname" {
  value = aws_alb.main.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "execution_role_arn" {
  value = aws_iam_role.grafana_execution_role.arn
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "cluster_id" {
  value = aws_ecs_cluster.grafana_ecs_cluster.id
}
