source /script/env.sh

terraform apply \
  -auto-approve \
  -state=$TFSTATE_PATH \
  -var "clusters_dir=/clusters" \
  -var "cluster_name=${CLUSTER_NAME}" \
  -var "region=$REGION" \
  -var "availability_zone_one=$AZ_ONE" \
  -var "availability_zone_two=$AZ_TWO" \
  /terraform/eks


export PUBLIC_SUBNET_ID_ONE=$(terraform output -state=$TFSTATE_PATH public_subnet_id_one)
export PRIVATE_SUBNET_ID_ONE=$(terraform output -state=$TFSTATE_PATH private_subnet_id_one)
export PUBLIC_SUBNET_ID_TWO=$(terraform output -state=$TFSTATE_PATH public_subnet_id_two)
export PRIVATE_SUBNET_ID_TWO=$(terraform output -state=$TFSTATE_PATH private_subnet_id_two)


eksctl create cluster \
  --name ${CLUSTER_NAME} \
  --vpc-private-subnets=${PRIVATE_SUBNET_ID_ONE},${PRIVATE_SUBNET_ID_TWO} \
  --vpc-public-subnets=${PUBLIC_SUBNET_ID_ONE},${PUBLIC_SUBNET_ID_TWO} \
  --version 1.16 \
  --nodegroup-name 'standard-workers' \
  --node-type ${NODE_TYPE} \
  --nodes ${NODE_COUNT} \
  --node-ami auto \
  --ssh-access --ssh-public-key ~/.ssh/id_rsa.pub



for node_ip in $(kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type == "ExternalIP")].address}'); do
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$node_ip <<-'EOF'
    sudo yum install -y iscsi-initiator-utils
    sudo systemctl enable iscsid
    sudo systemctl start iscsid

    sudo chmod a+r /var/run/iscsid.pid

    echo 512 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    echo 'vm.nr_hugepages = 512' | sudo tee -a /etc/sysctl.conf

    sudo modprobe nbd
    echo 'nbd' | sudo tee -a /etc/modules-load.d/modules.conf

    sudo service kubelet restart

    sudo yum install -y parted

    # file=/etc/systemd/system/kubelet.service.d/10-eksclt.al2.conf
    # last_line=$(cat $file | tail -1)
    # replacement="$last_line \\"
    # escaped_replacement=$(printf '%s\n' "$replacement" | sed -e 's/[\/&]/\\&/g')
    # escaped_keyword=$(echo $last_line | sed -e 's/[]\/$*.^[]/\\&/g')
    # sudo sed -i "s/ *$escaped_keyword/$escaped_replacement/" $file
    # echo '  --cpu-manager-policy=static --kube-reserved cpu=1 --system-reserved cpu=1' | sudo tee -a $file
    # sudo rm /var/lib/kubelet/cpu_manager_state
    # sudo systemctl daemon-reload
    #
    # sudo sed -ri "s/(GRUB_CMDLINE_LINUX_DEFAULT=.+)\"$/\1 isolcpus=0\"/" /etc/default/grub
    # sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    #
    # (sleep 1 && sudo reboot &) && exit
EOF
done
