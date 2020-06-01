#@ Wait for a specified number of pods to be in ready status (1/1) based upon name prefix
#^ kubernetes
PROMPT~Enter name prefix of cluster or pods to monitor (i.e. cb-example, couchmart, etc...)~CLUSTER~cb-example
PROMPT~Enter namespace of cluster~NS~default
PROMPT~Enter expected number of pods in cluster~PODS~3
PROMPT~Enter number of retries to check~RETRIES~10
PROMPT~Enter number of seconds to wait between retries~SLEEP~30
CODE~wait_till_cluster_ready.ksh~{{CLUSTER}},{{PODS}},{{NS}},{{RETRIES}},{{SLEEP}}
