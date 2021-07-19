Process under GCP project. Please remember perf-tests running on kubemark master, so all logs should be checked under /var/log/ on kubemark cluster

Pre-rerequisites: GCP config
1. run "gcloud version" to ensure your Google Cloud SDK is updated (suggested Google Cloud SDK 298.0.0 and up), Please refer to https://cloud.google.com/sdk/docs/downloads-apt-get or https://cloud.google.com/sdk/docs/downloads-versioned-archives to upgrade your google cloud SDK
2. ensure your docker login and access has been configured, if not, please run "gcloud auth configure-docker" to config

Pre-rerequisites: build prepare
```
git clone [arktos git link]
cd arktos
make clean
make quick-release
```

1. kube-up to start admin cluster, start-kubemark to start kubemark cluster

```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ export KUBEMARK_NUM_NODES=500 NUM_NODES=6 SCALEOUT_TP_COUNT=1 RUN_PREFIX=etcd343-0312-1x500

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ export MASTER_DISK_SIZE=200GB MASTER_ROOT_DISK_SIZE=200GB KUBE_GCE_ZONE=us-central1-b MASTER_SIZE=n1-highmem-32 NODE_SIZE=n1-highmem-16 NODE_DISK_SIZE=200GB GOPATH=$HOME/go KUBE_GCE_ENABLE_IP_ALIASES=true KUBE_GCE_PRIVATE_CLUSTER=true CREATE_CUSTOM_NETWORK=true KUBE_GCE_INSTANCE_PREFIX=${RUN_PREFIX} KUBE_GCE_NETWORK=${RUN_PREFIX} ENABLE_KCM_LEADER_ELECT=false ENABLE_SCHEDULER_LEADER_ELECT=false ETCD_QUOTA_BACKEND_BYTES=8589934592 SHARE_PARTITIONSERVER=false LOGROTATE_FILES_MAX_COUNT=50 LOGROTATE_MAX_SIZE=200M KUBE_ENABLE_APISERVER_INSECURE_PORT=true KUBE_ENABLE_PROMETHEUS_DEBUG=true KUBE_ENABLE_PPROF_DEBUG=true TEST_CLUSTER_LOG_LEVEL=--v=2 HOLLOW_KUBELET_TEST_LOG_LEVEL=--v=2 SCALEOUT_CLUSTER=true KUBE_FEATURE_GATES=ExperimentalCriticalPodAnnotation=true,QPSDoubleGCController=true

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./cluster/kube-up.sh 

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./test/kubemark/start-kubemark.sh
```
If you have multi TP or multi RP server, KUBEMARK_NUM_NODES is the hollow-node number for each RP; NUM_NODES is the admin cluster physical VM number, should be OK to host your total hollow-node number.
```
export KUBEMARK_NUM_NODES=500 NUM_NODES=12 SCALEOUT_TP_COUNT=2 SCALEOUT_RP_COUNT=2 RUN_PREFIX=etcd343-0312-1x500
```

   Since Arktos PR 1001, an initial implementation of the secure GW is added(full feature will be per customer feedbacks) and secured communication channel is added in the Arktos performance testing env. Two control variables were added and the responsibilities are as follows:
   ```
   ## https://www.haproxy.com/documentation/hapee/2-2r1/deployment-guides/tls-infrastructure/
   ## currently only bridging and offloading is supported
   export HAPROXY_TLS_MODE=${HAPROXY_TLS_MODE:-"bridging"}
   
   ## controls the behavior of kubeconfig files
   ## true means kubeconfig files generated for insecure API server connections
   ## false is generated for secured API server connections
   export USE_INSECURE_SCALEOUT_CLUSTER_MODE="${USE_INSECURE_SCALEOUT_CLUSTER_MODE:-false}"
   ```
  For the bridging mode where both front end and backend are using secure connection. NO changes are needed in the below perf settings.
  For the offloading mode, set the HAPROXY_TLS_MODE="offloading"
  
