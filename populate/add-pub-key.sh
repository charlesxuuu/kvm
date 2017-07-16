#!/bin/bash
#run with sudo
#add pubkey

START=11
END=40
KVMDIR=/home/chix/kvm
DPDKDIR=/home/chix/dpdk
QEMUDIR=/home/chix/qemu-2.9.0



modprobe nbd
lsmod | grep nbd

for ((cur=$START; cur<=$END; cur++))
do	
  echo "add Key to Image $cur"  

  $QEMUDIR/qemu-nbd -c /dev/nbd0 $KVMDIR/image/image-$cur.img
  sleep 1
  mount /dev/nbd0p1 /mnt/kvm-image

  #modify /etc/hostname  
  #modify /etc/hosts
  cp /home/chix/kvm/populate/sshkey/authorized_keys /mnt/kvm-image/home/chix/.ssh/
  #disconnect
  sleep 1
  umount /mnt/kvm-image/
  sleep 1
  $QEMUDIR/qemu-nbd -d /dev/nbd0

done

