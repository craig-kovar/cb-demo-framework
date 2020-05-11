#@ Deploy a couchbase cluster yaml into specified namespace
PROMPT~Enter working director~WORKDIR~./work
PROMPT~Enter name of configuration yaml~CONFFILE~cb-cluster.yaml
PROMPT~Enter namespace to deploy into~NS~default
KUBECTL~create -f {{WORKDIR}}/{{CONFFILE}} -n {{NS}} --save-config
