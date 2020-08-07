#@ Get a pod name by prefix
#^ kubernetes
PROMPT~Enter the name prefix of pod~PREFIX~cb-example
PROMPT~Enter the namespace of the pod~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PREFIX}},{{NS}}~POD
MESSAGE~pod [{{POD}}] detected...
