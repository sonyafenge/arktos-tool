This can be done from the master node. come to think of it, it may be better to put this on a non-master node to reduce the load of the master.
1. cd /etc/srv/kubernetes
2. get prometheus
export RELEASE="2.2.1"
wget https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz
tar xvf prometheus-${RELEASE}.linux-amd64.tar.gz
cd prometheus-2.2.1.linux-amd64/
3. write config file
root@ip-172-31-27-32:/home/ubuntu# cat /tmp/prometheus-metric.yaml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: prometheus-metric
    static_configs:
    - targets: ['127.0.0.1:2379','127.0.0.1:8080']
3. run prometheus
./prometheus --config.file="/tmp/prometheus-metric.yaml" --web.listen-address=":9090" --web.enable-admin-api


PLease also ensure apiserver insecure port 8080 is enabled before start cluster: https://github.com/sonyafenge/arktos/commit/530ac5ff89f3e158177f4b7d78bc22d02c095714 
To access the metrics, make sure port 9090 is enabled on the host, and then head to browser and do
http://[host ip]:9090/



You can also save snapshot for Prometheus data: 
```
$ curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot
{
  "status": "success",
  "data": {
    "name": "20171210T211224Z-2be650b6d019eb54"
  }
}
```
and then start your own prometheus server by the command below:
```
sonyali@sonyadev4:~/tools/prometheus-2.2.1.linux-amd64$ ./prometheus  --web.listen-address=":9090" --storage.tsdb.path /home/sonyali/logs/perf-test/gce-5000/arktos/0924-morelog-1a0w1e/logs/crashed/kubemarkmaster/promethues/snapshots/20200925T141700Z-59ebb5530a34d031
```
