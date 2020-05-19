#@ Execute a single query using CBQ
PROMPT~Enter name prefix of the pod to execute from~PODPFX~cb-example-0
PROMPT~Enter namespace of your cluster~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter username~USER~Administrator
PROMPT~Enter password~PASS~password
PROMPT~Enter query~QUERY~
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "cbq -e couchbase://localhost -u {{USER}} -p {{PASS}} -s '{{QUERY}}'"
