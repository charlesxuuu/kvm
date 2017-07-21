 sudo qemu-system-x86_64 -vnc :2\
		-enable-kvm -smp 8 -m 16384 \
		-drive file=/home/chix/kvm/ovs-template2.img,if=virtio \
		-device virtio-net-pci,mac=00:00:00:00:10:01,netdev=vnic1 \
		-netdev type=tap,vhost=on,id=vnic1,script=/home/chix/kvm/ovs-if-script/ovs-ifup1,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown1 \
		-device virtio-net-pci,mac=00:00:00:00:11:01,netdev=vnic2 \
		-netdev type=tap,vhost=on,id=vnic2,script=/home/chix/kvm/ovs-if-script/ovs-ifup2,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown2 \
		-device virtio-net-pci,mac=00:00:00:00:12:01,netdev=vnic3 \
		-netdev type=tap,vhost=on,id=vnic3,script=/home/chix/kvm/pub-if-script/pub-ifup,downscript=/home/chix/kvm/pub-if-script/pub-ifdown \
