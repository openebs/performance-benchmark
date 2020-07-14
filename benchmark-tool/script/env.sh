source /script/kubeconfig.sh

mkdir -p /clusters/${CLUSTER_NAME}
cd /clusters/${CLUSTER_NAME}

# TODO ------------------------------------------------------------------------------
terraform init /terraform/eks

TFSTATE_PATH="/clusters/${CLUSTER_NAME}/terraform.tfstate"

export AWS_DEFAULT_REGION=$REGION
