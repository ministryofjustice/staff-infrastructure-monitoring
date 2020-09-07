resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "${var.prefix}-cloudwatch-policy"
  policy = data.template_file.cloudwatch_policy.rendered
}

data "template_file" "cloudwatch_policy" {
  template = file("${path.module}/policies/cloudwatch_policy.json")

  vars = {
    log_group_arn = aws_cloudwatch_log_group.cloudwatch_log_group.arn
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "${var.prefix}-cloudwatch-role"
  assume_role_policy = data.template_file.cloudwatch_assume_role_policy.rendered
}

data "template_file" "cloudwatch_assume_role_policy" {
  template = file("${path.module}/policies/cloudwatch_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  # policy_arn = aws_iam_policy.cloudwatch_policy.arn
  role       = aws_iam_role.cloudwatch_role.name
}

