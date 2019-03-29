variable "apigw_api_id" {}
variable "apigw_method_root_proxy_resource_id" {}
variable "apigw_method_root_proxy_http_method" {}
variable "apigw_method_proxy_resource_id" {}
variable "apigw_method_proxy_http_method" {}
variable "lambda_apigw_invoked_arn" {}
variable "lambda_apigw_arn" {}

variable "apigw_gateway_deployment_stage_name" {
  default = "api"
}
