#!/bin/ksh

echo "Stopping all kubectl port-forward commands..."

for i in `ps -ef | grep "kubectl port-forward" | grep -v "grep" | tr -s ' ' | cut -d' ' -f 3`
do
	echo "Stopping `ps -ef | grep $i | grep -v grep`"
	kill -9 $i
done
