sudo docker run --rm -d \
  --name FioTarget \
  --network host \
  -e "discovery.type=single-node" \
  -e "bootstrap.memory_lock=true" --ulimit memlock=-1:-1 \
  -e "ES_JAVA_OPTS=-Xms8g -Xmx8g" \
  -v FioTarget:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:7.8.0





# curl -O https://raw.githubusercontent.com/elastic/rally-tracks/master/download.sh
# chmod u+x download.sh
#
# ./download.sh http_logs
#
# tar -xf rally-track-data-http_logs.tar
#
# # -v ~/.rally/benchmarks/data/http_logs/:/rally/.rally/benchmarks/data/http_logs \








# sudo mkdir -p /rally
# sudo chmod a+rwx -R /rally
#
# sudo docker run --rm -it \
#   -v /rally:/rally/.rally \
#   elastic/rally \
#   --track=http_logs --pipeline=benchmark-only --target-hosts=172.31.57.81:9200
#
#
#
#
# sudo docker run --rm -d \
#   -v /rally:/rally/.rally \
#   elastic/rally \
#   /bin/bash -c 'esrallyd start --node-ip=172.31.1.59 --coordinator-ip=172.31.1.59 && sleep 9999999'
#
# sudo docker run --rm -it \
#   -v /rally:/rally/.rally \
#   elastic/rally \
#   -p
#   /bin/bash -c 'esrallyd start --node-ip=172.31.10.222 --coordinator-ip=172.31.7.193 && sleep 9999999'
#
# # esrallyd start --node-ip=10.5.5.5 --coordinator-ip=10.5.5.5
# # esrally --pipeline=benchmark-only  --target-hosts=10.5.5.11:9200,10.5.5.12:9200,10.5.5.13:9200
#
# sudo docker run --rm -it \
#   -v /rally:/rally/.rally \
#   elastic/rally \
#   --track=http_logs --pipeline=benchmark-only --target-hosts=172.31.57.81:9200 --load-driver-hosts=172.31.1.59




#
# esrallyd start --node-ip=172.31.13.155 --coordinator-ip=172.31.13.155
#
# esrallyd start --node-ip=172.31.13.117 --coordinator-ip=172.31.13.155
#
# esrallyd start --node-ip=172.31.13.197 --coordinator-ip=172.31.13.155
#
# esrallyd start --node-ip=172.31.4.180 --coordinator-ip=172.31.4.180



esrally race --track=pmc --pipeline=benchmark-only --target-hosts=172.31.57.81:9200 --load-driver-hosts=172.31.1.59,172.31.1.6,172.31.0.45,172.31.14.92


echo 'FROM ubuntu
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y blktrace' > Dockerfile

sudo docker build -t profiler .

mkdir profiles

sudo docker run --rm -it \
  --privileged \
  --name Blktrace \
  --volumes-from FioTarget \
  -v $(pwd)/profiles:/profiles \
  profiler \
  /bin/bash -c 'mount -t debugfs none /sys/kernel/debug && cd /profiles && blktrace -d /dev/nvme0n1 -o nvme0n1 -w 60'




# --------------------- just have mount below for testing.. do not need

# sudo docker run --rm -it \
#   --privileged \
#   --name Btrecord \
#   --volumes-from FioTarget \
#   -v $(pwd)/profiles:/profiles \
#   profiler \
#   /bin/bash -c 'cd /profiles && btrecord -F'
#
#
# sudo docker run --rm -it \
#   --privileged \
#   --name Btreplay \
#   --volumes-from FioTarget \
#   -v $(pwd)/profiles:/profiles \
#   profiler \
#   /bin/bash -c 'cd /profiles && btreplay -F'







sudo docker run --rm -it \
  --privileged \
  -v $(pwd)/profiles:/profiles \
  dmonakhov/alpine-fio \
  fio \
    --name=benchtest \
    --size=50m \
    --read_iolog=/profiles/nvme0n1.blktrace.0 \
    --allow_mounted_write=1 \
    --filename='/dev/nvme1n1' \
    --direct=1 \
    --rw=randrw \
    --ioengine=libaio \
    --bs=4k \
    --iodepth=16 \
    --numjobs=1 \
    --time_based \
    --runtime=60



sudo docker run --rm -it \
  --privileged \
  -v $(pwd)/profiles:/profiles \
  dmonakhov/alpine-fio \
  fio \
    --name=benchtest \
    --size=50m \
    --allow_mounted_write=1 \
    --filename='/dev/nvme1n1' \
    --direct=1 \
    --rw=randrw \
    --ioengine=libaio \
    --bs=4k \
    --iodepth=16 \
    --numjobs=1 \
    --time_based \
    --runtime=60
