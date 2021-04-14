output "assume_role_arn" {
  value = aws_iam_role.cloudwatch_exporter_assume_role.arn
}