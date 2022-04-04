resource "aws_acm_certificate" "thanos_receiver" {
  domain_name       = "thanos-secure-${var.env}.${var.vpn_hosted_zone_domain}"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}