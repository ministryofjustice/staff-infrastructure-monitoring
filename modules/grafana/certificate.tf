resource "aws_acm_certificate" "grafana" {
  domain_name       = aws_route53_record.grafana.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
