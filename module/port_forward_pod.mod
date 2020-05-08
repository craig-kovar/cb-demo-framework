PROMPT~Enter name prefix of the pod to connect to~PODPFX~cb-example
PROMPT~Enter namespace of your pod~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter local port to use~LPORT~8091
PROMPT~Enter remote port to use~RPORT~8091
MESSAGE~Running port-forward {{POD}} {{LPORT}}:{{RPORT}} -n {{NS}} hit ctrl-c to exit...
KUBECTL~port-forward {{POD}} {{LPORT}}:{{RPORT}} -n {{NS}} > /dev/null 2>&1 &
