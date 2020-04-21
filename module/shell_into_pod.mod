PROMPT~Enter name of the pod to connect to~POD~cb-example-0000
PROMPT~Enter namespace of your pod~NS~default
KUBEEXEC~-it {{POD}} -n {{NS}} -- bash
