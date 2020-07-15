source /script/kubeconfig.sh




for node_ip in $(kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type == "ExternalIP")].address}'); do
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$node_ip <<-'EOF'
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<-EOG | sudo fdisk /dev/nvme1n1
  o     # clear the in memory partition table
  n     # new partition
  p     # primary partition
  1     # partition number 1
        # default, start immediately after preceding partition
  +139G # size
  n     # new partition
  p     # primary partition
  2     # partion number 2
        # default, start immediately after preceding partition
  +139G # size
  p     # print the in-memory partition table
  w     # write the partition table
  q     # and we're done
EOG
sudo partprobe
EOF
done



kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/v0.2.0/csi/moac/crds/mayastorpool.yaml

kubectl apply -f /mayastor/deploy/namespace.yaml
kubectl apply -f /mayastor/deploy/nats-deployment.yaml
kubectl apply -f /mayastor/deploy/moac-deployment.yaml
# kubectl apply -f /mayastor/deploy/mayastor-daemonset.yaml
kubectl apply -f /deploy/mayastor-daemonset.yaml


device_name=$NODE_DEVICE_NAME


for node_name in $(kubectl get nodes -o=jsonpath='{.items[*].metadata.name}'); do
  kubectl label node $node_name openebs.io/engine=mayastor --overwrite

  cat <<EOF | kubectl apply -f -
    apiVersion: "openebs.io/v1alpha1"
    kind: MayastorPool
    metadata:
      name: $node_name
      namespace: mayastor
    spec:
      node: $node_name
      disks: ["$device_name"]
EOF
done


kubectl apply -f /deploy/storageclass-iscsi.yaml
kubectl apply -f /deploy/storageclass-nbd.yaml



kubectl wait pod --timeout=120s --for=condition=Ready -n mayastor -l app=mayastor
