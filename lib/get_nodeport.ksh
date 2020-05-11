#!/bin/ksh

NS=${1}
CBNAME=${2}
SSL=${3}

line=`kubectl get svc -n $NS | grep $CBNAME | grep -v "grep" | tr -s ' ' | cut -d' ' -f5`
IFS=','; typeset -a port_array=($line); unset IFS;

checkport=8091
http="http://"
if [ $SSL == "y" ];then
	checkport=18091
	http="https://"
fi

returnport=""
for i in ${port_array[@]};do
	lport=`echo $i | cut -d':' -f 1 `
	rport=`echo $i | cut -d':' -f 2 | cut -d'/' -f 1`
	if [ $lport == $checkport ];then
		returnport=$rport
		break
	fi
done


echo "${http}localhost:$returnport"
