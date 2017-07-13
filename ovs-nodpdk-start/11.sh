 sudo qemu-system-x86_64 -vnc :11 \\n
		-enable-kvm -smp 8 -m 16384 \\n
		-drive file=/home/chix/kvm/image/image-11.img,if=virtio \\n
		-net nic,macaddr=00:00:00:00:10:11,vlan=1 \\n
		-net tap,vhost=on,id=vnic1,script=/home/chix/kvm/ovs-if-script/ovs-ifup1,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown1,vlan=1 \\n
		-net nic,macaddr=00:00:00:00:11:11,vlan=2 \\n
		-net tap,vhost=on,id=vnic2,script=/home/chix/kvm/ovs-if-script/ovs-ifup2,downscript=/home/chix/kvm/ovs-if-script/ovs-ifdown2,vlan=2 \\n
		-display sdl -vga std \
