#!/bin/bash

#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

echo "Updating system, it may take a while..."

apt -y update
apt -y upgrade
apt -y install git sshpass ntpdate screen vim-nox python3-pip nfs-kernel-server slurm-wlm munge openmpi-bin openmpi-common libopenmpi3 libopenmpi-dev build-essential

echo "Cloning Github repo.."
git clone --recursive https://github.com/sayanadhikari/wipi.git
cd wipi
git checkout automated
chown -R pi:pi /home/pi/wipi
cd /home/pi/wipi/deployment/config_data/master

hostname master
cp hostname /etc/hostname
cp hosts /etc/hosts
# Back to home dir
cd

echo "Setting up system locale and keyboards"
timezone=US/Eastern
timedatectl set-timezone $timezone

# Setting up NFS share
echo "Setting up NFS share"

mkdir -p /shared_dir
chown nobody.nogroup -R /shared_dir
chmod 777 -R /shared_dir

#In our case, the main partition of the external storage is mounted at /dev/sda1
# Before, using it as a NFS drive, we need to format it properly in ext4 file system.

echo -e "y\n" | mkfs.ext4 /dev/sda1

## Remember to replace the long ID-number given below with your own received from "blkid" command
UUID=$(blkid -o value -s UUID /dev/sda1)
echo "UUID=${UUID} /shared_dir ext4 defaults 0 2" >> /etc/fstab

mount -a

echo "/shared_dir 10.10.0.0/24(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports

exportfs -a

echo "Rebooting system, please wait ...."
reboot
# sudo mount --bind /home/shared_dir/ /home/shared_dir/
# echo '/home/shared_dir  /home/shared_dir   none   bind  0 0' >>/etc/fstab
# if grep -Fxq "NEED_SVCGSSD=" /etc/default/nfs-kernel-server
# then
#     echo "SVCGSSD exists"
# else
#     echo 'NEED_SVCGSSD=no' >>/etc/default/nfs-kernel-server
# fi
