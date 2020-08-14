#@ Load a FTS Index from provided JSON file
#^ Couchbase

PROMPT~Enter the dirctory where the FTS index is located~FTSDIR
PROMPT~Enter the FTS index definition to load~FTSFILE~
PROMPT~Enter the Index Name~INDEXNAME
PROMPT~Enter NS to deploy to~NS
MODULE~get_pod_by_svc.mod
KUBECTL~cp -n {{NS}} {{FTSDIR}}/{{FTSFILE}} {{RETPOD}}:/tmp
KUBEEXEC~{{RETPOD}} -n {{NS}} -- bash -c "curl -u Administrator:password -XPUT http://localhost:8094/api/index/{{INDEXNAME}} -H "Content-type:application/json" -d @/tmp/{{FTSFILE}}
