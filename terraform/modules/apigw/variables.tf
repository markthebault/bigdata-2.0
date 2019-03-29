variable "apigw_name" {}

variable "lambda_authorizer_arn" {}

variable "lambda_authorizer_invoked_arn" {}

variable "authorization_cache_ttl" {
  default = 0
}
