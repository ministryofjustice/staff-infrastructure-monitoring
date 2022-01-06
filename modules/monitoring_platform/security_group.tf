resource "aws_security_group" "route53_resolver" {
  name        = "${var.prefix}-route53-resolver"
  description = "Allow ingress and egress traffic for route53 resolver"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "dns_1_out" {
  description       = "Allow DNS lookups against the MoJO DNS servers in eu-west-2a"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.route53_resolver.id
  cidr_blocks       = ["${var.mojo_dns_ip_1}/32"]
}

resource "aws_security_group_rule" "dns_2_out" {
  description       = "Allow DNS lookups against the MoJO DNS servers in eu-west-2b"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.route53_resolver.id
  cidr_blocks       = ["${var.mojo_dns_ip_2}/32"]
}
