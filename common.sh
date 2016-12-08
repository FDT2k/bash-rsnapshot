#!/bin/bash
SCRIPT_NAME=$0

echo $SCRIPT_NAME
log(){
	now="$(date +'%Y-%m-%d_%H-%M')"
	#echo $1
	logger "$SCRIPT_NAME $1"
}

shutdown() {
	ERROR="[ERROR]: exiting.  $1"
	log $ERROR
	>&2 echo $ERROR
	exit 2
}
