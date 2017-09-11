kubectl create configmap --namespace kube-system kube-gelf --from-file fluent.conf

kubectl create -f daemonset.yaml

