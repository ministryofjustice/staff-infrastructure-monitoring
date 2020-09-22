output "hostname" {
  value = aws_alb.main_grafana.dns_name
}
