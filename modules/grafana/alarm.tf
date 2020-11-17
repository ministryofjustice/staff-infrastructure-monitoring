resource "aws_cloudwatch_metric_alarm" "grafana" {
  alarm_name          = "Monitoring and Alerting platform"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Number of healthy Grafana hosts"

  dimensions = {
    LoadBalancer = aws_alb.main_grafana.arn_suffix
    TargetGroup  = aws_alb_target_group.app_grafana.arn_suffix
  }

  insufficient_data_actions = []
}