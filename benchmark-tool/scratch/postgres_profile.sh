


sudo docker run --rm -d \
  --name FioTarget \
  --network host \
  -e "POSTGRES_PASSWORD=secret" \
  -v FioTarget:/var/lib/postgresql/data \
  postgres



sudo docker run --rm -it \
  -e "PGPASSWORD=secret" \
  -e "PGUSER=postgres" \
  -e "PGHOST=172.31.59.221" \
  postgres \
  /bin/bash -c '(createdb pgbench || true) && pgbench -i -s 9600 pgbench && pgbench -c 32 -j 2 -T 300 pgbench'



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
