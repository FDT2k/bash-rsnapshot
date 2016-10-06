#!/bin/bash
# Rsnapshot with automount

shutdown() {

		>&2 echo "error: exiting " $1
		exit 2
}

UUID=""
RSNAPSHOT_MODE="hourly"
LOGFILE="/var/log/rsnapshot-inubo.log"
MOUNT_PATH="/mnt"
while getopts "h?u:r:l:p:" opt; do
		case "$opt" in
		h|\?)
				show_help
				exit 0
				;;
		u)  UUID=$OPTARG
				;;
		r)  RSNAPSHOT_MODE=$OPTARG
				;;
		r)  LOGFILE=$OPTARG
				;;
		p)  MOUNT_PATH=$OPTARG
				;;
		esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

isMounted() {
				MOUNTPOINT=$1
				grep -q " $(echo $MOUNTPOINT | sed -e 's/ /\\\\040/g') " /proc/mounts || isParentOnOtherDevice "$MOUNTPOINT"
}

assertMounted() {
				MOUNTPOINT=$1
				if ! isMounted "$MOUNTPOINT" ; then
								echo $MOUNTPOINT not mounted >&2
								exit 1
				fi
}

do_mount(){
	echo "mounting $1"
	mount $1 $MOUNT_PATH || shutdown "can't mount device"
}

do_umount(){

	umount $MOUNT_PATH || shutdown "can't umount device"
}

isParentOnOtherDevice() {
				DEVICE=$(stat -c "%d" "$1") || exit 1
				DEVICE2=$(stat -c "%d" "`dirname $1`") || exit 1
				test "$DEVICE" != "$DEVICE2"
}
SCRIPT_NAME=$0
log(){
	now="$(date +'%Y-%m-%d_%H-%M')"
	#echo "[$now]$1" >> $LOGFILE
	logger $SCRIPT_NAME $1
}

show_help(){
	echo "Do not forget to configure rsnapshot to point to your MOUNT_PATH"
	echo "rsnapshot.sh -u [UUID] -r [RSNAPSHOT_MODE] "
	echo "optional: -p [MOUNT_PATH] (default: /mnt)"
	exit 1
}

if [ -z "$UUID" ] ; then
	show_help
fi

if [ -z "$RSNAPSHOT_MODE" ]; then
	show_help
fi

MOUNT_DEVICE="/dev/disk/by-uuid/$UUID"
if [ ! -b "$MOUNT_DEVICE" ]; then
	log "external device is not plugged. Skipping."
	exit 0
fi

if  ! isMounted $MOUNT_PATH ; then
	echo $MOUNT_DEVICE
	do_mount $MOUNT_DEVICE
	log "mounted $MOUNT_DEVICE ok"
	log "launching rsnapshot"
	rsnapshot $RSNAPSHOT_MODE || shutdown "rsnapshot error"
	log "finished rsnapshot"
	do_umount
	log "umounted $MOUNT_DEVICE"
else
	shutdown "$MOUNT_PATH is already mounted. skipping"
fi
