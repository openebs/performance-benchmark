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
- Deploy the fio job manifest

  ```
  root@chaos-go:~# kubectl create -f fio-deploy.yaml 
  job.batch/dbench-njlxh created
  ```

  ```
  root@chaos-go:~# kubectl get pods 
  NAME                     READY   STATUS      RESTARTS   AGE
  dbench-njlxh-bslsv       1/1     Running     0          4s
  ```

### HOW TO CHECK PROGRESS & VIEW RESULTS 

- Check the logs of the ongoing/completed job 

  ```
  root@chaos-go:~# kubectl logs -f dbench-njlxh-bslsv
  Working dir: /data

  Testing Read IOPS...
  ```
 
- In case of quick/detailed job types, the fio results are parsed and summary provided: 

  ```
  All tests complete.

  ==================
  = Dbench Summary =
  ==================
  Random Read/Write IOPS: 147/300. BW: 16.4MiB/s / 29.2MiB/s
  Average Latency (usec) Read/Write: 26397.57/13089.65
  Sequential Read/Write: 120MiB/s / 120MiB/s
  Mixed Random Read/Write IOPS: 179/59
  ```

- In case of custom jobs type, the fio results are presented in json format:

  ```
  Testing Custom I/O Profile..
  {
    "fio version" : "fio-3.13",
    "timestamp" : 1565244391,
    "timestamp_ms" : 1565244391233,
    "time" : "Thu Aug  8 06:06:31 2019",
    "global options" : {
      "filename" : "/data/fiotest",
      "bs" : "16k",
      "iodepth" : "64",
      "ioengine" : "sync",
      "size" : "500M"
    },
    "jobs" : [
      {
        "jobname" : "custom",
        "groupid" : 0,
        "error" : 0,
        "eta" : 0,
        "elapsed" : 95,
        "job options" : {
          "name" : "custom",
          "rw" : "randrw",
          "rwmixread" : "80",
          "random_distribution" : "pareto"
        },
        "read" : {
          "io_bytes" : 418496512,
          "io_kbytes" : 408688,
          "bw_bytes" : 4455740,
          "bw" : 4351,
          "iops" : 271.956816,
          "runtime" : 93923,
          "total_ios" : 25543,
          "short_ios" : 0,
          "drop_ios" : 0,
          "slat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000
          },
          "clat_ns" : {
            "min" : 1442,
            "max" : 103178937,
            "mean" : 3666519.548448,
            "stddev" : 8232144.081062,
            "percentile" : {
              "1.000000" : 1496,
              "5.000000" : 1592,
              "10.000000" : 1832,
              "20.000000" : 4320,
              "30.000000" : 4896,
              "40.000000" : 5536,
              "50.000000" : 6496,
              "60.000000" : 8512,
              "70.000000" : 12608,
              "80.000000" : 6717440,
              "90.000000" : 14483456,
              "95.000000" : 20840448,
              "99.000000" : 35389440,
              "99.500000" : 44302336,
              "99.900000" : 64749568,
              "99.950000" : 73924608,
              "99.990000" : 100139008
            }
          },
          "lat_ns" : {
            "min" : 1475,
            "max" : 103178970,
            "mean" : 3666739.408683,
            "stddev" : 8232149.905693
          },
          "bw_min" : 1664,
          "bw_max" : 8960,
          "bw_agg" : 100.000000,
          "bw_mean" : 4351.582888,
          "bw_dev" : 1417.766666,
          "bw_samples" : 187,
          "iops_min" : 104,
          "iops_max" : 560,
          "iops_mean" : 271.930481,
          "iops_stddev" : 88.633294,
          "iops_samples" : 187
        },
        "write" : {
          "io_bytes" : 105791488,
          "io_kbytes" : 103312,
          "bw_bytes" : 1126364,
          "bw" : 1099,
          "iops" : 68.747804,
          "runtime" : 93923,
          "total_ios" : 6457,
          "short_ios" : 0,
          "drop_ios" : 0,
          "slat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000
          },
          "clat_ns" : {
            "min" : 2701,
            "max" : 961553,
            "mean" : 21392.000000,
            "stddev" : 23236.131518,
            "percentile" : {
              "1.000000" : 2832,
              "5.000000" : 3216,
              "10.000000" : 6304,
              "20.000000" : 8256,
              "30.000000" : 10048,
              "40.000000" : 12224,
              "50.000000" : 16512,
              "60.000000" : 20608,
              "70.000000" : 26496,
              "80.000000" : 33536,
              "90.000000" : 41216,
              "95.000000" : 49408,
              "99.000000" : 87552,
              "99.500000" : 101888,
              "99.900000" : 128512,
              "99.950000" : 201728,
              "99.990000" : 962560
            }
          },
          "lat_ns" : {
            "min" : 2832,
            "max" : 961901,
            "mean" : 21838.640081,
            "stddev" : 23410.608218
          },
          "bw_min" : 288,
          "bw_max" : 2528,
          "bw_agg" : 100.000000,
          "bw_mean" : 1100.657754,
          "bw_dev" : 413.426243,
          "bw_samples" : 187,
          "iops_min" : 18,
          "iops_max" : 158,
          "iops_mean" : 68.721925,
          "iops_stddev" : 25.869351,
          "iops_samples" : 187
        },
        "trim" : {
          "io_bytes" : 0,
          "io_kbytes" : 0,
          "bw_bytes" : 0,
          "bw" : 0,
          "iops" : 0.000000,
          "runtime" : 0,
          "total_ios" : 0,
          "short_ios" : 0,
          "drop_ios" : 0,
          "slat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000
          },
          "clat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000,
            "percentile" : {
              "1.000000" : 0,
              "5.000000" : 0,
              "10.000000" : 0,
              "20.000000" : 0,
              "30.000000" : 0,
              "40.000000" : 0,
              "50.000000" : 0,
              "60.000000" : 0,
              "70.000000" : 0,
              "80.000000" : 0,
              "90.000000" : 0,
              "95.000000" : 0,
              "99.000000" : 0,
              "99.500000" : 0,
              "99.900000" : 0,
              "99.950000" : 0,
              "99.990000" : 0
            }
          },
          "lat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000
          },
          "bw_min" : 0,
          "bw_max" : 0,
          "bw_agg" : 0.000000,
          "bw_mean" : 0.000000,
          "bw_dev" : 0.000000,
          "bw_samples" : 0,
          "iops_min" : 0,
          "iops_max" : 0,
          "iops_mean" : 0.000000,
          "iops_stddev" : 0.000000,
          "iops_samples" : 0
        },
        "sync" : {
          "lat_ns" : {
            "min" : 0,
            "max" : 0,
            "mean" : 0.000000,
            "stddev" : 0.000000,
            "percentile" : {
              "1.000000" : 0,
              "5.000000" : 0,
              "10.000000" : 0,
              "20.000000" : 0,
              "30.000000" : 0,
              "40.000000" : 0,
              "50.000000" : 0,
              "60.000000" : 0,
              "70.000000" : 0,
              "80.000000" : 0,
              "90.000000" : 0,
              "95.000000" : 0,
              "99.000000" : 0,
              "99.500000" : 0,
              "99.900000" : 0,
              "99.950000" : 0,
              "99.990000" : 0
            }
          },
          "total_ios" : 0
        },
        "job_runtime" : 93922,
        "usr_cpu" : 0.216137,
        "sys_cpu" : 0.771917,
        "ctx" : 7333,
        "majf" : 0,
        "minf" : 12,
        "iodepth_level" : {
          "1" : 100.000000,
          "2" : 0.000000,
          "4" : 0.000000,
          "8" : 0.000000,
          "16" : 0.000000,
          "32" : 0.000000,
          ">=64" : 0.000000
        },
        "iodepth_submit" : {
          "0" : 0.000000,
          "4" : 100.000000,
          "8" : 0.000000,
          "16" : 0.000000,
          "32" : 0.000000,
          "64" : 0.000000,
          ">=64" : 0.000000
        },
        "iodepth_complete" : {
          "0" : 0.000000,
          "4" : 100.000000,
          "8" : 0.000000,
          "16" : 0.000000,
          "32" : 0.000000,
          "64" : 0.000000,
          ">=64" : 0.000000
        },
        "latency_ns" : {
          "2" : 0.000000,
          "4" : 0.000000,
          "10" : 0.000000,
          "20" : 0.000000,
          "50" : 0.000000,
          "100" : 0.000000,
          "250" : 0.000000,
          "500" : 0.000000,
          "750" : 0.000000,
          "1000" : 0.000000
        },
        "latency_us" : {
          "2" : 9.131250,
          "4" : 5.790625,
          "10" : 43.571875,
          "20" : 10.284375,
          "50" : 7.793750,
          "100" : 0.971875,
          "250" : 0.106250,
          "500" : 0.262500,
          "750" : 1.912500,
          "1000" : 0.315625
        },
        "latency_ms" : {
          "2" : 1.368750,
          "4" : 0.309375,
          "10" : 5.843750,
          "20" : 7.978125,
          "50" : 4.081250,
          "100" : 0.268750,
          "250" : 0.010000,
          "500" : 0.000000,
          "750" : 0.000000,
          "1000" : 0.000000,
          "2000" : 0.000000,
          ">=2000" : 0.000000
        },
        "latency_depth" : 64,
        "latency_target" : 0,
        "latency_percentile" : 100.000000,
        "latency_window" : 0
      }
    ],
    "disk_util" : [
      {
        "name" : "sda",
        "read_ios" : 7140,
        "write_ios" : 2280,
        "read_merges" : 0,
        "write_merges" : 36,
        "read_ticks" : 92742,
        "write_ticks" : 9247,
        "in_queue" : 9281,
        "util" : 1.108352
      }
    ]  
  }
  ```
  

