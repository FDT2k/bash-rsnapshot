#!/bin/bash
# Rsnapshot with automount
# v0.2
DIRNAME=$(dirname $0)
source $DIRNAME/common.sh
source $DIRNAME/mounting.sh
UUID=""
RSNAPSHOT_MODE="hourly"
MOUNT_PATH=""
AUTO_MOUNT_PATH=false
NFS_PATH="" # shadowman.example.com:/misc/export

show_help(){
	echo "Do not forget to configure rsnapshot to point to your MOUNT_PATH"
	echo "rsnapshot.sh -u [UUID] -r [RSNAPSHOT_MODE] -a"
	echo " OR "
	echo "rsnapshot.sh -m [NFS_URI OR FULL MOUNT ARG] -r [RSNAPSHOT_MODE] -a"
	echo "optional: -p [MOUNT_PATH] (default: /mnt)"
	echo "optional: -a : auto fetch the mount path from rsnapshot"
	exit 1
}

while getopts "h?u:r:m:p:a" opt; do
	case "$opt" in
	h|\?)
			show_help
			exit 0
			;;
	u)  UUID=$OPTARG
			;;
	r)  RSNAPSHOT_MODE=$OPTARG
			;;
	p)  MOUNT_PATH=$OPTARG
			;;
	a)  AUTO_MOUNT_PATH=true
			;;
	m)	NFS_PATH=$OPTARG
			;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift


SCRIPT_NAME=$0





TO_MOUNT=""

if [ ! -z "$UUID" ] ; then

	TO_MOUNT=$UUID
	MOUNT_DEVICE="/dev/disk/by-uuid/$UUID"
fi

if [ ! -z "$NFS_PATH" ] ; then
	TO_MOUNT=$NFS_PATH
	MOUNT_DEVICE=$NFS_PATH
fi

if [ -z "$TO_MOUNT" ] ; then
	show_help
fi

if [ -z "$RSNAPSHOT_MODE" ]; then
	show_help
fi



if $AUTO_MOUNT_PATH; then
	if [ -f "/etc/rsnapshot.conf" ]; then
		GREPPED_PATH=$(cat /etc/rsnapshot.conf | grep snapshot_root | grep -v "#" | sed 's/snapshot_root\s*\(.*\)$/\1/' | sed 's/^ *//;s/ *$//')
		if [ ! -z "$GREPPED_PATH" ];then
			MOUNT_PATH=$GREPPED_PATH
		else
			shutdown "-a option is setted but could'nt fetch the snapshot_root config from /etc/rsnapshot.conf. Aborting"
		fi
	else
		shutdown "no /etc/rsnapshot.conf file found"
	fi
fi

if [ -z "$MOUNT_PATH" ]; then
	#show_help
	shutdown "you did not specify -p or -a option. resulting in an empty mount path"
fi





if [ ! -b "$MOUNT_DEVICE" ]; then
	log "external device is not plugged. Skipping."
	exit 0
fi

if  ! isMounted $MOUNT_PATH ; then
	echo "mounting  $MOUNT_DEVICE"
	do_mount $MOUNT_DEVICE $MOUNT_PATH
	log "mounted $MOUNT_DEVICE on $MOUNT_PATH ok"
	echo "Launching rsnapshot"
	log "launching rsnapshot"
	rsnapshot $RSNAPSHOT_MODE || shutdown "rsnapshot error"

	log "finished rsnapshot"
	do_umount $MOUNT_PATH
	log "umounted $MOUNT_DEVICE"
else
	shutdown "$MOUNT_PATH is already mounted. skipping"
fi
