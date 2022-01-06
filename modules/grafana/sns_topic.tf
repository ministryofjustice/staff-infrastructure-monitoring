resource "aws_sns_topic" "grafana-alerts" {
  name = "${var.prefix}-grafana-alerts"

  tags = var.tags
}

locals {
  sns_subscriptions = [for s in var.sns_subscribers : templatefile("${path.module}/sns_subscription.tmpl", {
    email     = s
    topic_arn = aws_sns_topic.grafana-alerts.arn

    # Name must be alphanumeric, unique, but also consistent based on the email address.
    # It also needs to stay under 255 characters.
    name = sha256("${aws_sns_topic.grafana-alerts.name}-${s}")
  })]
}


resource "aws_cloudformation_stack" "email" {
  name = "${aws_sns_topic.grafana-alerts.name}-subscriptions"

  template_body = <<-STACK
  {
    "Resources": {
      ${join(",", sort(local.sns_subscriptions))}
    }
  }

  STACK
}
