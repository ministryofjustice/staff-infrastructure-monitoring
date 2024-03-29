terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.0"
    }
  }
}

resource "aws_iam_role" "cloudwatch_exporter_assume_role" {
  name        = "${var.prefix}-cloudwatch-exporter-prod-assume-role"
  description = "Allows the production root account access to Cloudwatch metrics for the current environment"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${var.production_account_id}:root" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "production_cloudwatch_access_policy_attachment" {
  policy_arn = var.cloudwatch_access_policy_arn
  role       = aws_iam_role.cloudwatch_exporter_assume_role.name
}