2. Check clusters are ready
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ kubectl --kubeconfig=/home/sonyali/go/src/k8s.io/arktos/test/kubemark/resources/kubeconfig.kubemark.rp-1 get nodes | wc -l
502

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ls ./test/kubemark/resources
addons                            heapster_template.json              hollow-node.yaml           kubeconfig.kubemark-rp    kubemark-ns.json              start-kubemark-master.sh
cluster-autoscaler_template.json  hollow-node_template_scaleout.yaml  kernel-monitor.json        kubeconfig.kubemark-tp-1  manifests
haproxy.cfg.tmp                   hollow-node_template.yaml           kubeconfig.kubemark-proxy  kube_dns_template.yaml    start-kubemark-master-aws.sh
```

3. Create Tenants and run sanity test if necessary
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark.tp-1 create tenant arktos
setting storage cluster to 0
tenant/arktos created
```
Sanity test is to verify cluster basic function. these are optional for perf-test:
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark.tp-1 get pods -AT

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy get pods -AT

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark.tp-1 create tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy run sanitytest --image=nginx --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy get namespaces --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy get deployments --all-namespaces --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy scale deployment sanitytest --replicas=3 --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy get pods --all-namespaces --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy delete deployment sanitytest --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark-proxy get pods --all-namespaces --tenant aaaaa

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./_output/dockerized/bin/linux/amd64/kubectl --kubeconfig=./test/kubemark/resources/kubeconfig.kubemark.tp-1 delete tenant aaaaa
```

if SCALEOUT_TP_COUNT>1, then follow the steps above to create new tenant, for example: zeta

4. start perf-tests
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ SCALEOUT_TEST_TENANT=arktos RUN_NAME=etcd343-0312-1x500 TENANT_PERF_LOG_DIR=/home/sonyali/logs/perf-test/gce-500/arktos/${RUN_NAME}/${SCALEOUT_TEST_TENANT}

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ echo $TENANT_PERF_LOG_DIR 
/home/sonyali/logs/perf-test/gce-500/arktos/etcd343-0312-1x500/arktos

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ mkdir -p /home/sonyali/logs/perf-test/gce-500/arktos/etcd343-0312-1x500/arktos

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ SCALEOUT_TEST_TENANT=arktos RUN_NAME=etcd343-0312-1x500 TENANT_PERF_LOG_DIR=/home/sonyali/logs/perf-test/gce-500/arktos/${RUN_NAME}/${SCALEOUT_TEST_TENANT} nohup perf-tests/clusterloader2/run-e2e.sh --nodes=500 --provider=kubemark --kubeconfig=/home/sonyali/go/src/k8s.io/arktos/test/kubemark/resources/kubeconfig.kubemark-proxy --report-dir=${TENANT_PERF_LOG_DIR} --testconfig=testing/density/config.yaml --testconfig=testing/load/config.yaml --testoverrides=./testing/experiments/disable_pvs.yaml > ${TENANT_PERF_LOG_DIR}/perf-run.log  2>&1  &
```

if SCALEOUT_TP_COUNT>1, then open a new commandline windows, follow the steps above to start perf-test instance for each TP.  Please remember to update SCALEOUT_TEST_TENANT to your TP tenant name.  "--nodes" should be the number that assigned to this TP. For example: if you have totally 1000 hollow-nodes, 2 tp server, then "--nodes" should be 1000/2=500

5. Check and collect all logs
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ cd /home/sonyali/logs/perf-test/gce-500/arktos/etcd343-0312-1x500

sonyali@sonyadev4:~/logs/perf-test/gce-500/arktos/etcd343-0312-1x500$ ls
arktos

sonyali@sonyadev4:~/logs/perf-test/gce-500/arktos/etcd343-0312-1x500$ vi arktos/PodStartupLatency_PodStartupLatency_density_2021-03-10T02:34:30Z.json

sonyali@sonyadev4:~/logs/perf-test/gce-500/arktos/etcd343-0312-1x500$ export GCE_PROJECT=workload-controller-manager GCE_REGION=us-central1-b RUN_PREFIX=etcd343-0312-1x500 SCALEOUT_CLUSTER=true SCALEOUT_TP_COUNT=1

sonyali@sonyadev4:~/logs/perf-test/gce-500/arktos/etcd343-0312-1x500$ bash ~/arktos-tool/logcollection/logcollection.sh
```

6. after all run finished, shutdown cluster
```
sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./test/kubemark/stop-kubemark.sh 

sonyali@sonyadev4:~/go/src/k8s.io/arktos$ ./cluster/kube-down.sh
```
