#! /bin/bash

# get pod ips and names
kubectl get pod -o wide | grep cascade | cat > info.txt 
IPs=`awk '/cascade/ {print $6}' info.txt`
PODs=`awk '/cascade/ {print $1}' info.txt`
IP_ARRAY=()
POD_ARRAY=()

LEADER_IP=""

# set first pod to be leader; store pod ips and names into array
idx=0
for IP in ${IPs}
do 
  if [ ${idx} = 0 ]; then
    LEADER_IP=${IP}
  fi
  IP_ARRAY[${idx}]=$IP
  idx=$[idx+1]
done
idx=0
for POD in ${PODs}
do 
  POD_ARRAY[${idx}]=$POD
  idx=$[idx+1]
done

for (( i=0; i<${#IP_ARRAY[*]}; i++ )); do
  vf_ca=`kubectl exec ${POD_ARRAY[${i}]} -- ibv_devices | awk '/mlx/ {print $1}'`

  cmd="kubectl exec -it ${POD_ARRAY[${i}]} \
  -- /root/scripts/config-cascade.sh ${LEADER_IP} ${IP_ARRAY[${i}]} ${i} verbs ${vf_ca}"
  echo $cmd
  $cmd
  
done

rm info.txt