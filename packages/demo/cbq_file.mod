#@ Execute a query file using CBQ
#^ Couchbase CLI command,Couchbase
PROMPT~Enter data location you want to load (Local path)~FILEPATH~
PROMPT~Enter data file you want to load (Local file)~FILE~
PROMPT~Enter namespace of your cluster~NS~default
PROMPT~Enter name of the pod to load to~PODPFX~cb-example-0
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter username~USER~Administrator
PROMPT~Enter password~PASS~password
KUBECTL~cp -n {{NS}} {{FILEPATH}}/{{FILE}} {{POD}}:/tmp
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "cbq -e couchbase://localhost -u {{USER}} -p {{PASS}} -f /tmp/{{FILE}}"
