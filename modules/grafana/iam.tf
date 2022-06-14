resource "aws_iam_role" "task_role" {
  name               = "${var.prefix_pttp}-grafana-task-role"
  assume_role_policy = file("${path.module}/policies/task_assume_role_policy.json")

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_read_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.task_role.name
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "${var.prefix_pttp}-grafana-s3-access"

  policy = templatefile("${path.module}/policies/s3_access_policy.template.json", {
    bucket = var.storage_bucket_name
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.task_role.name
}

resource "aws_iam_user" "cloudwatch_datasource_user" {
  name = "${var.prefix_pttp}-cloudwatch-datasource-user"

  tags = var.tags
}

resource "aws_iam_user_policy" "cloudwatch_datasource_access_policy" {
  policy = file("${path.module}/policies/cloudwatch_metrics_and_logs.json")
  user   = aws_iam_user.cloudwatch_datasource_user.name
}


