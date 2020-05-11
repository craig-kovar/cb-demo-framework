#@ Execute a single query using CBQ
PROMPT~Enter name of the pod to execute from~POD~cb-example-0000
PROMPT~Enter namespace of your cluster~NS~default
PROMPT~Enter username~USER~Administrator
PROMPT~Enter password~PASS~password
PROMPT~Enter query~QUERY~
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "cbq -e couchbase://localhost -u {{USER}} -p {{PASS}} -s \'{{QUERY}}\'"
