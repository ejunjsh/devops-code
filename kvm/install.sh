# location for config files
config_dir=/opt/build_config
iso_name=`basename $ISO`

#copy the iso file to the target machine
Port=22

mac_prefix=`echo $OAM_MAC | awk -F: '{printf("%s:%s:%s:%s:%s\n", $1,$2,$3,$4,$5)}'`
mac_base=`echo $OAM_MAC | awk -F: '{print$6}'`
for id in 0 1 2 3 4 5
do
    eval VM_MAC$id="$mac_prefix:`expr $mac_base + $id`"
done

#shut down the old VM first
VMID=`ssh -q -p$Port ${VMServer} virsh list --all | grep ${VM_NAME} |awk '{print $1}'`
if [ -z "$VMID" ]
then
   echo "${VM_NAME} does not exist, create a new one."
elif [ "$VMID" = "-" ]
then
   echo "${VM_NAME} already exist, remove it."
   ssh -q -p$Port ${VMServer} virsh undefine ${VM_NAME}
   sleep 5
else
   echo "${VM_NAME} already exist and running, force power off and remove it."
   ssh -q -p$Port ${VMServer} virsh destroy ${VM_NAME}
   ssh -q -p$Port ${VMServer} virsh undefine ${VM_NAME}
fi

#clear
ssh -q -p$Port ${VMServer} rm -rf /kvm/images/${VM_NAME}/*

#prepare the vm descriptor
cp $config_dir/kvm.xml.template.sdd $config_dir/$VM_NAME.xml
sed -i "s/\[VMNAME\]/${VM_NAME}/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMUUID\]/`uuidgen`/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMIMG\]/\/kvm\/images\/$VM_NAME\/$VM_NAME.qcow2/g" $config_dir/$VM_NAME.xml
sed -i "s/\[PGDATAIMG\]/\/kvm\/images\/$VM_NAME\/pgdata.qcow2/g" $config_dir/$VM_NAME.xml
sed -i "s/\[PGARCHIMG\]/\/kvm\/images\/$VM_NAME\/pgarch.qcow2/g" $config_dir/$VM_NAME.xml
sed -i "s/\[MNBAKIMG\]/\/kvm\/images\/$VM_NAME\/mnbackup.qcow2/g" $config_dir/$VM_NAME.xml
sed -i "s/\[ISOIMG\]/\/kvm\/images\/$VM_NAME\/$iso_name/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMMAC_0\]/${VM_MAC0}/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMMAC_1\]/${VM_MAC1}/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMMAC_2\]/${VM_MAC2}/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMMAC_3\]/${VM_MAC3}/g" $config_dir/$VM_NAME.xml
sed -i "s/\[VMMAC_4\]/${VM_MAC4}/g" $config_dir/$VM_NAME.xml
ssh -q -p$Port ${VMServer} mkdir -p /kvm/images/$VM_NAME
scp -P$Port $config_dir/$VM_NAME.xml ${VMServer}:/kvm/images/$VM_NAME/$VM_NAME.xml

#prepare the disk
ssh -q -p$Port ${VMServer} qemu-img create -f qcow2 /kvm/images/${VM_NAME}/${VM_NAME}.qcow2 70G
ssh -q -p$Port ${VMServer} qemu-img create -f qcow2 /kvm/images/${VM_NAME}/pgdata.qcow2 20G
ssh -q -p$Port ${VMServer} qemu-img create -f qcow2 /kvm/images/${VM_NAME}/pgarch.qcow2 20G
ssh -q -p$Port ${VMServer} qemu-img create -f qcow2 /kvm/images/${VM_NAME}/mnbackup.qcow2 20G

#copy the iso
scp -P$Port $ISO ${VMServer}:/kvm/images/${VM_NAME}/

#start a new VM
ssh -q -p$Port ${VMServer} virsh define /kvm/images/$VM_NAME/$VM_NAME.xml
ssh -q -p$Port ${VMServer} virsh start $VM_NAME