# Kubernetes dashboard
This is the typical kubernetes dashboard, it is configured to use an internal load balancer. So you need to be on the same network as the VPC to access to this dashboard (you can use socks proxy for instance.)

## Usage
```shell
$ kubectl apply -f kube-dashboard
```
## Log in
Login can be done either by sending the config file of the kubectl `~/.kube/config` of using a token. The token expires in few minutes so you need to re-connect.

To get the docker you need to run the following commands:
```shell
$ kubectl get secrets -n kube-system | grep kubernetes-dashboard
kubernetes-dashboard-certs                       Opaque                                0         1d
kubernetes-dashboard-key-holder                  Opaque                                2         5d
kubernetes-dashboard-token-XXXXX                 kubernetes.io/service-account-token   3         1d
$ kubectl describe secret kubernetes-dashboard-token-XXXXX -n kube-system
# Copy the token and past it in the dashboard
```