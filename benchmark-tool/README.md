**Create a cluster**

```shell
CLUSTER_NAME='maya-test-1' \
make create_cluster
```

**Run a test**

Profiles: `randrw`, `postgres`
Backends: `hostpath`, `localpv`, `cstor`, `mayastor`

```shell
CLUSTER_NAME='maya-test-1' \
PROFILE='randrw' \
BACKEND='mayastor' \
make test_performance
```

**Results**

Random read/write:
```
Hostpath:
  read: IOPS=58.1k, BW=227MiB/s (238MB/s)(13.3GiB/60001msec)
  write: IOPS=58.1k, BW=227MiB/s (238MB/s)(13.3GiB/60001msec)

Local PV:
  read: IOPS=58.0k, BW=227MiB/s (238MB/s)(13.3GiB/60001msec)
  write: IOPS=57.0k, BW=227MiB/s (238MB/s)(13.3GiB/60001msec)

cStor:
  read: IOPS=2256, BW=9024KiB/s (9241kB/s)(529MiB/60003msec)
  write: IOPS=2258, BW=9034KiB/s (9251kB/s)(529MiB/60003msec)

MayaStor:
  read: IOPS=31.3k, BW=122MiB/s (128MB/s)(7336MiB/60006msec)
  write: IOPS=31.3k, BW=122MiB/s (128MB/s)(7335MiB/60006msec)
```

Postgres:
```
Hostpath:
  read: IOPS=10.2k, BW=79.9MiB/s (83.7MB/s)(4202MiB/52646msec)
  write: IOPS=16.3k, BW=252MiB/s (264MB/s)(12.1GiB/52646msec)

Local PV:
  read: IOPS=9042, BW=71.0MiB/s (74.5MB/s)(4202MiB/59178msec)
  write: IOPS=14.5k, BW=224MiB/s (235MB/s)(12.1GiB/59178msec)

cStor:
  read: IOPS=1383, BW=10.9MiB/s (11.4MB/s)(4202MiB/386917msec)
  write: IOPS=2214, BW=34.3MiB/s (35.1MB/s)(12.1GiB/386917msec)

MayaStor:
  read: IOPS=10.2k, BW=79.5MiB/s (83.4MB/s)(8403MiB/105773msec)
  write: IOPS=16.2k, BW=251MiB/s (263MB/s)(25.1GiB/105773msec)
```

**Delete cluster**

```shell
CLUSTER_NAME='maya-test-1' \
make delete_cluster
```
