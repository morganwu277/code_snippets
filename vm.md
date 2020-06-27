
# netsted VM using VirutalBox under macOS
1. make sure you have latest VirtualBox, (6.1 version will support Intel CPU however, 6.0 only support AMD)
2. make sure you have `VMX` flag under next command output:
```
(py3) ➜  ~ sysctl -a | grep machdep.cpu.features
machdep.cpu.features: FPU VME DE PSE TSC MSR PAE MCE CX8 APIC SEP MTRR PGE MCA CMOV PAT PSE36 CLFSH DS ACPI MMX FXSR SSE SSE2 SS HTT TM PBE SSE3 PCLMULQDQ DTES64 MON DSCPL VMX SMX EST TM2 SSSE3 FMA CX16 TPR PDCM SSE4.1 SSE4.2 x2APIC MOVBE POPCNT AES PCID XSAVE OSXSAVE SEGLIM64 TSCTMR AVX1.0 RDRAND F16C
```
3. enable netsted VMX using next command, `jsLinux_default_1593226310353_19294` is your VirtualBoxVMName
```
VBoxManage modifyvm jsLinux_default_1593226310353_19294 --nested-hw-virt on
```
4. follow https://computingforgeeks.com/how-to-install-kvm-on-fedora/ to install KVM inside

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
