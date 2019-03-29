output "cognito_group_name" {
  value = "${aws_cognito_user_group.main.name}"
}
