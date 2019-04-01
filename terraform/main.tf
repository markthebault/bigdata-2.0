locals {
  name = "simple-api"
}

module "cognito_userpools" {
  source = "modules/cognito-userpools"

  cognito_userpools_name = "simple-users"
}

module "lambda_login" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-login"
  runtime       = "nodejs8.10"
  handler       = "lambda_login.handler"

  source_path = "${path.module}/lambdas/lambda_login"

  environment {
    variables {
      COGNITO_USER_POOL   = "${module.cognito_userpools.cognito_user_pool_id}"
      USER_POOL_CLIENT_ID = "${module.cognito_userpools.cognito_client}"
      DEBUG_ENABLED       = "true"
    }
  }
}

module "lambda_auth" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-authorizer"
  runtime       = "nodejs8.10"
  handler       = "lambda_authorizer.handler"

  source_path = "${path.module}/lambdas/lambda_authorizer"

  environment {
    variables {
      COGNITO_USER_POOL = "${module.cognito_userpools.cognito_user_pool_id}"
      DEBUG_ENABLED     = "true"
    }
  }
}

module "lambda_api" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-route"
  runtime       = "nodejs8.10"
  handler       = "datalake_lambda.handler"

  source_path = "${path.module}/lambdas/lambda_datalake"

  environment {
    variables {
      COGNITO_USER_POOL   = "${module.cognito_userpools.cognito_user_pool_id}"
      USER_POOL_CLIENT_ID = "${module.cognito_userpools.cognito_client}"
      DEBUG_ENABLED       = "true"
    }
  }
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
  lambda_apigw_invoked_arn            = "${module.lambda_api.function_invoke_arn}"

  apigw_method_login_http_method = "${module.api_gw.apigw_method_login_http_method}"
  apigw_method_login_resource_id = "${module.api_gw.apigw_method_login_resource_id}"
  lambda_apigw_login_invoked_arn = "${module.lambda_login.function_invoke_arn}"
  lambda_apigw_login_arn         = "${module.lambda_login.function_arn}"
}

module "cognito_dlk_group" {
  source = "modules/cognito-dlk-admin-group"

  cognito_group_name   = "dlk-admin"
  cognito_user_pool_id = "${module.cognito_userpools.cognito_user_pool_id}"

  cognito_additional_policy = true

  cognitor_group_additional_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON
}
