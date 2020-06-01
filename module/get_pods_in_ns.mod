#@ Get all pods in a given namespace
#^ kubernetes
PROMPT~Enter namespace to get pods~NS~default
PROMPT~Enter -w if you want to watch pod events, leave blank otherwise~PODEVENT~
MESSAGE~Getting pods in {{NS}}...
KUBECTL~get pods -n {{NS}} {{PODEVENT}}
