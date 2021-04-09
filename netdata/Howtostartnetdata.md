1. Connect to the machine which need netdata and run the command below to start netdata docker:
```
docker run -d --name=netdata \
  -p 19999:19999 \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata
```
2. Edit Application config in netdata container:
    * “docker ps” to get container ID
    * docker exec -it  [container ID] /bin/sh
    * cd /etc/netdata
    * ./edit-config apps_groups.conf
    * Add the information below to “kubernetes” (around line #170)

```
# -----------------------------------------------------------------------------                                                                                              
# kubernetes                                                                                                                                                                 
                                                                                                                                                                             
kubelet: kubelet
kube-apiserver: kube-apiserver
etcd: etcd
kube-scheduler: kube-scheduler
kube-controller-manager: kube-controller-manager
workload-controller-manager: workload-controller-manager
kube-dns: kube-dns      

```

 
   * Exit container
   * docker stop [container ID]
   * docker start [container ID]
   * 
3. check Netdata: http://[machineIP]:19999. Ensure your machine or VPC/subnet has 19999 port opened. On GCE, you need add firewall rules to allow 19999 in cluster VPC.
