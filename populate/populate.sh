#!/bin/bash
#run with sudo
#populate VM image
#step1: copy VM image
#step2: copy start command
#step3: modify VM image 

START=11
END=12
KVMDIR=/home/chix/kvm
DPDKDIR=/home/chix/dpdk
QEMUDIR=/home/chix/qemu-2.9.0



#require ovs-template.img (qcow2)

if [ ! -d "/home/chix/kvm/image" ]; then
  mkdir -p /home/chix/kvm/image
fi
if [ ! -d "/home/chix/kvm/linux-bridge-start" ]; then
  mkdir -p /home/chix/kvm/linux-bridge-start
  echo "#!/bin/bash\n" > /home/chix/kvm/linux-bridge-start/start-vm-all.sh
fi
if [ ! -d "/home/chix/kvm/ovs-dpdk-start" ]; then
  mkdir -p /home/chix/kvm/ovs-dpdk-start
  echo "#!/bin/bash\n" > /home/chix/kvm/ovs-dpdk-start/start-vm-all.sh
fi
if [ ! -d "/home/chix/kvm/ovs-nodpdk-start" ]; then
  mkdir -p /home/chix/kvm/ovs-nodpdk-start
  echo "#!/bin/bash\n" > /home/chix/kvm/ovs-nodpdk-start/start-vm-all.sh
fi
if [ ! -d "/mnt/kvm-image" ]; then
  mkdir -p /mnt/kvm-image
fi


for ((cur=$START; cur<=$END; cur++))
do	
  echo "Start to copy Image $cur"
  #cp /home/chix/kvm/ovs-template.img /home/chix/kvm/image/image-$cur.img
  echo "Finish copying Image $cur"
  
  echo "start to copy kvm ovs dpdk scripts for VM $cur"

	echo "sudo /home/chix/qemu-2.9.0/x86_64-softmmu/qemu-system-x86_64 -vnc :$cur \\\n
		-enable-kvm -smp 8 -m 16384 \\\n
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\\n
		-object memory-backend-file,id=mem,size=16384M,mem-path=/dev/hugepages,share=on \\\n
		-numa node,memdev=mem -mem-prealloc \\\n
		-chardev socket,id=char1,path=$DPDKDIR/socket/vhost-client-$cur-1,server \\\n
		-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \\\n
		-device virtio-net-pci,mac=00:00:00:00:10:$cur,netdev=mynet1 \\\n
		-chardev socket,id=char2,path=$DPDKDIR/socket/vhost-client-$cur-2,server \\\n
		-netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce \\\n
		-device virtio-net-pci,mac=00:00:00:00:11:$cur,netdev=mynet2 \\\n" > $KVMDIR/ovs-dpdk-start/$cur.sh


  echo "start to copy kvm ovs nodpdk scripts for VM $cur"

	 echo " sudo qemu-system-x86_64 -vnc :$cur \\\n
		-enable-kvm -smp 8 -m 16384 \\\n
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\\n
		-net nic,macaddr=00:00:00:00:10:$cur,vlan=1 \\\n
		-net tap,vhost=on,id=vnic1,script=$KVMDIR/ovs-if-script/ovs-ifup1,downscript=$KVMDIR/ovs-if-script/ovs-ifdown1,vlan=1 \\\n
		-net nic,macaddr=00:00:00:00:11:$cur,vlan=2 \\\n
		-net tap,vhost=on,id=vnic2,script=$KVMDIR/ovs-if-script/ovs-ifup2,downscript=$KVMDIR/ovs-if-script/ovs-ifdown2,vlan=2 \\\n
		-display sdl -vga std \\" > $KVMDIR/ovs-nodpdk-start/$cur.sh


  echo "start to copy kvm linux bridge scripts for VM $cur"

	  echo " sudo qemu-system-x86_64 -vnc :$cur \\\n
		-enable-kvm -smp 8 -m 16384 \\\n
		-drive file=$KVMDIR/image/image-$cur.img,if=virtio \\\n
		-net nic,macaddr=00:00:00:00:10:$cur,vlan=1 \\\n
		-net tap,vhost=on,id=vnic1,script=$KVMDIR/lb-if-script/lb-ifup1,downscript=$KVMDIR/lb-if-script/lb-ifdown1,vlan=1 \\\n
		-net nic,macaddr=00:00:00:00:11:$cur,vlan=2 \\\n
		-net tap,vhost=on,id=vnic2,script=$KVMDIR/lb-if-script/lb-ifup2,downscript=$KVMDIR/lb-if-script/lb-ifdown2,vlan=2 \\\n
		-display sdl -vga std \\" > $KVMDIR/linux-bridge-start/$cur.sh

	
  echo "start to mount VM image..."

  modprobe nbd
  lsmod | grep nbd
  $QEMUDIR/qemu-nbd -c /dev/nbd0 $KVMDIR/image/image-$cur.img
  mount /dev/nbd0p1 /mnt/kvm-image

  #modify /etc/hostname  
  echo "openvswitch$cur" > /mnt/kvm-image/etc/hostname
  #modify /etc/hosts
  sed -i "2s/.*/127.0.1.1\topenvswitch$cur/" /mnt/kvm-image/etc/hosts
  #modify /etc/network/interfaces
  sed -i "5s/.*/address 192.168.100.1$cur/" /mnt/kvm-image/etc/network/interfaces
  sed -i "12s/.*/address 192.168.101.1$cur/" /mnt/kvm-image/etc/network/interfaces
  #disconnect
  
  sleep 1
  umount /mnt/kvm-image/
  $QEMUDIR/qemu-nbd -d /dev/nbd0


  echo "bash $cur.sh\n" >> /home/chix/kvm/linux-bridge-start/start-vm-all.sh

  echo "bash $cur.sh\n" >> /home/chix/kvm/ovs-dpdk-start/start-vm-all.sh
  
  echo "bash $cur.sh\n" >> /home/chix/kvm/ovs-nodpdk-start/start-vm-all.sh

	
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

