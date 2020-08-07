#!/bin/ksh

workdir=${1}

if [ -z $workdir ];then
	echo "Directory can not be blank, exiting..."
	exit 1
fi

if [ ! -d $workdir ];then
	mkdir -p $workdir
fi
