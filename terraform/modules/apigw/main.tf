resource "aws_api_gateway_rest_api" "example_api" {
  name = "${var.apigw_name}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "login" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  path_part   = "login"
}

resource "aws_api_gateway_method" "login" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_resource.login.id}"
  http_method = "POST"

  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "ANY"

  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api_gateway_lambda_authorizer.id}"

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  http_method = "ANY"

  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api_gateway_lambda_authorizer.id}"
}

## AUTH
resource "aws_api_gateway_authorizer" "api_gateway_lambda_authorizer" {
  name                             = "${var.apigw_name}-${local.apigw_auth_name}"
  rest_api_id                      = "${aws_api_gateway_rest_api.example_api.id}"
  authorizer_uri                   = "${var.lambda_authorizer_invoked_arn}"
  authorizer_credentials           = "${aws_iam_role.api_gateway_authorizer_role.arn}"
  type                             = "TOKEN"
  authorizer_result_ttl_in_seconds = "${var.authorization_cache_ttl}"
}
