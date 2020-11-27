#@ Execute a single CURL command
#^ shell, generic
PROMPT~Enter name prefix of the pod to execute from~PODPFX~cb-example-0
PROMPT~Enter namespace of your cluster~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter curl command~CCMD~
MESSAGE~Executing command {{CCMD}} on {{POD}}
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "{{CCMD}}"
