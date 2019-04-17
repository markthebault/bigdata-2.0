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

output "eks_kubeconfig" {
  value = "${module.eks_dlk.kubeconfig}"
}

output "eks_kubeconfig_filename" {
  value = "${module.eks_dlk.kubeconfig_filename}"
}

output "eks_workers_asg_names" {
  value = "${module.eks_dlk.workers_asg_names}"
}

output "role_lambda_dlk_k8s_intraction_arn" {
  value = "${module.lambda_api_k8s_interact.role_arn}"
}

# output "kube2iam_role_arn" {
#   value = "${aws_iam_role.kube2iam_role.arn}"
# }

output "etl_role_arn" {
  value = "${aws_iam_role.etl_role.arn}"
}
