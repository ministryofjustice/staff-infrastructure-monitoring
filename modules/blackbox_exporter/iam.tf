resource "aws_iam_role" "task_role" {
  name               = "${var.prefix_pttp}-blackbox-task-role"
  assume_role_policy = file("${path.module}/policies/task_assume_role_policy.json")

  tags = var.tags
}

resource "aws_iam_policy" "kms_access_policy" {
  name = "${var.prefix_pttp}-blackbox-kms-policy"

  policy = templatefile("${path.module}/policies/kms_access_policy.template.json", {
    kms_key_arn = var.storage_key_arn
  })
}

resource "aws_iam_role_policy_attachment" "kms_access_policy_attachment" {
  policy_arn = aws_iam_policy.kms_access_policy.arn
  role       = aws_iam_role.task_role.name
}
