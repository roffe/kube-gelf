# Kube-gelf

## WIP

```bash
kubectl create -f rbac.yaml

kubectl create configmap \
    --namespace kube-system kube-gelf \
    --from-file fluent.conf \
    --from-literal GELF_HOST=<graylog ip> \
    --from-literal GELF_PORT=12201

kubectl create -f daemonset.yaml
```

After updating the configmap reloading fluentd config on all pods can be done with kubectl access.
Please allow atleast a minute to pass before issuing the command due to Kubernetes not real-time syncing configmap updates to volumes.

```bash
for POD in `kubectl get pod --namespace kube-system -l app=kube-gelf | tail +2 | awk '{print $1}'`; do echo SIGHUP ${POD}; kubectl exec --namespace kube-system ${POD} -- /bin/sh -c 'kill -1 1'; sleep 1; done
```