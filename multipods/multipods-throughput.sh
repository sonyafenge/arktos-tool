#!/usr/bin/env bash
echo "start deploying large scale pods... "
export NODENUM=${NODENUM:-"500"}
export PODSPERNODE=${PODSPERNODE:-"30"}
export DPPATH=${DPPATH:-}
export TENANTNAME=${TENANTNAME:-"system"}
#export PODSTOTAL=${PODSTOTAL:-"10"}
export PODSPERDP=${PODSPERDP:-"10"}
export DPPERNAMESPACE=${DPPERNAMESPACE:-"15"}
export NSPERNODE=${NSPERNODE:-"15"}
export PODSIMAGE=${PODSIMAG:-"kahootali/counter:1.0"}
export CLEANUP=${CLEANUP:-"false"}
export KUBECONFILE=${KUBECONFILE:-}
function cleanup-yaml {
        echo "cleaning up all yaml"
        local kubeocnfigoption=${kubeocnfigoption:-}
        if [[ ! -z "${KUBECONFILE}" ]]; then
                kubeocnfigoption=" --kubeconfig=${KUBECONFILE}"
        fi
        for name in $(ls | grep .yaml); do
                echo $(kubectl delete -f ${name} ${kubeocnfigoption})
#               echo $(kubectl delete ns ns-${name::-5} ${kubeocnfigoption})
        done
        echo $(sudo rm *.yaml)
}

function create-dpyaml {
        local podsnumber=$1
        local name=$2
        local nsname=$3
        local image=$4
	local tenantname=$5
        local filename="${nsname}-${name}.yaml"
        echo "${podsnumber}, ${name}, ${nsname}, ${image}, ${tenantname},${filename}"
    cat <<EOF > ${filename}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "${name}-pods"
  namespace: "${nsname}"
  tenant: ${tenantname}
spec:
  replicas: ${podsnumber}
  selector:
    matchLabels:
      app: "${name}-pods"
  template:
    metadata:
      labels:
        app: "${name}-pods"
    spec:
      containers:
      - name: "${name}-pods"
        image: ${image}
EOF
}

function create-tenantyaml {
        local name=$1
        local filename="${name}.yaml"
    cat <<EOF > ${filename}
apiVersion: v1
kind: Tenant
metadata:
  name: "${name}"
EOF
}

function create-nsyaml {
        local nsname=$1
        local tenantname=$2
        local filename="${nsname}.yaml"
    cat <<EOF > ${filename}
apiVersion: v1
kind: Namespace
metadata:
  name: "${nsname}"
  tenant: "${tenantname}"
EOF
}


###############
#   main function
###############
if [[ -z "${DPPATH}" ]]; then
        echo "Please provide deployment yaml path!"
        exit 1
fi
cd ${DPPATH}
if [[ ${CLEANUP} == "true" ]]; then
        cleanup-yaml
        exit 1
fi

podsdeployed=0
podspending=$((ENODENUM * PODSPERNODE))
namespacenum=$((NODENUM / NSPERNODE))
kubeconfigoption=${kubeconfigoption:-}
if [[ ! -z "${KUBECONFILE}" ]]; then
    kubeconfigoption=" --kubeconfig=${KUBECONFILE}"
fi

echo "creating yaml and deploying pods"
echo "kubeconfig file: ${kubeconfigoption}"


if [[ ! -z "${TENANTNAME}" ]]; then
        echo "Creating Tenent: ${TENANTNAME}"
        create-tenantyaml ${TENANTNAME}
	echo $(kubectl apply -f ${TENANTNAME}.yaml ${kubeconfigoption})
        
fi

echo "total ns: ${namespacenum}"
for (( nsnum=0; nsnum<${namespacenum:-1}; nsnum++ )); do
        randomname=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w ${1:-32} | head -n 1)
        nsname="${randomname}-ns"
        create-nsyaml ${nsname} ${TENANTNAME}
        echo $(kubectl apply -f ${nsname}.yaml ${kubeconfigoption})
        for (( dpnum=0; dpnum<${DPPERNAMESPACE:-1}; dpnum++ )); do
                dpname="dp-${dpnum}"
                create-dpyaml ${PODSPERDP} ${dpname} ${nsname} ${PODSIMAGE} ${TENANTNAME}
                echo $(kubectl apply -f ${nsname}-${dpname}.yaml ${kubeconfigoption})
        done
done

