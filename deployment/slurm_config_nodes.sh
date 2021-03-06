#!/bin/bash

#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

echo "Configuring SLURM on master node"

wipi_repo=/home/pi/wipi
cp $wipi_repo/deployment/slurm_config/* /etc/slurm-llnl/

echo "Copying munge key to the shared directory"
cp /shared_dir/munge.key /etc/munge/munge.key

echo "Add a new group named admin and add pi to it"
groupadd admin
usermod -a -G admin pi

echo "Adding admin group to sudoes file"
echo "%admin	ALL=(ALL) ALL" >>/etc/sudoers
echo "%admin	ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

echo "Enable and start SLURM Control Services and munge"
systemctl enable munge
systemctl start munge

systemctl enable slurmd
systemctl start slurmd


echo "Rebooting system, please wait ...."
reboot
