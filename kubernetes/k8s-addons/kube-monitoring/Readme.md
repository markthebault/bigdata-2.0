# Metrics server
This server is important if you want to use HorizontalScaling pods. This server collect metrics from pods and nodes.

Those metrics are available under the following API: `kube get --raw /apis/metrics.k8s.io/v1beta1`

**Note: Metrics severs is the one to go with the next versions of kubernetes. Unfortunately a bug is in the version 1.9.x, the kubectl top command still uses heapster metrics, so there is both in this folder.**

