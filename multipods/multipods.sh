#!/usr/bin/env bash
echo "start deploying large scale pods... "
export DPPATH=${DPPATH:-}
export TENANTNAME=${TENANTNAME:-}
export PODSTOTAL=${PODSTOTAL:-"10"}
export PODSPERDP=${PODSPERDP:-"5"}
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
        local image=$3
		local tenantname=$4
        local filename="${name}.yaml"
        echo "${filename}, ${name}, ${image}, ${podsnumber}"
    cat <<EOF > ${filename}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "pods-${name}"
  namespace: "ns-${name}"
  tenant: ${tenantname}
spec:
  replicas: ${podsnumber}
  selector:
    matchLabels:
      app: "pods-${name}"
  template:
    metadata:
      labels:
        app: "pods-${name}"
    spec:
      containers:
      - name: "pods-${name}"
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
podspending=${PODSTOTAL}
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

while (("${podspending}" > 0)); do
        echo "pods pending num:${podspending}"
    randomname=$(uuidgen -r)
#       echo "randomname: ${randomname}"
        dpname="pods-${randomname}"
        nsname="ns-${randomname}"
        podsnum=${PODSPERDP}
        if (("${podspending}" <= "${podsnum}")) ; then
                podsnum=${podspending}
        fi
#       echo "${randomname}, ${dpname},${nsname}, ${podsnum}"
        create-dpyaml ${podsnum} ${randomname} ${PODSIMAGE} ${TENANTNAME}
        create-nsyaml ${nsname} ${TENANTNAME}
        echo $(kubectl apply -f ${nsname}.yaml ${kubeconfigoption})
        echo $(kubectl apply -f ${randomname}.yaml ${kubeconfigoption})
        podspending=$((${podspending}-${podsnum}))
done

