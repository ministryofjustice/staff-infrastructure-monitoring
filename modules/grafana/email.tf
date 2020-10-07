resource "aws_ses_domain_identity" "grafana_email" {
  domain = var.vpn_hosted_zone_domain
}

resource "aws_route53_record" "grafana_email_amazonses_verification_record" {
  zone_id = var.vpn_hosted_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.grafana_email.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.grafana_email.verification_token]
}

resource "aws_ses_domain_identity_verification" "grafana_email_verification" {
  domain = aws_ses_domain_identity.grafana_email.id

  depends_on = [aws_route53_record.grafana_email_amazonses_verification_record]
}

resource "aws_ses_domain_mail_from" "grafana_email_from" {
  domain           = aws_ses_domain_identity.grafana_email.domain
  mail_from_domain = "${var.domain_prefix}.${aws_ses_domain_identity.grafana_email.domain}"
}

resource "aws_route53_record" "grafana_email_ses_domain_mail_from_mx" {
  zone_id = var.vpn_hosted_zone_id
  name    = aws_ses_domain_mail_from.grafana_email_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

resource "aws_route53_record" "grafana_email_ses_domain_mail_from_txt" {
  zone_id = var.vpn_hosted_zone_id
  name    = aws_ses_domain_mail_from.grafana_email_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
