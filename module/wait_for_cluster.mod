PROMPT~Enter name of cluster~CLUSTER~cb-example
PROMPT~Enter namespace of cluster~NS~default
PROMPT~Enter expected number of pods in cluster~PODS~3
PROMPT~Enter number of retries to check~RETRIES~3
PROMPT~Enter number of seconds to wait between retries~SLEEP~30
CODE~wait_till_cluster_ready.ksh~{{CLUSTER}},{{PODS}},{{NS}},{{RETRIES}},{{SLEEP}}
