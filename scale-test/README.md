This `scale-test` directory contains scripts and templated yamls to generate required number of application pods yaml and apply these yamls.
After test is completed, scripts takes care of collecting fio outputs into local machine's <curdir>/<testid> and prints the IOPS/latency snippets of fio output.
These scripts also takes care of any cleanup required during the start of test, and also does cleanup at the end of test.

Notes:
- All the pods and PVCs generated in this test are created in `default` namespace.
- Script (runScaletest.sh) have checks to make sure that PVCs are bound to PV. So, if SC is having 'WaitForFirstConsumer` as the BindingMode, this check need to be removed.
- Script (runScaletest.sh) have checks to make sure that all CVRs are in Healthy state before starting the applications. This check need to be removed if storageclass used in PVC is NOT related to cStor.

Pre-requisites Required:
- K8s setup
- OpenEBS installed
- Required storage engines is setup
- Storage classes

Steps to perform to run tests:
- Update @nodes@ in getresults.sh, runScaletest.sh, runMountpods.sh with the list of nodes where workloads can run
- Update @results-dir@ in mountpodtemplate.yaml, fiotemplate.yaml, fioload-template.yaml to the directory on the nodes where results can be collected
- Update @nodeSelector@ in fiotemplate.yaml and fioload-template.yaml
- Change the fio command in fiotemplate.yaml and fioload-template.yaml
- Update storageClassName, storage in fiopvctemplate.yaml

Note: Don't worry about other values that need to be filled in the template yamls. Scripts takes care of them.

How it works:

- Bring up the pods in the nodes where workloads can run by doing:
`bash -x runMountpods.sh`
These pods helps in collecting logs from the nodes.

- Bring up the required number of application pods by running:
`bash -x runScaletest.sh <testid> <blocksize> <# of fio pods>`

<testid> can be any unique string. Please make sure that no two tests are ran with same <testid>
<blocksize> is the size at which fio should run
<# of fio pods> is the number of application pods to run.


That's it. It prints the shell commands that are run as part of the script.
And, output of our concern will look like:
```
+ grep -w IOPS fio1
   read: IOPS=7, BW=1992KiB/s (2040kB/s)(29.2MiB/15038msec)
+ grep -w lat fio1
+ grep -i min
     lat (msec): min=66, max=205, avg=128.51, stdev=22.64
```
