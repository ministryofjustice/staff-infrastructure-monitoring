resource "aws_iam_role" "shared_services_admin" {
  name = "${module.label.id}-shared-services-admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : var.shared_services_account_arn }
        Condition = {}
    }]
  })
}

resource "aws_iam_policy" "shared_services_admin" {
  name        = "${module.label.id}-shared-services-admin"
  path        = "/"
  description = "Used by the ci to apply changes to this enviroment"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "shared_services_admin" {
  role       = aws_iam_role.shared_services_admin.name
  policy_arn = aws_iam_policy.shared_services_admin.arn
}