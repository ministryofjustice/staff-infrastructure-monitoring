resource "aws_route53_record" "grafana" {
  type           = "A"
  zone_id        = var.vpn_hosted_zone_id
  name           = "${var.domain_prefix}.${var.vpn_hosted_zone_domain}"

  alias {
    name                   = aws_alb.main_grafana.dns_name
    zone_id                = aws_alb.main_grafana.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "grafana_verification" {
  ttl     = 3600
  zone_id = var.vpn_hosted_zone_id

  name    = tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.grafana.domain_validation_options)[0].resource_record_value]
}
