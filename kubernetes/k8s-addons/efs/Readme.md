## EFS volume storage for pods
You can create persistent volumes using efs, a new folder in the EFS will be created at the lunch of the pod. Make sure the container runs in root mode otherwise the pod will not have read access to the volume.

The different scripts came from [this repository](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs)

Before executing you need to change the different values in the `manifest.yml`:
- value of **file.system.id**
- value of **aws.region**
- value of **server**

## Usage
```
$ kubectl apply -f efs/
```

then you can attache the volume to the pod as following:
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: gcr.io/google_containers/busybox:1.24
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
      - name: efs-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: efs-pvc
      persistentVolumeClaim:
        claimName: efs #here is the name of the persistan volume created by the manifest.yml
```