#!/bin/bash

# parameters 0: mount point
isMounted() {
	MOUNTPOINT=$1
	grep -q " $(echo $MOUNTPOINT | sed -e 's/ /\\\\040/g') " /proc/mounts || isParentOnOtherDevice "$MOUNTPOINT"
}

#parameters mount point
assertMounted() {
	MOUNTPOINT=$1
	if ! isMounted "$MOUNTPOINT" ; then
		echo $MOUNTPOINT not mounted >&2
		exit 1
	fi
}

# mount first parameter on second
do_mount(){
	echo "mounting $1"
	#mount $1 $MOUNT_PATH || shutdown "can't mount device"
  mount $1 $2 || shutdown "can't mount device"

}
# 
do_umount(){
	umount $1 || shutdown "can't umount device"
}

isParentOnOtherDevice() {
	DEVICE=$(stat -c "%d" "$1") || exit 1
	DEVICE2=$(stat -c "%d" "`dirname $1`") || exit 1
	test "$DEVICE" != "$DEVICE2"
}
