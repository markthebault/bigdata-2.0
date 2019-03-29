output "apigw_api_id" {
  value = "${aws_api_gateway_rest_api.example_api.id}"
}

output "apigw_method_login_resource_id" {
  value = "${aws_api_gateway_method.login.resource_id}"
}

output "apigw_method_login_http_method" {
  value = "${aws_api_gateway_method.login.http_method}"
}

output "apigw_method_root_proxy_resource_id" {
  value = "${aws_api_gateway_method.proxy_root.resource_id}"
}

output "apigw_method_root_proxy_http_method" {
  value = "${aws_api_gateway_method.proxy_root.http_method}"
}

output "apigw_method_proxy_resource_id" {
  value = "${aws_api_gateway_method.proxy.resource_id}"
}

output "apigw_method_proxy_http_method" {
  value = "${aws_api_gateway_method.proxy.http_method}"
}
