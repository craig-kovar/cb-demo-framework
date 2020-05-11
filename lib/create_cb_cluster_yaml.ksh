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

echo "Enter name of configuration file to save [cb-cluster.yaml]: "
conffile=`read_inp cb-cluster.yaml`

echo "Enter the cluster name [cb-example]: "
clustername=`read_inp cb-example`

echo "apiVersion: couchbase.com/v2" > $workdir/${conffile}
echo "kind: CouchbaseCluster" >> $workdir/${conffile}
echo "metadata:" >> $workdir/${conffile}
echo "  name: $clustername" >> $workdir/${conffile}
echo "spec:" >> $workdir/${conffile}

echo "Enter version [6.5.0]: "
version=`read_inp 6.5.0`

echo "  image: couchbase/server:${version}" >> $workdir/${conffile}
echo "  paused: false" >> $workdir/${conffile}
echo "  antiAffinity: false" >> $workdir/${conffile}
echo "  softwareUpdateNotifications: false" >> $workdir/${conffile}
echo "  cluster:" >> $workdir/${conffile}
echo "    clusterName: $clustername" >> $workdir/${conffile}

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
istorage=`read_inp memory_optimized`

echo "    dataServiceMemoryQuota: ${dquota}Mi" >> $workdir/${conffile}
echo "    indexServiceMemoryQuota: ${iquota}Mi" >> $workdir/${conffile}
echo "    searchServiceMemoryQuota: ${fquota}Mi" >> $workdir/${conffile}
echo "    eventingServiceMemoryQuota: ${equota}Mi" >> $workdir/${conffile}
echo "    analyticsServiceMemoryQuota: ${aquota}Mi" >> $workdir/${conffile}
echo "    indexStorageSetting: $istorage" >> $workdir/${conffile}

echo "Enter the autofailover timeout in seconds [30]: "
timeout=`read_inp 30`

echo "    autoFailoverTimeout: ${timeout}s" >> $workdir/${conffile}
echo "    autoFailoverMaxCount: 3" >> $workdir/${conffile}
echo "    autoFailoverOnDataDiskIssues: true" >> $workdir/${conffile}
echo "    autoFailoverOnDataDiskIssuesTimePeriod: 120s" >> $workdir/${conffile}
echo "    autoFailoverServerGroup: false" >> $workdir/${conffile}

echo "  security:" >> $workdir/${conffile}

echo "Enter secret name [cb-example-auth]: "
secret=`read_inp cb-example-auth`

echo "    adminSecret: ${secret}" >> $workdir/${conffile}
echo "    rbac:" >> $workdir/${conffile}

echo "Do you want Operator to manage RBAC [y/n]: "
rbac=`read_inp y`

if [[ $rbac != "y" && $rbac != "n" ]];then
	while [[ $rbac != "y" && $rbac != "n" ]];do
		echo "Do you want Operator to manage RBAC [y/n]: "
		rbac=`read_inp y`
	done
fi

if [ $rbac = "y" ];then
	echo "      managed: true" >> $workdir/${conffile}
else
	echo "      managed: false" >> $workdir/${conffile}
fi

echo "      selector:" >> $workdir/${conffile}
echo "        matchLabels:" >> $workdir/${conffile}
echo "          cluster: ${clustername}" >> $workdir/${conffile}

echo "Do you want to expose services and/or enable TLS [y/n]: "
tlssec=`read_inp y`

if [[ $tlssec != "y" && $tlssec != "n" ]];then
	echo "DEBUG - In the if loop"
	while [[ $tlssec != "y" && $tlssec != "n" ]]; do
		echo "DEBUG - in the while loop"
		echo "Do you want to expose services and/or enable TLS [y/n]: "
		tlssec=`read_inp y`
	done
fi

