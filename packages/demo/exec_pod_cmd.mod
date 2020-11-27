#@ Execute a single command on pod
#^ shell, generic
PROMPT~Enter name prefix of the pod to execute from~PODPFX~cb-example-0
PROMPT~Enter namespace of your cluster~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter command~CCMD~
MESSAGE~Executing {{CCMD}} on {{POD}}
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "{{CCMD}}"
