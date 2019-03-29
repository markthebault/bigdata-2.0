resource "aws_iam_role" "group_role" {
  name = "role-cognito-group-${var.cognito_group_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${var.cognito_user_pool_id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_cognito_user_group" "main" {
  name         = "${var.cognito_group_name}"
  user_pool_id = "${var.cognito_user_pool_id}"
  role_arn     = "${aws_iam_role.group_role.arn}"
}

resource "aws_iam_policy" "policy" {
  count = "${var.cognito_additional_policy ? 1 : 0}"
  name  = "policy-additional-cognito-group-${var.cognito_group_name}"

  policy = "${var.cognitor_group_additional_policy}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  count      = "${var.cognito_additional_policy ? 1 : 0}"
  name       = "test-attachment"
  roles      = ["${aws_iam_role.group_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}
