#!/bin/ksh

workdir=$1

if [ -z $workdir ];then
	echo "Enter working directory: "
	read workdir
fi

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

echo "apiVersion: couchbase.com/v1" > $workdir/cb-cluster.yaml
echo "kind: CouchbaseCluster" >> $workdir/cb-cluster.yaml
echo "metadata:" >> $workdir/cb-cluster.yaml
echo "  name: cb-example" >> $workdir/cb-cluster.yaml
echo "spec:" >> $workdir/cb-cluster.yaml
echo "  baseImage: couchbase/server" >> $workdir/cb-cluster.yaml

echo "Enter version [6.5.0]: "
version=`read_inp 6.5.0`

echo "  version: enterprise-${version}" >> $workdir/cb-cluster.yaml
echo "  authSecret: cb-example-auth" >> $workdir/cb-cluster.yaml
echo "  exposeAdminConsole: true" >> $workdir/cb-cluster.yaml
echo "  adminConsoleServices:" >> $workdir/cb-cluster.yaml
echo "    - data" >> $workdir/cb-cluster.yaml
echo "  cluster:" >> $workdir/cb-cluster.yaml

echo "Enter data service cluster quota in MB [256]: "
dquota=`read_inp 256`

echo "Enter index service cluster quota in MB [256]: "
iquota=`read_inp 256`

echo "Enter FTS service cluster quota in MB [256]: "
fquota=`read_inp 256`

echo "Enter eventing service cluster quota in MB [256]: "
equota=`read_inp 256`

echo "Enter analytics service cluster quota in MB [1024]: "
aquota=`read_inp 1024`

echo "Enter index storage setting (plasma or memory_optimized)  [memory_optimized]: "
istorage=`read_inp 1024`

echo "    dataServiceMemoryQuota: $dquota" >> $workdir/cb-cluster.yaml
echo "    indexServiceMemoryQuota: $iquota" >> $workdir/cb-cluster.yaml
echo "    searchServiceMemoryQuota: $fquota" >> $workdir/cb-cluster.yaml
echo "    eventingServiceMemoryQuota: $equota" >> $workdir/cb-cluster.yaml
echo "    analyticsServiceMemoryQuota: $aquota" >> $workdir/cb-cluster.yaml
echo "    indexStorageSetting: $istorage" >> $workdir/cb-cluster.yaml
echo "    autoFailoverTimeout: 30" >> $workdir/cb-cluster.yaml
echo "    autoFailoverMaxCount: 3" >> $workdir/cb-cluster.yaml
echo "    autoFailoverOnDataDiskIssues: true" >> $workdir/cb-cluster.yaml
echo "    autoFailoverOnDataDiskIssuesTimePeriod: 120" >> $workdir/cb-cluster.yaml
echo "    autoFailoverServerGroup: false" >> $workdir/cb-cluster.yaml
echo "  buckets:" >> $workdir/cb-cluster.yaml

addBucket="true"

while [ $addBucket = "true" ];do

	echo "Enter bucket name [default]: "
	bucket=`read_inp default`
	
	echo "    - name: $bucket" >> $workdir/cb-cluster.yaml
	echo "      type: couchbase" >> $workdir/cb-cluster.yaml
	
	echo "Enter the memory quota (mb) for bucket $bucket [128]: "
	memquota=`read_inp 128`

	echo "      memoryQuota: $memquota" >> $workdir/cb-cluster.yaml
	
	echo "Enter the number of replicas (0-3) [1]: "
	replicas=`read_inp 1`

	echo "      replicas: $replicas" >> $workdir/cb-cluster.yaml
	echo "      ioPriority: low" >> $workdir/cb-cluster.yaml
	echo "      evictionPolicy: valueOnly" >> $workdir/cb-cluster.yaml
	echo "      conflictResolution: seqno" >> $workdir/cb-cluster.yaml
	echo "      enableFlush: true" >> $workdir/cb-cluster.yaml
	echo "      enableIndexReplica: false" >> $workdir/cb-cluster.yaml

	echo "Add another bucket (y|n): "
	read bktcontinue
	while [[ $bktcontinue != "y" && $bktcontinue != "n" ]];do
		echo "Add another bucket (y|n): "
		read bktcontinue
	done

	if [ $bktcontinue = "n" ];then
		addBucket="false"
	fi
done

echo "  servers:" >> $workdir/cb-cluster.yaml
addServer="true"

while [ $addServer = "true" ];do

	echo "Enter server name [all]: "
	server=`read_inp all`

	echo "Enter number of pods [3]: "
	size=`read_inp 3`

		

	echo "Add another server (y|n): "
	read srvcontinue
	while [[ $srvcontinue != "y" && $srvcontinue != "n" ]];do
		echo "Add another server (y|n): "
		read srvcontinue
	done

	if [ $srvcontinue = "n" ];then
		addServer="false"
	fi

done

