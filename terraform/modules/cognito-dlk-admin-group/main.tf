data "aws_caller_identity" "current" {}

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
    },
    {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "sts:AssumeRole",
        "Condition": {}
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

module "dynamodb_table_dataset_landing" {
  source    = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=master"
  namespace = "datalake"
  stage     = "dev"
  name      = "landing_bucket"
  hash_key  = "dataset_key"
  range_key = "metadata"

  autoscale_write_target       = 3
  autoscale_read_target        = 3
  autoscale_min_read_capacity  = 1
  autoscale_max_read_capacity  = 5
  autoscale_min_write_capacity = 1
  autoscale_max_write_capacity = 5
  enable_autoscaler            = true
}

module "dynamodb_table_datalake" {
  source    = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=master"
  namespace = "datalake"
  stage     = "dev"
  name      = "datalake"
  hash_key  = "dataset_key"
  range_key = "metadata"

  autoscale_write_target       = 3
  autoscale_read_target        = 3
  autoscale_min_read_capacity  = 1
  autoscale_max_read_capacity  = 5
  autoscale_min_write_capacity = 1
  autoscale_max_write_capacity = 5
  enable_autoscaler            = true
}
