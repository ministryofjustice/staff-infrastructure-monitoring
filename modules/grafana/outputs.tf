output "hostname" {
  value = aws_alb.main.dns_name
}

output "prom_hostname" {
  value = aws_alb.main_prometheus.dns_name
}
