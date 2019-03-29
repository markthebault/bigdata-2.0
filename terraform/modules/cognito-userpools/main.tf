resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.cognito_userpools_name}"

  schema {
    name                     = "acl"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 1000
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 50
    }
  }
}

resource "aws_cognito_user_pool_client" "example_client" {
  name                = "${var.cognito_userpools_name}-client"
  user_pool_id        = "${aws_cognito_user_pool.user_pool.id}"
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  read_attributes     = ["name", "email", "sub", "custom:acl"]
}
