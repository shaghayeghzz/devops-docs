#!/bin/bash

LVM ()
{
    dev=/dev/
    echo "Recomended You Have to 3 Disk for Create LVM. :) !~ "
    sudo lsblk
    sleep 5
    read -p "How many Disk to Create Partition? " num
    for (( i=1; i<=${num}; i++ ));
        do
            read -p "Select HDD Name: (Example: sdb)" blk
            (echo n; echo p; echo ""; echo ""; echo ""; echo t; echo 8E; echo w) | fdisk /dev/${blk}
            echo ''${blk}''1'' > file"${i}"
            echo ''${dev}''${blk}''1'' >> file
        done
    sudo lsblk
    sleep 5
    paste -s -d " " file > row
    pvcreate `cat row`
    vgcreate myvg `cat row`
    vgdisplay myvg | grep -i "vg size" | awk '{print $3}' > size
    sed -i 's/<//g' size
    vgdisplay myvg | grep -i "vg size" | awk '{print $4}' > size1
    sed -i 's/iB//g' size1
    lvcreate --name mylv --size ${size}${size1} myvg
    rm size size1 row
}