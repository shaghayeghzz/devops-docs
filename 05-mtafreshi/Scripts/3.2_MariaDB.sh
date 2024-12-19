#!/bin/bash

dev=/dev/
mount=/dev/myvg/mylv
path=/var/lib/mysql

check_root ()
{
    if [ `whoami` == "root" ]; then
        echo "you are login with Root User"
    else
        echo "Please Login "root" User and Run Script Agein." 
        exit 1
    fi
}

LVM ()
{
    dev=/dev/
    mount=/dev/myvg/mylv
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
    sed -i 's/.99//g' size
    vgdisplay myvg | grep -i "vg size" | awk '{print $4}' > size1
    sed -i 's/iB//g' size1
    lvcreate --name mylv --size ${size}${size1} myvg
    mkfs.ext4 ${mount}
    rm size size1 row file file{1..3}
}

install_mariadb ()
{
    path=/var/lib/mysql
    mkdir ${path}
    blkid ${mount} | awk '{print $2}' > uuid
    sed -i 's/UUID="//g' uuid
    sed -i 's/"//g' uuid
    echo "`cat uuid`  '${path}'  ext4    defaults 0 1" >> /etc/fstab
    mount -a
    if [ `echo $?` == 0 ]; then
        sudo apt update
        sudo apt install mariadb-server -y
    else
        echo "Check your Mount Point. "
        break
    fi
    rm uuid
}

#iptables ()

main ()
{
    check_root
    LVM
    install_mariadb
}
main