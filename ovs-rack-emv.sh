 sudo qemu-system-x86_64 -vnc :27 \
		-enable-kvm -smp 8 -m 16384 \
		-drive file=/home/chix/kvm/ovs-rack-emv.img,if=virtio \
		-net nic,macaddr=00:00:00:00:10:01,vlan=1 \
		-net tap,vhost=on,id=vnic1,script=/home/chix/kvm/ovs-if-script/ovs-ifup1,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown1,vlan=1 \
		-net nic,macaddr=00:00:00:00:11:01,vlan=2 \
		-net tap,vhost=on,id=vnic2,script=/home/chix/kvm/ovs-if-script/ovs-ifup2,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown2,vlan=2 \
		-net nic,macaddr=00:11:22:33:44:55,vlan=3 \
		-net tap,vhost=on,id=vnic3,script=/home/chix/kvm/pub-if-script/pub-ifup,downscript=/home/chix/kvm/pub-if-script/pub-ifdown,vlan=3
