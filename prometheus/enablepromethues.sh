#!/usr/bin/env bash


function create-prometheus-metrics {
  echo "configing prometheus-metrics"
  cat <<EOF >/tmp/prometheus-metrics.yaml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: prometheus-metrics
    static_configs:
    - targets: ['127.0.0.1:2379','127.0.0.1:8080']
EOF
}



###############
#   main function
###############

cd /etc/srv/kubernetes
# downloading prometheus
export RELEASE="2.2.1"
wget https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz
tar xvf prometheus-${RELEASE}.linux-amd64.tar.gz
cd prometheus-2.2.1.linux-amd64/

create-prometheus-metrics

./prometheus --config.file="/tmp/prometheus-metrics.yaml" --web.listen-address=":9090" --web.enable-admin-api

