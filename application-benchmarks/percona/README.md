# Running TPC-C benchmark on Percona Pod 
----------------------------------------

## What is TPC-C benchmark

As an OLTP system benchmark, TPC-C (From - "Transaction Performance Council") simulates a complete environment where
a population of terminal operators executes transactions against a database. The benchmark is centered around the
principal activities (transactions) of an order-entry environment. These transactions include entering and delivering
orders, recording payments, checking the status of orders, and monitoring the level of stock at the warehouses.

Read more about TPC-C here : http://www.tpc.org/tpc_documents_current_versions/pdf/tpc-c_v5.11.0.pdf

## Steps to run TPC-C benchmark

Note: We use percona's tpcc-mysql tool to run this benchmark (https://github.com/Percona-Lab/tpcc-mysql)

- Deploy the percona pod on kubernetes 
  
  ```
  kubectl apply -f percona.yaml
  ```

  This will also create the percona pod along with the OpenEBS persistent volumes which will be used as the mysql for
  the data directory. Confirm the pod is running using the below command

  ```
  kubectl get pods
  ```

- Setup metrics monitoring using the PMM (Percona monitoring management) tools

  First, set up the PMM server pod 

  ```
  kubectl apply -f pmm-server.yaml
  ```
  
  Identify which node the pmm-server pod is running on. Note the node public IP 

  ```
  kubectl describe pod pmm-server
  ```

  Verify that the grafana dashboard of PMM server is accessible over http://<node-public-ip>:31758

- Register the DB host, i.e., the percona container as a host on the PMM-server. The percona image that we have 
  deployed comes integrated with the pmm-client packages

  As part of this, first identify the pmm-server pod IP

  ```
  kubectl describe pod pmm-server | grep IP
  ```

  Add the percona container as host into PMM-server
  
  ```
  kubectl exec percona /bin/bash -- pmm-admin config --server <pmm-server-pod-ip>
  ```

  Add the services (mysql) which we would like to be monitored. The node(linux)- metrics are monitored by default 
  with endpoint at port 42000, while the mysql metrics are collected on port 42002

  ```
  kubectl exec percona /bin/bash -- pmm-admin add mysql --user <db_user> --password <db_password>
  ```

  Verify that the host is added and services are monitored by visiting the PMM-server dashboard

- Update the TPCC benchmark configuration file ```tpcc.conf``` with desired values 
  
- Create a kubernetes config map to hold the tpcc benchmark config. This will be used in the kubernetes job
  that will run the benchmark

  ```
  kubectl create configmap tpcc-config --from-file tpcc.conf
  ```

  Verify successful creation of the configmap

  ```
  kubectl describe configmap
  ```
 
- Launch the tpcc benchmark job yaml to prepare the database, load it & run the benchmark test. 

  As part of this, first identify the percona pod IP

  ```
  kubectl describe pod percona | grep IP
  ```

  Replace this IP in the "args" section for the container in the tpcc-bench job specification yaml

  Finally, launch the job 

  ```
  kubectl apply -f tpcc-bench.yaml
  ```

  Verify that the job is running successfully

  ```
  kubectl get pods
  ```

  The mysql metrics and system metrics (disk performance, space etc..,) can be viewed on the PMM-server dashboard

  We can even view the tpcc-bench container logs when the test is in progress

  ```
  kubectl logs -f <tpcc-bench-pod-name>
  ```

- Note the tpmC value from the tpcc-bench container logs.Also note the storage metrics such as IOPS, 
  latency, bandwidth & utilization stats from PMM. 

## What next ? 

The tpmC metric represents new-orders-per-minute & accounts for around 45% of the entire transactions,
therefore the total transactions can be accordingly derived. The steps can be repeated with specific mysql startup
params OR tpcc benchmark params (increased warehouses, threads) based on test intent




  
  

  

