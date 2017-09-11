# Kube-gelf

## WIP

Deploy

```bash
kubectl create -f sa.yaml

kubectl create -f rbac.yaml

kubectl create configmap \
    --namespace kube-system kube-gelf \
    --from-file fluent.conf \
    --from-literal GELF_HOST=<graylog ip> \
    --from-literal GELF_PORT=12201

kubectl create -f daemonset.yaml
```
