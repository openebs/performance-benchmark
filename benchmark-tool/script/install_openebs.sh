source /script/kubeconfig.sh


helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

kubectl create ns openebs || true
helm install --namespace openebs openebs stable/openebs --version 1.8.0 --set 'ndm.filters.excludePaths=/dev/nbd' || true

kubectl wait pod --timeout=120s --for=condition=Ready -n openebs -l app=openebs


kubectl apply -f /deploy/storageclass-cstor.yaml
