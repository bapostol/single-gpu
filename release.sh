#!/bin/bash
set -x
  
# Re-Bind GPU to the display driver
virsh nodedev-reattach pci_0000_0b_00_3
virsh nodedev-reattach pci_0000_0b_00_2
virsh nodedev-reattach pci_0000_0b_00_1
virsh nodedev-reattach pci_0000_0b_00_0

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console.
#Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

# echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Restart Display Manager
systemctl start display-manager.service
