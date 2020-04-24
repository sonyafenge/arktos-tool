how to use example:
```
export PODSTOTAL=400 PODSPERDP=200 PODSIMAGE="gcr.io/google_samples/gb-frontend:v3"  DPPATH=~/dpyamlpath/ KUBECONFILE=~/go/src/k8s.io/arktos/test/kubemark/resources/kubeconfig.kubemark
```

multipods-prealkaid.sh.   #####for prealkaid
multipods.sh                       #####for arktos with default talents


check 
kubectl get pods --all-namespaces --field-selector=status.phase=Running --kubeconfig=~/go/src/k8s.io/arktos/test/kubemark/resources/kubeconfig.kubemark | wc -l
