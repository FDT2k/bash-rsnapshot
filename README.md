# bash-rsnapshot
rsnapshot bash script that mount an external usb device with its uuid and run rsnapshot.



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



