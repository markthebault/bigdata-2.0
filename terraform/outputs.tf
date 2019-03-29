output "api_gateway_base_url" {
  value = "${module.api_gw_resource.api_gateway_base_url}"
}

output "cognito_user_pool_id" {
  value = "${module.cognito_userpools.cognito_user_pool_id}"
}

output "cognito_client" {
  value = "${module.cognito_userpools.cognito_client}"
}

output "cognito_group_name" {
  value = "${module.cognito_dlk_group.cognito_group_name}"
}
