#!/bin/ksh

#Get script
script=${1}
shift

#Get args
args=""
for i in $@;do
	args="$args $i"
done

echo $args

if [ -f ${script} ];then
	python $script $args
fi
