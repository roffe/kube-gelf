# Kube-gelf

## WIP
```
kubectl create -f sa.yaml
kubectl create -f rbac.yaml

kubectl create configmap --namespace kube-system kube-gelf --from-file fluent.conf

kubectl create -f daemonset.yaml
```
