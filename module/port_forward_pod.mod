PROMPT~Enter name of the pod to connect to~POD~cb-example-0000
PROMPT~Enter namespace of your pod~NS~default
PROMPT~Enter local port to use~LPORT~8091
PROMPT~Enter remote port to use~RPORT~8091
MESSAGE~Running port-forward {{POD}} {{LPORT}}:{{RPORT}} -n {{NS}} hit ctrl-c to exit...
KUBECTL~port-forward {{POD}} {{LPORT}}:{{RPORT}} -n {{NS}}
