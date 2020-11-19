output "hostname" {
  value = aws_alb.main_grafana.dns_name
}

output "domain" {
  value = aws_route53_record.grafana.name
}

output "grafana_db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

output "db_in_security_group_id" {
  value = aws_security_group.db_in.id
}