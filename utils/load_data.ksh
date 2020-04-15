#!/bin/ksh
clear
echo "Enter data location you want to load (Local):"
read data_loc
echo " "

echo "Enter the name of a Pod in your CB cluster:"
read pod
echo " "

echo "Enter a bucket name to load data to:"
read bucket
echo " "
dir=`echo $data_loc | awk -F "/" '{print $NF}'`

kubectl cp ${data_loc} ${pod}:/tmp

for i in `ls -l ${data_loc} |grep -v total| awk '{print $9}'`
do
	kubectl exec ${pod} -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ${bucket} -f list -d file:///tmp/${dir}/${i} -g key::%_id% -t 4"
done

