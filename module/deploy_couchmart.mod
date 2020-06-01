#@ Deploy couchmart application
#^ couchbase_demo_container
PROMPT~Enter the namespace to deploy couchmart into~CMNS~default
PROMPT~Enter the Couchbase cluster name to connect to~CMCLUSTER~cb-example
PROMPT~Enter the namespace where the CB Cluster is deployed~NS~default
SET~CLUSTER~couchmart
SET~PODS~1
SET~RETRIES~10
SET~SLEEP~30
CODE~get_pod_by_nameprefix.ksh~{{CMCLUSTER}},{{NS}}~CBPOD
SET~CONNSTR~{{CBPOD}}.{{CMCLUSTER}}.{{NS}}.svc
PROMPT~Enter the work directory to use for intermediate files~WORKDIR~./work
TEMPLATE~couchmart.template~{{WORKDIR}}~yaml~COUCHMART
KUBECTL~create -f {{WORKDIR}}/couchmart.yaml -n {{CMNS}}
CODE~wait_till_cluster_ready.ksh~{{CLUSTER}},{{PODS}},{{CMNS}},{{RETRIES}},{{SLEEP}}
CODE~get_pod_by_nameprefix.ksh~{{CLUSTER}},{{CMNS}}~CMPOD
PROMPT~Enter the local port to forward for couchmart~LPORT~8888
KUBECTL~port-forward {{CMPOD}} {{LPORT}}:8888 -n {{CMNS}} > /dev/null 2>&1 &