if [ $tlssec = "y" ];then
	echo "  networking:" >> $workdir/${conffile}
	echo "    exposeAdminConsole: true" >> $workdir/${conffile}
	echo "    adminConsoleServices:" >> $workdir/${conffile}
	echo "    - data" >> $workdir/${conffile}

	echo "Enter how to expose services [NodePort|LoadBalancer]: "
	exposetype=`read_inp LoadBalancer`
	
	echo "    adminConsoleServiceType: $exposetype" >> $workdir/${conffile}

	typeset -A services
	echo "Enter the services to expose [admin|xdcr|client] or q to stop: "
	service=`read_inp admin`
	while [ $service != "q" ];do
		if [[ $service = "admin" || $service = "xdcr" || $service = "client" ]];then
			services[$service]="true"
		fi
		echo "Enter the services to expose [admin|xdcr|client] or q to stop: "
		service=`read_inp admin`
	done

	if [ ${#services[@]} -ge 1 ];then
		echo "    exposedFeatures:" >> $workdir/${conffile}
		for i in "${!services[@]}"
		do
			echo "    - ${i}" >> $workdir/${conffile}
		done
	fi

	echo "    exposedFeatureServiceType: ${exposetype}" >> $workdir/${conffile}
	echo "    tls:" >> $workdir/${conffile}
	echo "      static:" >> $workdir/${conffile}
	echo "        serverSecret: couchbase-server-tls" >> $workdir/${conffile}
	echo "        operatorSecret: couchbase-operator-tls" >>$workdir/${conffile}

	if [ $exposetype = "LoadBalancer" ];then
		echo "    dns:" >> $workdir/${conffile}
		echo "Enter domain name to expose services under [se-couchbasedemos.com]: "
		dns=`read_inp se-couchbasedemos.com`
		echo "      domain: $dns" >> $workdir/${conffile}
	
		echo "Enter any service annotation label: "
		svcannotation=`read_inp`
		echo "Enter service annotation value for label $svcannotation: "
		svcvalue=`read_inp`
		if [ ! -z $svcannotation ];then
			echo "    serviceAnnotations:" >> $workdir/${conffile}
			echo "      ${svcannotation}: ${svcvalue}" >> $workdir/${conffile}
		fi
	fi
fi

cbnode="y"
echo "  servers:" >> $workdir/${conffile}
while [ $cbnode = "y" ];do
	echo "Enter node names [all_services]: "
	node=`read_inp all_services`
	echo "How many pods to create [3]: "
	size=`read_inp 3`
	
	typeset -A cbsvcs
	echo "Enter the services [data|index|query|search|eventing|analytics] or q to stop: "
	service=`read_inp data`
	while [ $service != "q" ];do
		if [[ $service = "data" || $service = "index" || $service = "query" \
		   || $service = "search" || $service = "eventing" || $service = "analytics" ]];then
			cbsvcs[$service]="true"
		fi
		echo "Enter the services [data|index|query|search|eventing|analytics] or q to stop: "
		service=`read_inp data`
	done
	
	echo "Do you want to specify resource limits/requests [y/n]: "
	read limit
	if [ $limit = "y" ];then
		echo "Enter cpu limit: "
		read cpu_limit
		echo "Enter memory limit, i.e. 2Gi: "
		read mem_limit
		echo "Enter cpu request: "
		read cpu_request
		echo "Enter memory request i.e. 2Gi: "
		read mem_request
	fi

	echo "Specify a node selector [y/n]: "
	read nodeselector
	if [ $nodeselector = "y" ];then
		echo "Enter node selector label: "
		read ns_label
		echo "Enter node selector value: "
		read ns_value
	fi

	#Print Server info
	echo "  - size: $size" >> $workdir/$conffile
	echo "    name: $node" >> $workdir/$conffile
	echo "    services:" >> $workdir/$conffile

	for i in "${!cbsvcs[@]}"
        do
                echo "    - ${i}" >> $workdir/${conffile}
        done
	unset cbsvcs

	if [ $limit = "y" ];then
		echo "    resources:" >> $workdir/$conffile
		echo "      limits:" >> $workdir/$conffile
		echo "        cpu: ${cpu_limit}" >> $workdir/$conffile
		echo "        memory: ${mem_limit}" >> $workdir/$conffile
		echo "      requests:" >> $workdir/$conffile
		echo "        cpu: ${cpu_request}" >> $workdir/$conffile
		echo "        memory: ${mem_request}" >> $workdir/$conffile
	fi

	if [ $nodeselector = "y" ];then
		echo "    pod:" >> $workdir/$conffile
		echo "      spec:" >> $workdir/$conffile
		echo "        nodeSelector:" >> $workdir/$conffile
		echo "          ${ns_label}: ${ns_value}" >> $workdir/$conffile
	fi
	
	echo "Configure another Couchbase Server [y/n]: "
	read cbnode
done

echo "  buckets:" >> $workdir/$conffile
echo "Should the operator manage buckets within this cluster [y/n]: "
read bucketmng

if [ $bucketmng = "y" ];then
	echo "    managed: true" >> $workdir/$conffile
else
	echo "    managed: false" >> $workdir/$conffile
fi

echo "    selector:" >> $workdir/$conffile
echo "      matchLabels:" >> $workdir/$conffile
echo "        cluster: $clustername" >> $workdir/$conffile
echo "  xdcr:" >> $workdir/$conffile
echo "    managed: false" >> $workdir/$conffile
