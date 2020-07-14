#!/bin/bash -e

if [ -z "${CLUSTER_NAME}" ]; then
  echo "CLUSTER_NAME is undefined"
  exit 1
fi

AWS_CONF_DIR=${AWS_CONF_DIR:-"$HOME/.aws"}
REGION=${REGION:-"us-west-2"}
AZ_ONE=${AZ_ONE:-"us-west-2b"}
AZ_TWO=${AZ_TWO:-"us-west-2c"}
NODE_COUNT=${NODE_COUNT:-"1"}
NODE_TYPE=${NODE_TYPE:-"m5ad.2xlarge"}
NODE_DEVICE_NAME=${NODE_DEVICE_NAME:-"/dev/nvme1n1"}
SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:-"$HOME/.ssh/id_rsa.pub"}
SSH_DIR=${SSH_DIR:-"$HOME/.ssh"}


docker run -it --rm \
  -v $PWD/clusters:/clusters \
  -v $AWS_CONF_DIR:/root/.aws \
  -v $SSH_DIR:/root/.ssh \
  -e "CLUSTER_NAME=$CLUSTER_NAME" \
  -e "REGION=$REGION" \
  -e "AZ_ONE=$AZ_ONE" \
  -e "AZ_TWO=$AZ_TWO" \
  -e "NODE_COUNT=$NODE_COUNT" \
  -e "NODE_TYPE=$NODE_TYPE" \
  -e "NODE_DEVICE_NAME=$NODE_DEVICE_NAME" \
  -e "SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY" \
  -e "PROFILE=$PROFILE" \
  -e "BACKEND=$BACKEND" \
  $IMAGE_URL \
  /bin/bash $1
