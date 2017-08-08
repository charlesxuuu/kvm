#!/bin/bash
#run with sudo
#populate VM image
#step1: copy VM image
#step2: copy start command
#step3: modify VM image 

START=11
END=22
KVMDIR=/home/chix/kvm
DPDKDIR=/home/chix/dpdk
QEMUDIR=/home/chix/qemu-2.9.0



#require template-new.img (qcow2)

if [ ! -d "/home/chix/kvm/image" ]; then
  mkdir -p /home/chix/kvm/image
fi
if [ ! -d "/home/chix/kvm/linux-bridge-start" ]; then
  mkdir -p /home/chix/kvm/linux-bridge-start
fi
if [ ! -d "/home/chix/kvm/ovs-dpdk-start" ]; then
  mkdir -p /home/chix/kvm/ovs-dpdk-start
fi
if [ ! -d "/home/chix/kvm/ovs-nodpdk-start" ]; then
  mkdir -p /home/chix/kvm/ovs-nodpdk-start
fi
if [ ! -d "/mnt/kvm-image" ]; then
  mkdir -p /mnt/kvm-image
fi

#clear original start-vm-all.sh
rm -rf /home/chix/kvm/image/*

rm -rf /home/chix/kvm/linux-bridge-start/*

rm -rf /home/chix/kvm/ovs-dpdk-start/*

rm -rf /home/chix/kvm/ovs-nodpdk-start/*

modprobe nbd
lsmod | grep nbd

for ((cur=$START; cur<=$END; cur++))
do	
  echo "Start to copy Image $cur"
  cp /home/chix/kvm/template-new.img /home/chix/kvm/image/image-$cur.img
  echo "Finish copying Image $cur"
  
  echo "start to copy kvm ovs dpdk scripts for VM $cur"

	echo "sudo /home/chix/qemu-2.9.0/x86_64-softmmu/qemu-system-x86_64 -vnc :$cur \\
		-enable-kvm -smp 8 -m 16384 \\
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\
		-object memory-backend-file,id=mem,size=16384M,mem-path=/dev/hugepages,share=on \\
		-numa node,memdev=mem -mem-prealloc \\
		-chardev socket,id=char1,path=$DPDKDIR/socket/vhost-client-$cur-1,server \\
		-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \\
		-device virtio-net-pci,mac=00:00:00:00:10:$cur,netdev=mynet1 \\
		-chardev socket,id=char2,path=$DPDKDIR/socket/vhost-client-$cur-2,server \\
		-netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce \\
		-device virtio-net-pci,mac=00:00:00:00:11:$cur,netdev=mynet2" > $KVMDIR/ovs-dpdk-start/$cur.sh


	
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

  echo  "start to mount VM image..."


  $QEMUDIR/qemu-nbd -c /dev/nbd0 $KVMDIR/image/image-$cur.img
  sleep 1
  mount /dev/nbd0p1 /mnt/kvm-image

  #modify /etc/hostname  
  echo "openvswitch$cur" > /mnt/kvm-image/etc/hostname
  #modify /etc/hosts
  sed -i "2s/.*/127.0.1.1\topenvswitch$cur/" /mnt/kvm-image/etc/hosts
  #modify /etc/network/interfaces
  sed -i "7s/.*/  address 192.168.100.1$cur/" /mnt/kvm-image/etc/network/interfaces
  sed -i "14s/.*/  address 192.168.101.1$cur/" /mnt/kvm-image/etc/network/interfaces
  #disconnect
  
  sleep 1
  umount /mnt/kvm-image/
  sleep 1
  $QEMUDIR/qemu-nbd -d /dev/nbd0

  echo "bash $cur.sh &" >> /home/chix/kvm/linux-bridge-start/start-vm-all.sh

  echo "bash $cur.sh &" >> /home/chix/kvm/ovs-dpdk-start/start-vm-all.sh
  
  echo "bash $cur.sh &" >> /home/chix/kvm/ovs-nodpdk-start/start-vm-all.sh

	
#  for ((t=0; t<=0; t++))
#  do
#    echo ${protm1[$r]} ${protm2[$r]} ${protm3[$r]} ${protm4[$r]}
#    ssh -f -n root@192.168.0.4 "./myiperf machine1 ${protm1[$r]} $TIME 100 $r" &
#    ssh -f -n root@192.168.0.5 "./myiperf machine2 ${protm2[$r]} $TIME 100 $r" &
#    ssh -f -n root@192.168.0.6 "./myiperf machine3 ${protm3[$r]} $TIME 100 $r" &
#    ssh -f -n root@192.168.0.7 "./myiperf machine4 ${protm4[$r]} $TIME 100 $r" &
#      #wait until the loop end	
#      sleep $[$TIME+5]
#  done
done

