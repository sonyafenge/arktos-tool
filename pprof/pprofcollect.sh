#!/usr/bin/env bash

export DATETIME=${DATETIME:-}

function collectpprof {
        local ports=$1
        local name=$2
        local pproftype=$3
        echo "curl http://127.0.0.1:${ports}/debug/pprof/${pproftype} -o ${name}-${pproftype}-${DATETIME}.pprof"
        curl http://127.0.0.1:${ports}/debug/pprof/${pproftype} -o ${name}-${pproftype}-${DATETIME}.pprof
}




###############
#   main function
###############
if [[ -z "${DATETIME}" ]]; then
        echo "Please provide DATETIME to collect data!"
        exit 1
fi
mkdir ${DATETIME}
cd ${DATETIME}

COMPONENTS_PORTS=${COMPONENTS_PORTS:-"8080"}
COMPONENTS_NAME=${COMPONENTS_NAME:-"kube-apiserver"}
echo "Collecting kube-apiserver pprof"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "profile"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "heap"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "goroutine"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "mutex"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "block"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "threadcreate"

COMPONENTS_PORTS="2379"
COMPONENTS_NAME="etcd"
echo "Collecting etcd pprof"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "profile"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "heap"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "goroutine"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "mutex"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "block"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "threadcreate"

COMPONENTS_PORTS="10251"
COMPONENTS_NAME="kube-scheduler"
echo "Collecting kube-scheduler pprof"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "profile"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "heap"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "goroutine"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "mutex"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "block"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "threadcreate"



COMPONENTS_PORTS="10252"
COMPONENTS_NAME="kube-controller-manager"
echo "Collecting kube-controller-manager pprof"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "profile"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "heap"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "goroutine"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "mutex"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "block"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "threadcreate"


COMPONENTS_PORTS="10250"
COMPONENTS_NAME="kubelet"
echo "Collecting kubelet pprof"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "profile"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "heap"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "goroutine"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "mutex"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "block"
collectpprof ${COMPONENTS_PORTS} ${COMPONENTS_NAME} "threadcreate"
