resource "aws_route53_record" "grafana" {
  type           = "A"
  set_identifier = var.aws_region
  zone_id        = var.vpn_hosted_zone_id
  name           = "staff-infrastructure-${var.short_prefix}-monitoring.${var.vpn_hosted_zone_domain}"

  alias {
    evaluate_target_health = true
    zone_id                = aws_alb.main_grafana.zone_id
    name                   = aws_alb.main_grafana.dns_name
  }

  weighted_routing_policy {
    weight = "100"
  }
}

resource "aws_route53_record" "grafana_verification" {
  ttl     = 3600
  zone_id = var.vpn_hosted_zone_id

  name    = tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_value]
}