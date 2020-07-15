source /script/kubeconfig.sh


if [ -z "${PROFILE}" ]; then
  echo "PROFILE is undefined"
  exit 1
fi
if [ -z "${BACKEND}" ]; then
  echo "BACKEND is undefined"
  exit 1
fi


if [[ $BACKEND == "hostpath" ]]; then
  for node_ip in $(kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type == "ExternalIP")].address}'); do
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$node_ip <<-'EOF'
      sudo wipefs /dev/nvme1n1
      sudo mkfs.ext4 -F /dev/nvme1n1
EOF
  done
fi
if [[ $BACKEND == "cstor" ]]; then
  bash -e /script/install_openebs.sh

  block_dev_json=$(kubectl get blockdevice -n openebs -o json | jq -c '[.items[] | select(.spec.capacity.storage > 0) | .metadata.name]')
  cat <<EOF | kubectl apply -f -
  apiVersion: openebs.io/v1alpha1
  kind: StoragePoolClaim
  metadata:
    name: cstor-disk-pool
    annotations:
      cas.openebs.io/config: |
        - name: PoolResourceRequests
          value: |-
              memory: 2Gi
        - name: PoolResourceLimits
          value: |-
              memory: 4Gi
  spec:
    name: cstor-disk-pool
    type: disk
    poolSpec:
      poolType: striped
    blockDevices:
      blockDeviceList: $block_dev_json
EOF
fi
if [[ $BACKEND == "localpv" ]]; then
  bash -e /script/install_openebs.sh
fi
if [[ $BACKEND == "mayastor" ]]; then
  bash -e /script/install_mayastor.sh
fi



target_device=''

# cStor
if [[ $BACKEND == "cstor" ]]; then
  target_device='/dev/sda'
  kubectl apply -f /deploy/pvc-cstor.yaml
  kubectl apply -f /deploy/fio.yaml
fi
# MayaStor
if [[ $BACKEND == "mayastor" ]]; then
  # target_device=''
  kubectl apply -f /deploy/pvc-iscsi-parted.yaml
  kubectl apply -f /deploy/fio-parted.yaml
fi
# Local PV
if [[ $BACKEND == "localpv" ]]; then
  target_device=$NODE_DEVICE_NAME
  kubectl apply -f /deploy/pvc-local-device.yaml
  kubectl apply -f /deploy/fio.yaml
fi
# Hostpath
if [[ $BACKEND == "hostpath" ]]; then
  target_device=$NODE_DEVICE_NAME
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fio-pv
spec:
  storageClassName: manual
  capacity:
    storage: 200Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "$target_device"
EOF
  kubectl apply -f /deploy/pvc-manual.yaml
  kubectl apply -f /deploy/fio.yaml
fi



if kubectl wait pod --timeout=120s --for=condition=Ready fio; then

  # Common
  fio_args='--allow_mounted_write=1 --direct=1 --ioengine=libaio'

  target_flag='filename'

  # ES / Postgres
  if [[ $PROFILE == "elasticsearch" || $PROFILE == "postgres" ]]; then

    target_flag='replay_redirect'

    # Copy up the profiles (only when needed)
    kubectl cp io_profiles fio:/io_profiles

    fio_args+=" \
      --read_iolog=/io_profiles/postgres/nvme0n1.blktrace.0 \
      --filename=/dev/nvme1n1 \
      --replay_align=2 \
      --replay_scale=2 \
      --numjobs=10 \
      --group_reporting=1"
  fi

  # Basic Fio
  if [[ $PROFILE == "randrw" ]]; then
    fio_args+=" \
      --size=50m \
      --rw=randrw \
      --bs=4k \
      --iodepth=128 \
      --time_based \
      --runtime=60 \
      --numjobs=1"
  fi


  if [[ $BACKEND == "mayastor" ]]; then
    fio_args+=" \
      --group_reporting=1 \
      --name=job1 --$target_flag=/dev/sda \
      --name=job2 --$target_flag=/dev/sdb"
  else
    fio_args+=" \
      --name=job1 \
      --$target_flag=$target_device"
  fi


  echo "kubectl exec fio -- fio $fio_args"
  kubectl exec fio -- fio $fio_args
fi


# Tear down
kubectl delete pod fio --grace-period=0
kubectl delete pvc --all

for pv in $(kubectl get pv | awk '{print $1}' | tail +2); do
  kubectl patch pv $pv -p '{"metadata":{"finalizers":[]}}' --type=merge
done
kubectl delete pv --all



if [[ $BACKEND == "hostpath" ]]; then
  for node_ip in $(kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type == "ExternalIP")].address}'); do
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$node_ip <<-'EOF'
      sudo wipefs /dev/nvme1n1
EOF
  done
fi
if [[ $BACKEND == "cstor" ]]; then

  for bdc in $(kubectl get bdc -A | awk '{print $2}' | tail +2); do
    kubectl patch bdc $bdc -n openebs -p '{"metadata":{"finalizers":[]}}' --type=merge
  done

  kubectl delete spc --all -A
  kubectl delete csp --all -A
  kubectl delete bdc --all -A
  kubectl delete bd --all -A

  bash -e /script/uninstall_openebs.sh
fi
if [[ $BACKEND == "localpv" ]]; then
  bash -e /script/uninstall_openebs.sh
fi
if [[ $BACKEND == "mayastor" ]]; then
  bash -e /script/uninstall_mayastor.sh
fi
