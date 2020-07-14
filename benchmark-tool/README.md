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

**Delete cluster**

```shell
CLUSTER_NAME='maya-test-1' \
make delete_cluster
```
