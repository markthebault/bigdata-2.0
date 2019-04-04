## Cluster autoscaler
This script is came from [this link](https://github.com/kubernetes/kops/tree/master/addons/cluster-autoscaler)

Basically it scales the cluster according to the resources requested by the pods. Make sure you change the run-template values with the ones used in the project (such as the region and the auto-scaling group for kuberlet nodes).

## Usage
```
#this will execute kubectl apply -f 
$ ./run-template
```