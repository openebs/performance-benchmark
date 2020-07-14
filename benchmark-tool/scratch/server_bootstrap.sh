echo 'mkdir /disk1

chmod a+rwx /disk1

mkfs.ext4 -F /dev/nvme0n1
mount /dev/nvme0n1 /disk1

apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io


sysctl -w vm.max_map_count=262144


systemctl stop docker
sed -i "s/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd -g \/disk1\/docker -H fd:\/\//" /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker
' > script.sh

sudo bash -e script.sh
