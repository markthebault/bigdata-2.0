output "cognito_user_pool_id" {
  value = "${aws_cognito_user_pool.user_pool.id}"
}

output "cognito_client" {
  value = "${aws_cognito_user_pool_client.example_client.id}"
}
