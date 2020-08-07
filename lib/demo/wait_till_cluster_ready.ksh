#!/bin/ksh

clustername=${1}
expectednodes=${2}
ns=${3}
maxtries=${4}
sleeptime=${5}

echo "Waiting for cluster availability"
check=1
run="true"

while [[ $check -le $maxtries && $run == "true" ]];do
	echo "Running check #${check}..."
	count=0
	for status in `kubectl get pods -n $ns | grep $clustername | grep -v "grep" | tr -s ' ' | cut -d' ' -f 2`
	do
		if [ $status == "1/1" ];then
			let count=count+1
		fi
	done

	if [ $count -eq $expectednodes ];then
		echo "Cluster is ready"
		run="false"
	else
		echo "Detected $count out of $expectednodes ready, sleeping $sleeptime"
		let check=check+1
		sleep $sleeptime
	fi
done

