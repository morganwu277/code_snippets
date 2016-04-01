# virsh connec URI
virsh -c qemu+ssh://root@192.168.1.205/system?socket=/var/run/libvirt/libvirt-sock list --all

# shrink VM physical disk after delete files in the VM
```bash
$ cat /dev/zero > z;sync;sleep 3;sync;rm -f z
$ # VirtualBox
$ VBoxManage modifyhd /path/to/image.vdi --compact
$ # VMware
$ /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k xxx.vmdk 
```
