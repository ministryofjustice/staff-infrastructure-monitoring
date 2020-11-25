resource "aws_cloudwatch_metric_alarm" "grafana" {
  alarm_name          = "${var.prefix}-monitoring-and-alerting-platform"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Number of healthy Grafana hosts"
  alarm_actions       = [aws_sns_topic.grafana-alerts.id]
  treat_missing_data = "breaching"
  dimensions = {
    LoadBalancer = aws_alb.main_grafana.arn_suffix
    TargetGroup  = aws_alb_target_group.app_grafana.arn_suffix
  }

  insufficient_data_actions = []
}
