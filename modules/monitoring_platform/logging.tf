data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_log_role" {
  name               = "${var.prefix}-flow-log"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = var.tags

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.prefix}-flow-log"
  role = aws_iam_role.flow_log_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = "${var.prefix}-vpc-flow-log-group"

  retention_in_days = 7
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}
