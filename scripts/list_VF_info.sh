if [ -f "VF_info.txt" ]; then
  rm VF_info.txt
fi

lspci | grep Mellanox | awk '{print $1}' > pci_ids.txt
for pciid in `cat pci_ids.txt`
do
    ca_name=`ls /sys/bus/pci/devices/0000:${pciid}/infiniband/`
    iface=`ls /sys/bus/pci/devices/0000:${pciid}/infiniband/${ca_name}/device/net/`
    mac=`cat /sys/bus/pci/devices/0000:${pciid}/infiniband/${ca_name}/device/net/${iface}/address`
    echo "0000:${pciid} ${ca_name} ${iface} ${mac}" >> VF_info_temp.txt
done
column -t VF_info_temp.txt | cat
rm pci_ids.txt VF_info_temp.txt