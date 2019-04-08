variable "iam_role_name" {}

variable "tags" {
  default = {}
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "kubernetes_admin" {
  name = "role-${var.iam_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

EOF

  tags = "${merge(var.tags)}"
}

resource "aws_iam_policy" "policy" {
  name = "policy-${var.iam_role_name}"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "attachment-${var.iam_role_name}-k8s-admin"
  roles      = ["${aws_iam_role.kubernetes_admin.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.kubernetes_admin.arn}"
}

output "iam_role_name" {
  value = "${aws_iam_role.kubernetes_admin.name}"
}
