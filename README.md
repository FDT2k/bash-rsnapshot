# bash-rsnapshot
rsnapshot bash script that mount an external usb device with its uuid and run rsnapshot. 


**installation** 

  install rsnapshot and configure it.
  
  snapshot_root must reflect -p 

**usage**

rsnapshot.sh -u [device_UUID] -r [rsnapshot_category] -p [mount_path]



Crontab sample:

    0       *     *       *       *       bash rsnapshot.sh -u 5be75f53-44d0-4e10-bccc-ef30872e7951 -r hourly
    0       0     *       *       *       bash rsnapshot.sh -u 5be75f53-44d0-4e10-bccc-ef30872e7951 -r daily



For disk rotation simply duplicate the crontab lines with the second uuid

**Log** 

minimal output to syslog 

