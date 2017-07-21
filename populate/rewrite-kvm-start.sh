#!/bin/bash
#run with sudo
#populate VM image
#step1: copy VM image
#step2: copy start command
#step3: modify VM image 

START=11
END=40
KVMDIR=/home/chix/kvm
DPDKDIR=/home/chix/dpdk
QEMUDIR=/home/chix/qemu-2.9.0


#clear original start-vm-all.sh
rm -rf /home/chix/kvm/linux-bridge-start/start-vm-all.sh

rm -rf /home/chix/kvm/ovs-nodpdk-start/start-vm-all.sh


for ((cur=$START; cur<=$END; cur++))
do	
  


  echo "start to copy kvm ovs nodpdk scripts for VM $cur"

	 echo " sudo qemu-system-x86_64 -vnc :$cur \\
		-enable-kvm -smp 8 -m 16384 \\
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\
		-device virtio-net-pci,mac=00:00:00:00:10:$cur,netdev=vnic1 \\
		-netdev type=tap,vhost=on,id=vnic1,script=$KVMDIR/ovs-if-script/ovs-ifup1,downscript=$KVMDIR/ovs-if-script/ovs-ifdown1 \\
		-device virtio-net-pci,mac=00:00:00:00:11:$cur,netdev=vnic2 \\
		-netdev type=tap,vhost=on,id=vnic2,script=$KVMDIR/ovs-if-script/ovs-ifup2,downscript=$KVMDIR/ovs-if-script/ovs-ifdown2" > $KVMDIR/ovs-nodpdk-start/$cur.sh


  echo "start to copy kvm linux bridge scripts for VM $cur"

	  echo " sudo qemu-system-x86_64 -vnc :$cur \\
		-enable-kvm -smp 8 -m 16384 \\
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\
		-device virtio-net-pci,mac=00:00:00:00:10:$cur,netdev=vnic1 \\
                -netdev type=tap,vhost=on,id=vnic1,script=$KVMDIR/lb-if-script/lb-ifup1,downscript=$KVMDIR/lb-if-script/lb-ifdown1 \\
		-device virtio-net-pci,mac=00:00:00:00:11:$cur,netdev=vnic2 \\
                -netdev type=tap,vhost=on,id=vnic2,script=$KVMDIR/lb-if-script/lb-ifup2,downscript=$KVMDIR/lb-if-script/lb-ifdown2" > $KVMDIR/linux-bridge-start/$cur.sh

	
  echo "bash $cur.sh &" >> /home/chix/kvm/linux-bridge-start/start-vm-all.sh

  echo "bash $cur.sh &" >> /home/chix/kvm/ovs-nodpdk-start/start-vm-all.sh

	
done

