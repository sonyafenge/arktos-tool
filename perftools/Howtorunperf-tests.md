Process under GCP project. Please remember perf-tests running on kubemark master, so all logs should be checked under /var/log/ on kubemark-master

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
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ export MASTER_ROOT_DISK_SIZE=100GB MASTER_DISK_SIZE=200GB KUBE_GCE_ZONE=europe-west2-b MASTER_SIZE=n1-highmem-32 NODE_SIZE=n1-highmem-8 NUM_NODES=8 NODE_DISK_SIZE=200GB KUBE_GCE_NETWORK=kubemark-500 GOPATH=$HOME/go KUBE_GCE_ENABLE_IP_ALIASES=true KUBE_GCE_PRIVATE_CLUSTER=true CREATE_CUSTOM_NETWORK=true KUBE_GCE_INSTANCE_PREFIX=kubemark-500 TEST_CLUSTER_LOG_LEVEL=--v=2 SHARE_PARTITIONSERVER=true APISERVERS_EXTRA_NUM=0 WORKLOADCONTROLLER_EXTRA_NUM=0 ETCD_EXTRA_NUM=0 KUBEMARK_NUM_NODES=500
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ ./cluster/kube-up.sh 
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ ./test/kubemark/start-kubemark.sh
```

2. ensure all hollow-nodes are ready
```
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ kubectl --kubeconfig=/home/sonyafenge/go/src/k8s.io/joeshao/arktos/test/kubemark/resources/kubeconfig.kubemark get nodes | wc -l
502
```

3. start perf-tests
```
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ export GOPATH=$HOME/go
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ nohup ./perf-tests/clusterloader2/run-e2e.sh --nodes=500 --provider=kubemark --kubeconfig=/home/sonyafenge/go/src/k8s.io/joeshao/arktos/test/kubemark/resources/kubeconfig.kubemark --report-dir=/home/sonyafenge/logs/perf-test/gce-500/arktos/0626-1apiserver --testconfig=testing/density/config.yaml --testconfig=testing/load/config.yaml 
```


5. after all run finished, shutdown cluster
```
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ export MASTER_ROOT_DISK_SIZE=100GB MASTER_DISK_SIZE=200GB KUBE_GCE_ZONE=europe-west2-b MASTER_SIZE=n1-highmem-32 NODE_SIZE=n1-highmem-8 NUM_NODES=8 NODE_DISK_SIZE=200GB KUBE_GCE_NETWORK=kubemark-500 GOPATH=$HOME/go KUBE_GCE_ENABLE_IP_ALIASES=true KUBE_GCE_PRIVATE_CLUSTER=true CREATE_CUSTOM_NETWORK=true KUBE_GCE_INSTANCE_PREFIX=kubemark-500 TEST_CLUSTER_LOG_LEVEL=--v=2 SHARE_PARTITIONSERVER=true APISERVERS_EXTRA_NUM=0 WORKLOADCONTROLLER_EXTRA_NUM=0 ETCD_EXTRA_NUM=0 KUBEMARK_NUM_NODES=500
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ ./test/kubemark/stop-kubemark.sh 
sonyafenge@sonyadev:~/go/src/k8s.io/joeshao/arktos$ ./cluster/kube-down.sh
```
