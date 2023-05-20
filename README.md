# Passthrough Single GPU, how to

## Prerequisites
Enable `virtualization` and `VT-d` in your BIOS

## Fedora prep instructions
First, ensure you're up to date:
```bash
sudo yum update
```

Setup virtualization with QEMU/KVM and iommu:
```bash
sudo yum groupinstall --with-optional virtualization
```
Setup grub:
```bash
sudo vi /etc/sysconfig/grub
```
Append `amd_iommu=on iommu=pt` to the `GRUB_CMDLINE_LINUX` entry
(_if you're on Intel, use_ `intel_iommu=on`)

Apply configuration changes:
```bash
sudo grub2-mkconfig -o /etc/grub2.cfg
```
Configure the boot process:
```bash
sudo vi /etc/dracut.conf.d/local.conf
```
Add the following line:
```bash
add_driver+=" vfio vfio_iommu_type1 vfio_pci vfio_virqfd "
```
Apply the changes
``` bash
sudo dracut -f --kver `uname -r`
```
Reboot, and  check that it worked:
```bash
lsmod | grep kvm
dmesg | grep -i iommu
cat /proc/cmdline
```
You should get results, signaling that the configuration was applied.

Ger hardware IDs by running
```bash
lspci -nnk
```

## Download prerequisite software:
 * [VirtIO drivers](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md).
 * [Windows](https://www.microsoft.com/software-download/windows11)

## Setup VM using virt-manager
 * Ensure you use the VNC display
   * Set it to listen to all addresses.
 * Configure your desired RAM and CPUs
 * Attach the `Guest OS` ISO
 * _Optional_: Remove your NIC if you don't want to sign in with a Microsoft Account.
 * Boot and install the OS
 * Shutdown the guest OS
 * _Optional_: Re-attach a NIC, if you previously removed it
 * Detach the Guest OS ISO
 * Attach the `VirtIO drivers` ISO
 * Attach a small `VirtIO` disk to the VM
 * Boot and install the VirtIO drivers.
 * Detach the `VirtIO` disk and the `VirtIO drivers` ISO
 * Shutdown the Guest OS
 * Configure the drive to use virtio (more faster, more better):
```xml
<disk type="file" device="disk">
  <driver name="qemu" type="qcow2" discard="unmap"/>
  <source file="/var/lib/libvirt/images/win11-1.qcow2"/>
  <target dev="sdc" bus="virtio"/>
  <boot order="2"/>
  <address type="pci" controller="0" bus="0" target="0" unit="2"/>
</disk>
```
 * Attach the GPU to the VM.

## Configure libvirt hooks
Download `VFIO-Tools`:
```bash
sudo mkdir -p /etc/libvirt/hooks
sudo wget https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu -O /etc/libvirt/hooks/qemu
sudo chmod +x /etc/libvirt/hooks/qemu
sudo service libvirtd restart
```
Configure hooks:
```bash
sudo mkdir -p /etc/libvirt/hooks/qemu.d/{vm_name}/prepare/begin
sudo mkdir -p /etc/libvirt/hooks/qemu.d/{vm_name}/release/end
sudo vi /etc/libvirt/hooks/qemu.d/{vm_name}/prepare/begin/start.sh
sudo chmod +x /etc/libvirt/hooks/qemu.d/{vm_name}/prepare/begin/start.sh
sudo vi /etc/libvirt/hooks/qemu.d/{vm_name}/release/end/revert.sh
sudo chmod +x /etc/libvirt/hooks/qemu.d/{vm_name}/release/end/revert.sh
```
Check the files in this repo for examples.

## First run
Starting the VM will disconnect the GPU, so **make sure** you have a VNC client setup somewhere on your network (like a phone, or another pc/laptop).

Get the IP of your host PC by running:
```bash
ip a
```

Start your VM, and connect to VNC using the IP obtained earlier. Download the appropriate GPU drivers and install them. 
If it's Windows 10 / 11, make sure you set the default display to **the other** display than the VNC one. 

## GREAT SUCCESS
```
★░░░░░░░░░░░████░░░░░░░░░░░░░░░░░░░░★
★░░░░░░░░░███░██░░░░░░░░░░░░░░░░░░░░★ 
★░░░░░░░░░██░░░█░░░░░░░░░░░░░░░░░░░░★ 
★░░░░░░░░░██░░░██░░░░░░░░░░░░░░░░░░░★ 
★░░░░░░░░░░██░░░███░░░░░░░░░░░░░░░░░★ 
★░░░░░░░░░░░██░░░░██░░░░░░░░░░░░░░░░★
★░░░░░░░░░░░██░░░░░███░░░░░░░░░░░░░░★
★░░░░░░░░░░░░██░░░░░░██░░░░░░░░░░░░░★ 
★░░░░░░░███████░░░░░░░██░░░░░░░░░░░░★
★░░░░█████░░░░░░░░░░░░░░███░██░░░░░░★
★░░░██░░░░░████░░░░░░░░░░██████░░░░░★
★░░░██░░████░░███░░░░░░░░░░░░░██░░░░★
★░░░██░░░░░░░░███░░░░░░░░░░░░░██░░░░★
★░░░░██████████░███░░░░░░░░░░░██░░░░★
★░░░░██░░░░░░░░████░░░░░░░░░░░██░░░░★
★░░░░███████████░░██░░░░░░░░░░██░░░░★
★░░░░░░██░░░░░░░████░░░░░██████░░░░░★
★░░░░░░██████████░██░░░░███░██░░░░░░★
★░░░░░░░░░██░░░░░████░███░░░░░░░░░░░★
★░░░░░░░░░█████████████░░░░░░░░░░░░░★
★░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░★
```
