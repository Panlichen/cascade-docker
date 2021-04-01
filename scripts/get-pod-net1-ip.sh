for pod_name in `kubectl get pod -o json | jq '.items' | jq '.[] | .metadata.name'`
do
    pod_name=`echo $pod_name | sed 's/\"//g'`
    echo $pod_name `kubectl get pod $pod_name -o json | jq '.spec.nodeName'`
    kubectl exec $pod_name -- ifconfig net1
done