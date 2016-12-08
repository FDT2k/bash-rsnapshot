#!/bin/bash
#dump a mysql mount the backup and umount the backup after
DIRNAME=$(dirname $0)
source $DIRNAME/common.sh
source $DIRNAME/mounting.sh
show_help(){
	echo "Do not forget to configure your ~/.cnf with your access AND host for mysqldump"
	echo "mysqlbackup.sh -u [UUID] "
  echo "SAMPLE "
  echo " sudo bash tar.sh -m \"//10.10.10.29/tech_backup -o credentials=/etc/cifsauth\" -p /mnt -f \"mydumptest/files\" -s \"/etc\""
	exit 1
}

UUID=""
MOUNT_PATH=""
MOUNT_SOURCE=""
DEST_FOLDER="mysqldump"
FOLDER_TO_BACKUP=""
FILE_EXPIRATION=15
GZIP=false
while getopts "h?u:m:p:f:s:t:z" opt; do
	case "$opt" in
	h|\?)
			show_help
			exit 0
			;;
	u)  UUID=$OPTARG
			;;
	p)  MOUNT_PATH=$OPTARG
			;;
	m)	MOUNT_SOURCE=$OPTARG
			;;
  f)  DEST_FOLDER=$OPTARG
      ;;
  s)  FOLDER_TO_BACKUP=$OPTARG
    ;;
  t)  FILE_EXPIRATION=$OPTARG
    ;;
  z)  GZIP=true
    ;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift


TO_MOUNT=""

if [ ! -z "$UUID" ] ; then
	TO_MOUNT=$UUID
	MOUNT_DEVICE="/dev/disk/by-uuid/$UUID"
fi

if [ ! -z "$MOUNT_SOURCE" ] ; then
	TO_MOUNT=$MOUNT_SOURCE
	MOUNT_DEVICE=$MOUNT_SOURCE
fi

if [ -z "$TO_MOUNT" ] ; then
	show_help
fi

if [ -z "$MOUNT_PATH" ]; then
	#show_help
	shutdown "you did not specify -p option. resulting in an empty mount path"
fi

if [ -z "$FOLDER_TO_BACKUP" ]; then
	#show_help
	shutdown "you have to specify a folder to backup"
fi


if  ! isMounted $MOUNT_PATH ; then
	echo "mounting  $MOUNT_DEVICE"
	do_mount "$MOUNT_DEVICE" "$MOUNT_PATH"
	log "mounted $MOUNT_DEVICE on $MOUNT_PATH ok"
	echo "Launching tar"
	log "launching tar"
	## do the dump here
  #escaping crap
  DEST_FOLDER=$(printf '%q' "$DEST_FOLDER")
  DESTINATION_FOLDER="$MOUNT_PATH/$DEST_FOLDER"
  if [ ! -d "$DESTINATION_FOLDER" ]; then
    log "creating destination folder $DESTINATION_FOLDER"
    mkdir -p "$DESTINATION_FOLDER" || shutdown "cannot create destination_folder"
  fi

  DB_STRING=$(printf '%q' "$FOLDER_TO_BACKUP" | sed 's/\//_/g')
  D=$(date +%Y-%m-%d_%H-%M-%S)
  DUMP_NAME=$(printf '%q_%q.tar.gz' "$DB_STRING" "$D")

#  mysqldump "$DATABASES" > "$DESTINATION_FOLDER/$DUMP_NAME" || shutdown "failed to dump the database"
  tar -zcvf "$DESTINATION_FOLDER/$DUMP_NAME" "$FOLDER_TO_BACKUP"
	log "finished dumping $FOLDER_TO_BACKUP into $DESTINATION_FOLDER/$DUMP_NAME "
	do_umount "$MOUNT_PATH"
	log "umounted $MOUNT_DEVICE"
else
	shutdown "$MOUNT_PATH is already mounted. skipping"
fi
