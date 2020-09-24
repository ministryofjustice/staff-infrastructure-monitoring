output "hostname" {
  value = aws_alb.main_grafana.dns_name
}

output "domain" {
  value = aws_route53_record.grafana.name
}
