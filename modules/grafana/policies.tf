resource "aws_iam_role" "grafana_execution_role" {
  name               = "${var.prefix}-grafana-execution-role"
  assume_role_policy = data.template_file.cloudwatch_assume_role_policy.rendered

  tags = var.tags
}

resource "aws_iam_role" "grafana_task_role" {
  name               = "${var.prefix}-grafana-task-role"
  assume_role_policy = data.template_file.cloudwatch_assume_role_policy.rendered

  tags = var.tags
}

data "template_file" "cloudwatch_assume_role_policy" {
  template = file("${path.module}/policies/cloudwatch_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.grafana_execution_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_read_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.grafana_task_role.name
}

resource "aws_iam_role" "rds_monitoring_role" {
  name               = "${var.prefix}-rds-monitoring-role"
  assume_role_policy = file("${path.module}/policies/rds_monitoring_role.json")

  tags = var.tags
}

data "aws_iam_policy" "rds_monitoring_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy_attachment" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = data.aws_iam_policy.rds_monitoring_policy.arn
}
