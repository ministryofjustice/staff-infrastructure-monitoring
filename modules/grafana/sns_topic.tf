resource "aws_sns_topic" "grafana-alerts" {
  name = "${var.prefix}-grafana-alerts"
}

data "template_file" "email_subscription" {
  count = length(var.sns_subscribers)
  vars = {
    email     = element(var.sns_subscribers, count.index)
    index     = count.index
    topic_arn = aws_sns_topic.grafana-alerts.arn

    # Name must be alphanumeric, unique, but also consistent based on the email address.
    # It also needs to stay under 255 characters.
    name = sha256("${aws_sns_topic.grafana-alerts.name}-${element(var.sns_subscribers, count.index)}")
  }

  template = <<-STACK
  $${jsonencode(name)}: {
    "Type" : "AWS::SNS::Subscription",
    "Properties": {
      "Endpoint": $${jsonencode(email)},
      "Protocol": "email",
      "TopicArn": $${jsonencode(topic_arn)}
    }
  }
  STACK
}

resource "aws_cloudformation_stack" "email" {
  name  = "${aws_sns_topic.grafana-alerts.name}-subscriptions"

  template_body = <<-STACK
  {
    "Resources": {
      ${join(",", sort(data.template_file.email_subscription.*.rendered))}
    }
  }
  STACK
}
