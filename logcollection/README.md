How to use example:
```
export GCE_PROJECT=workload-controller-manager GCE_REGION=us-west2-b RUN_PREFIX=daily010621-1a0w1e SCALEOUT_CLUSTER=true SCALEOUT_TP_COUNT=1
bash logcollection.sh
```

You can also add your own server name if you have any additional servers:
```
### add your own server information
### collect TP master logs
MACHINE_NAME="${RUN_PREFIX}-kubemark-tp-1-master"
dir="tp_1_master"
collectlogs $dir
```
