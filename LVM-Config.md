***add a new disk to LVM***

```bash
pvscan
#This will show you the current physical volumes.
sudo fdisk -l
fdisk /dev/sdb
#Add the disk to your machine as a primary partition. Partition type: “
8e
#(LVM)”. Obviously
pvcreate /dev/sdb1
This creates a new physical LVM volume on our new disk.
vgextend ubuntu-vg /dev/sdb1
pvscan
lvextend -L+20G /dev/ubuntu-vg/ubuntu-lv
lvm vgchange -a y  #This command makes your LVM volumes accessible.
e2fsck -f /dev/mapper/ubuntu--vg-ubuntu--lv #Run a file system check, the -f flag seems necessary. No idea what we do if the returns an error?
resize2fs /dev/VolGroup00/LogVol00
Without any parameters resize2fs will just increase the file system to the max space available.
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv #
#Reboot and your root partition is now 40GB lager, spanning multiple disks. Yay.
```
</br>
