resource "aws_route53_record" "grafana" {
  zone_id        = var.vpn_hosted_zone_id
  name           = "staff-infrastructure-${var.short_prefix}-monitoring.${var.vpn_hosted_zone_domain}"
  type           = "A"
  set_identifier = var.aws_region

  alias {
    name                   = aws_alb.main_grafana.dns_name
    zone_id                = aws_alb.main_grafana.zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = "100"
  }
}
