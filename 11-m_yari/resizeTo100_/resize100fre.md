 ## To extend a Logical Volume (LV) using 100% of the free space available on your SSD:
    1. To extend your Logical Volume to use 100% of the available free space in the Volume Group, use:
  ```bash
    lvextend -l +100%FREE /dev/VolumeGroupName/LogicalVolumeName
  ```
    2. After extending the Logical Volume, you must also resize the filesystem. For an ext4 filesystem, use:  
 ```bash
    resize2fs /dev/VolumeGroupName/LogicalVolumeName
  ```    

