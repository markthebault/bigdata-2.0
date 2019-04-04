#!/bin/bash
KUBECONFIG=${KUBECONFIG:-../terraform/kubeconfig_eks-dlk-cluster}
ROLE=arn:aws:lambda:eu-central-1:787257827481:function:lambda-simple-api-apigw-k8s-interactions

AUTH_CONFIG=$(kubectl --kubeconfig $KUBECONFIG get -n kube-system configmap/aws-auth -o json)

echo $AUTH_CONFIG > aws-auth-config.json.back
echo $AUTH_CONFIG | python tools/addRoleToConfig.py $ROLE > aws-auth-config.json
kubectl --kubeconfig $KUBECONFIG apply -f aws-auth-config.json