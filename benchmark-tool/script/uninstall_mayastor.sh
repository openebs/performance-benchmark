source /script/kubeconfig.sh


kubectl delete ns mayastor



for node_ip in $(kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type == "ExternalIP")].address}'); do
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$node_ip <<-'EOF'
    sudo wipefs --all --force /dev/nvme1n1
    sudo partprobe
EOF
done
