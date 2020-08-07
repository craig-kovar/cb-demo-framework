#!/bin/ksh

nameprefix=${1}
namespace=${2}

podname=`kubectl get pods -n ${namespace} | grep "^${nameprefix}" | grep "1/1" | grep -v "Terminating" | head -1 | cut -d' ' -f 1`

echo $podname

