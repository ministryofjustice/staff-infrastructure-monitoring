resource "aws_iam_role" "task_role" {
  name               = "${var.prefix}-thanos-task-role"
  assume_role_policy = file("${path.module}/policies/task_assume_role_policy.json")

  tags = var.tags
}

resource "aws_iam_policy" "s3_access_policy" {
  name              = "${var.prefix}-thanos-task-policy"

  policy = data.template_file.s3_access_policy.rendered
}

data "template_file" "s3_access_policy" {
  template = file("${path.module}/policies/s3_access_policy.template.json")

  vars ={
      bucket = aws_s3_bucket.storage.bucket
  }
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.task_role.name
}