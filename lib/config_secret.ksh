#!/bin/ksh

echo "Enter the working directory: "
read workdir

if [ -z $workdir ];then
	echo "Directory can not be blank, exiting..."
	exit 1
fi

if [ ! -d $workdir ];then
	mkdir -p $workdir
fi

read_inp()
{
        read inp_val
        if [ ! -z $inp_val ];then
                echo $inp_val
        else
                echo $1
        fi
}

echo "Enter name of secret yaml file [cb-example-auth.yaml]: "
conffile=`read_inp cb-example-auth.yaml`

echo "Enter name for secret [cb-example-auth]: "
name=`read_inp cb-example-auth`

echo "apiVersion: v1" > $workdir/$conffile
echo "kind: Secret" >> $workdir/$conffile
echo "metadata:" >> $workdir/$conffile
echo "  name: $name" >> $workdir/$conffile
echo "type: Opaque" >> $workdir/$conffile
echo "data:" >> $workdir/$conffile


datarun="y"
while [ $datarun = "y" ];do
	echo "Enter data value name [username]: "
	dataname=`read_inp username`
	echo "Enter value [Administrator]: "
	datavalue=`read_inp Administrator`
	encoded=`echo -n ${datavalue} | base64`

	echo "  $dataname: $encoded # $datavalue" >> $workdir/$conffile

	echo "Enter another data value [y/n]: "
	read datarun
done
