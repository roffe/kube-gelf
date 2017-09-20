# kube-gelf
CoreOS kubernetes container logs & journald log collector with graylog output.
Configurable through configmap and with provided cron example to mitigate some fluentd bugs as well as providing option for config reloads

```bash
kubectl create -f rbac.yaml

kubectl create configmap \
    --namespace kube-system kube-gelf \
    --from-file fluent.conf \
    --from-literal GELF_HOST=<graylog ip> \
    --from-literal GELF_PORT=12201

kubectl create -f daemonset.yaml

kubectl create -f cron.yaml
```

After updating the configmap reloading fluentd config on all pods can be done with kubectl access.
Please allow atleast a minute to pass before issuing the command due to Kubernetes not real-time syncing configmap updates to volumes.

```bash
for POD in `kubectl get pod --namespace kube-system -l app=kube-gelf | tail -n +2 | awk '{print $1}'`; do echo RELOAD ${POD}; kubectl exec --namespace kube-system ${POD} -- /bin/sh -c 'kill -1 1'; done
```

Or if one enables batch/v2alpha1=true in the apiservers the cron.yaml can be used to deploy a cronJob that periodicly tells kube-gelf to reload it's configuration to also remedie:

in_tail prevents docker from removing container
https://github.com/fluent/fluentd/issues/1680

in_tail removes untracked file position during startup phase. It means the content of pos_file is growing until restart when you tails lots of files with dynamic path setting. I will fix this problem in the future. Check this issue.
https://github.com/fluent/fluentd/issues/1126
