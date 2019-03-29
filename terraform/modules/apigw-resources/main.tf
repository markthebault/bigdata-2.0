## DEPLOY Route
resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id = "${var.apigw_api_id}"
  resource_id = "${var.apigw_method_proxy_resource_id}"
  http_method = "${var.apigw_method_proxy_http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_apigw_invoked_arn}"
}

resource "aws_api_gateway_integration" "api_integration_root" {
  rest_api_id = "${var.apigw_api_id}"
  resource_id = "${var.apigw_method_root_proxy_resource_id}"
  http_method = "${var.apigw_method_root_proxy_http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_apigw_invoked_arn}"
}

resource "aws_api_gateway_integration" "api_login" {
  rest_api_id = "${var.apigw_api_id}"
  resource_id = "${var.apigw_method_login_resource_id}"
  http_method = "${var.apigw_method_login_http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_apigw_login_invoked_arn}"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.api_login",
    "aws_api_gateway_integration.api_integration",
    "aws_api_gateway_integration.api_integration_root",
  ]

  rest_api_id = "${var.apigw_api_id}"
  stage_name  = "api"
}

resource "aws_lambda_permission" "api_lambda_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_apigw_arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_deployment.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_Login_lambda_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_apigw_login_arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_deployment.execution_arn}/*/*"
}
