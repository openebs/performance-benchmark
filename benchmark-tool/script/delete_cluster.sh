source /script/env.sh

eksctl delete cluster --name $CLUSTER_NAME || true

terraform destroy \
  -auto-approve \
  -state=$TFSTATE_PATH \
  -var "clusters_dir=/clusters" \
  -var "cluster_name=${CLUSTER_NAME}" \
  -var "region=$REGION" \
  -var "availability_zone_one=$AZ_ONE" \
  -var "availability_zone_two=$AZ_TWO" \
  /terraform/eks
