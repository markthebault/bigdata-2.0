locals {
  name                = "simple-api"
  landing_bucket_name = "mth-dlk-landing-bucket"
  dlk_bucket_name     = "mth-dlk-bucket"
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

      DYNAMO_LANDING_TABLE_NAME = "${module.dynamodb_table_dataset_landing.table_name}"
      DYNAMO_DLK_TABLE_NAME     = "${module.dynamodb_table_datalake.table_name}"
      S3_LANDING_BUCKET         = "${local.landing_bucket_name}"
    }
  }

  attach_policy = true

  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "*"
      },
      {
        "Action": [
            "dynamodb:*"
          ],
        "Effect": "Allow",
        "Resource": [
          "${module.dynamodb_table_dataset_landing.table_arn}",
          "${module.dynamodb_table_datalake.table_arn}",
          "${module.dynamodb_table_dataset_landing.table_arn}/*",
          "${module.dynamodb_table_datalake.table_arn}/*"
        ]
      },
      {
        "Action": [
            "sns:*"
          ],
        "Effect": "Allow",
        "Resource": [
          "${module.dlk_sns_topic.sns_topic_arn}"
        ]
      },
      {
        "Action": [
            "sns:*"
          ],
        "Effect": "Allow",
        "Resource": [
          "${module.k8s_sns_topic.sns_topic_arn}"
        ]
      }
    ]
}
JSON
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

module "dynamodb_table_dataset_landing" {
  source    = "git::https://github.com/markthebault/terraform-aws-dynamodb.git?ref=f21f7b9f55fae9c4ffad351b2ab0acd980dab41e"
  namespace = "datalake"
  stage     = "dev"
  name      = "landing_bucket"
  hash_key  = "dataset_key"
  range_key = "uri"

  autoscale_write_target       = 3
  autoscale_read_target        = 3
  autoscale_min_read_capacity  = 1
  autoscale_max_read_capacity  = 5
  autoscale_min_write_capacity = 1
  autoscale_max_write_capacity = 5
  enable_autoscaler            = true
}

module "dynamodb_table_datalake" {
  source    = "git::https://github.com/markthebault/terraform-aws-dynamodb.git?ref=f21f7b9f55fae9c4ffad351b2ab0acd980dab41e"
  namespace = "datalake"
  stage     = "dev"
  name      = "datalake"
  hash_key  = "dataset_key"
  range_key = "uri"

  autoscale_write_target       = 3
  autoscale_read_target        = 3
  autoscale_min_read_capacity  = 1
  autoscale_max_read_capacity  = 5
  autoscale_min_write_capacity = 1
  autoscale_max_write_capacity = 5
  enable_autoscaler            = true
}

module "s3-buckets" {
  source = "modules/s3-dlk-buckets"
  names  = ["${local.landing_bucket_name}", "${local.dlk_bucket_name}"]
}

module "dlk_sns_topic" {
  source = "modules/sns-dlk"

  sns_topic_name      = "sns-dlk-lambda-topic"
  attached_lambda_arn = "${module.lambda_api.function_arn}"
}

# resource "aws_lambda_event_source_mapping" "dlk_sns_topic" {
#   event_source_arn = "${module.dlk_sns_topic.sns_topic_arn}"
#   function_name    = "${module.lambda_api.function_arn}"
# }

