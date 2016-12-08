# bash-rsnapshot

is a collection of script for backuping things on linux computers.

The initial idea is to backup on external drives with the ability to rotate the disks.


rsnapshot.sh
----------------

bash script that mount an external usb device with its uuid and run rsnapshot.

**installation**

  install rsnapshot and configure it.

  snapshot_root must reflect -p parameter

**usage**

rsnapshot.sh -u [device_UUID] -r [rsnapshot_category]

options are:

-p [mount_path]

or

-a to automatically fetch the path from /etc/rsnapshot.conf




**Crontab sample**

    0       *     *       *       *       bash rsnapshot.sh -u 5be75f53-44d0-4e10-bccc-ef30872e7951 -r hourly -a
    0       0     *       *       *       bash rsnapshot.sh -u 5be75f53-44d0-4e10-bccc-ef30872e7951 -r daily -a



For disk rotation simply duplicate the crontab lines with the second uuid

**Log**

minimal output to syslog

**TODO**

inotify option and run as daemon option

tar.sh
----------------
bash script that mount an external usb device with its uuid and make a TAR archive of a folder.



mysqldump.sh
----------------

bash script that mount an external usb device with its uuid or a network mount and run mysqldump

**requirements**

Mysql client and mysqldump are required.

**installation**
create a file in /root named .my.cnf with the following content

    [mysqldump]
    user=yourusername
    password=yourpassword
    host=127.0.0.1

next run this

    chmod 0600 /root/.my.cnf

you're good to go. 

**crontab sample**

    0       *     *       *       *       bash mysqldump.sh -m \"//yourCIFSHost/backup -o credentials=/etc/cifsauth\" -p /mnt -f DESTFOLDER -d DATABASE_NAME -z
    0       *     *       *       *       bash mysqldump.sh -u YOUR_DEVICE_UUID -p /mnt -f DESTFOLDER -d DATABASE_NAME -z
