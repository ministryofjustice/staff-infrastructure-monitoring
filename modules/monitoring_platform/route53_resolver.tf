resource "aws_route53_resolver_endpoint" "ima_vpc_outbound" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  name      = "ima-resolver-${var.prefix}"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.route53_resolver.id
  ]

  ip_address {
    subnet_id = aws_subnet.private[0].id
  }

  ip_address {
    subnet_id = aws_subnet.private[1].id
  }

  ip_address {
    subnet_id = aws_subnet.private[2].id
  }
}

resource "aws_route53_resolver_rule" "mojo_dns_rule" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  name                 = "ima-mojo-resolver-rule-${var.prefix}"
  rule_type            = "FORWARD"
  domain_name          = var.gsi_domain
  resolver_endpoint_id = aws_route53_resolver_endpoint.ima_vpc_outbound.*.id[0]

  target_ip {
    ip   = var.mojo_dns_ip_1
    port = "53"
  }

  target_ip {
    ip   = var.mojo_dns_ip_2
    port = "53"
  }
}

resource "aws_route53_resolver_rule" "mojo_dns_rule_internal_vpn" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  name                 = "ima-mojo-resolver-rule-internal-vpn-${var.prefix}"
  rule_type            = "FORWARD"
  domain_name          = "internal.vpn.justice.gov.uk"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ima_vpc_outbound.*.id[0]

  target_ip {
    ip   = var.mojo_dns_ip_1
    port = "53"
  }

  target_ip {
    ip   = var.mojo_dns_ip_2
    port = "53"
  }
}

resource "aws_route53_resolver_rule_association" "ima_mojo_rule_association" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  resolver_rule_id = aws_route53_resolver_rule.mojo_dns_rule.*.id[0]
  vpc_id           = aws_vpc.main.id
}

resource "aws_route53_resolver_rule_association" "ima_mojo_rule_association_internal_vpn" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  resolver_rule_id = aws_route53_resolver_rule.mojo_dns_rule_internal_vpn.*.id[0]
  vpc_id           = aws_vpc.main.id
}

resource "aws_route53_resolver_query_log_config" "ima_mojo_resolver_query_log" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  name            = "ima-resolver-query-log-${var.prefix}"
  destination_arn = aws_cloudwatch_log_group.vpc_flow_log_group.arn
}

resource "aws_route53_resolver_query_log_config_association" "ima_resolver_query_log_association" {
  count = var.enable_ima_dns_resolver ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.ima_mojo_resolver_query_log[0].id
  resource_id                  = aws_vpc.main.id
}
