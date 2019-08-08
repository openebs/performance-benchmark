## FIO-BASED STORAGE BENCHMARK 

- This job can be used to run storage benchmark tests using the popular I/O tool [fio](https://fio.readthedocs.io/en/latest/).
- The image used is alpine-based & is inspired by `sotoaster/dbench` 
- Consists of pre-defined fio templates, with the job params tuned as per standard storage performance tests (used by the community)

### WHAT DOES IT RUN

- The job runs in three modes, defined by the `DBENCH_TYPE` ENV, namely:

  - `quick`: Runs random workload (read & write tests)
  - `detailed`: Runs the latency-oriented (random)(read & write), mixed profiles & sequential workloads (read & write) 
  - `custom`: Runs a one-off fio job with the params provided by the user

In both the `quick` & `detailed` mode, some of the default params can be tuned/overridden, while `custom` allows for a 
complete user-defined profile.

### HOW TO RUN IT 

- Ensure the OpenEBS control-plane & storageclasses is already installed.
- Create an OpenEBS PVC/PV of desired storageclass beforehand & mention the claim name in the jobspec OR include the 
  PVC spec in addition to the job spec in the fio-deploy yaml. 
- Execute `kubectl create -f fio-deploy.yaml`

### HOW TO VIEW RESULTS 

- Check the logs of the completed job

