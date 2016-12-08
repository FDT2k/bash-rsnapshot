#!/bin/bash
#dump a mysql mount the backup and umount the backup after
source ./common.sh
source ./mounting.sh

show_help(){
	echo "Do not forget to configure your ~/.cnf with your access AND host for mysqldump"
	echo "mysqlbackup.sh -u [UUID] "
  echo "SAMPLE "
  echo " bash mysqlbackup.sh -m \"//valinor.realise.ch/tech_backup -o credentials=/etc/cifsauth\" -p /mnt -f taxiblog -d taxiblog -z"
	exit 1
}

UUID=""
MOUNT_PATH=""
MOUNT_SOURCE=""
DEST_FOLDER="mysqldump"
DATABASES=""
FILE_EXPIRATION=15
GZIP=false
while getopts "h?u:m:p:f:d:t:z" opt; do
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
  d)  DATABASES=$OPTARG
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

if [ -z "$DATABASES" ]; then
	#show_help
	shutdown "you have to specify the databases to dump"
fi


if  ! isMounted $MOUNT_PATH ; then
	echo "mounting  $MOUNT_DEVICE"
	do_mount "$MOUNT_DEVICE" "$MOUNT_PATH"
	log "mounted $MOUNT_DEVICE on $MOUNT_PATH ok"
	echo "Launching mysqldump"
	log "launching mysqldump"
	## do the dump here
  #escaping crap
  DEST_FOLDER=$(printf '%q' "$DEST_FOLDER")
  DESTINATION_FOLDER="$MOUNT_PATH/$DEST_FOLDER"
  if [ ! -d "$DESTINATION_FOLDER" ]; then
    log "creating destination folder $DESTINATION_FOLDER"
    mkdir -p "$DESTINATION_FOLDER" || shutdown "cannot create destination_folder"
  fi

  DB_STRING=$(printf '%q' "$DATABASES")
  D=$(date +%Y-%m-%d_%H-%M-%S)
  DUMP_NAME=$(printf '%q_%q' "$DB_STRING" "$D")

  mysqldump "$DATABASES" > "$DESTINATION_FOLDER/$DUMP_NAME" || shutdown "failed to dump the database"
  if [ $GZIP ]; then
    gzip $DESTINATION_FOLDER/$DUMP_NAME
  fi
	log "finished dumping $DATABASES into $DESTINATION_FOLDER/$DUMP_NAME "
	do_umount "$MOUNT_PATH"
	log "umounted $MOUNT_DEVICE"
else
	shutdown "$MOUNT_PATH is already mounted. skipping"
fi
