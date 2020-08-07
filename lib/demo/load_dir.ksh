#!/bin/ksh
kubectl -n $3  cp $1 $2:/tmp

dir=`echo $1 | awk -F "/" '{print $NF}'`
for i in `ls -l $1 |grep -v total| awk '{print $9}'`
do
        kubectl exec -n $3 $2 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b $4 -f list -d file:///tmp/${dir}/${i} -g key::%_id% -t 4"
done
