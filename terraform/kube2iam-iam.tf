# locals {
#   kube2iam_role_name = "k8s-kube2iam"
# }
# resource "aws_iam_role" "kube2iam_role" {
#   name = "role-${local.kube2iam_role_name}"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     },
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${module.eks_dlk.worker_iam_role_arn}"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
#   tags = "${merge(var.tags)}"
# }
# resource "aws_iam_policy" "kube2iam_policy" {
#   name = "policy-${local.kube2iam_role_name}"
#   path = "/"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "sts:AssumeRole"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#           "${aws_iam_role.etl_role.arn}"
#       ]
#     }
#   ]
# }
# EOF
# }
# resource "aws_iam_policy_attachment" "kube2iam_attach" {
#   name       = "attachment-${local.kube2iam_role_name}-role"
#   roles      = ["${aws_iam_role.kube2iam_role.name}"]
#   policy_arn = "${aws_iam_policy.kube2iam_policy.arn}"
# }

