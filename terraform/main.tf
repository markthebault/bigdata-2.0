locals {
  name = "simple-api"
}

module "lambda_auth" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-authorizer"
  runtime       = "nodejs8.10"
  handler       = "lambda_authorizer.handler"

  source_path = "${path.module}/lambdas/lambda_authorizer"
}

module "lambda_api" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-route"
  runtime       = "nodejs8.10"
  handler       = "api_lambda.handler"

  source_path = "${path.module}/lambdas/api_lambda.js"
}

module "api_gw" {
  source = "modules/apigw"

  apigw_name                    = "apigw-${local.name}"
  lambda_authorizer_arn         = "${module.lambda_auth.function_arn}"
  lambda_authorizer_invoked_arn = "${module.lambda_auth.function_invoke_arn}"
}

module "api_gw_resource" {
  source = "modules/apigw-resources"

  apigw_api_id                        = "${module.api_gw.apigw_api_id}"
  apigw_method_root_proxy_resource_id = "${module.api_gw.apigw_method_root_proxy_resource_id}"
  apigw_method_root_proxy_http_method = "${module.api_gw.apigw_method_root_proxy_http_method}"
  apigw_method_proxy_resource_id      = "${module.api_gw.apigw_method_proxy_resource_id}"
  apigw_method_proxy_http_method      = "${module.api_gw.apigw_method_proxy_http_method}"
  lambda_apigw_arn                    = "${module.lambda_api.function_arn}"

  lambda_apigw_invoked_arn = "${module.lambda_api.function_invoke_arn}"
}
