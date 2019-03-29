resource "aws_iam_role" "api_gateway_authorizer_role" {
  name               = "role-${var.apigw_name}-${local.apigw_auth_name}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_authorizer_assume_role.json}"
}

data "aws_iam_policy_document" "lambda_authorizer_assume_role" {
  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_authorizer_invocation_policy" {
  name   = "policy-${var.apigw_name}-${local.apigw_auth_name}-lambda"
  role   = "${aws_iam_role.api_gateway_authorizer_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_authorizer_invocation_policy_document.json}"
}

data "aws_iam_policy_document" "lambda_authorizer_invocation_policy_document" {
  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      "${var.lambda_authorizer_arn}",
    ]
  }
}
