#! /bin/bash

lspci | grep Mellanox | awk '{print $1}' > pci_ids.txt
i=0
for pciid in `cat pci_ids.txt`
do
    ca_name=`ls /sys/bus/pci/devices/0000:${pciid}/infiniband/`
    iface=`ls /sys/bus/pci/devices/0000:${pciid}/infiniband/${ca_name}/device/net/`
    mac=`cat /sys/bus/pci/devices/0000:${pciid}/infiniband/${ca_name}/device/net/${iface}/address`
    echo "sudo ip link set eno50 vf $i mac ${mac}" 
    sudo ip link set eno50 vf $i mac ${mac} # set VF admin mac
    echo "0000:${pciid} ${ca_name} ${iface} ${mac}" >> VF_info_temp.txt

    
    sudo echo 0000:${pciid} > /sys/bus/pci/drivers/mlx5_core/unbind # unbind VF driver
    i=$((${i} + 1))
done

sudo echo "" > /sys/bus/pci/drivers/mlx5_core/bind # bind VF driver
column -t VF_info_temp.txt | cat
rm pci_ids.txt VF_info_temp.txt