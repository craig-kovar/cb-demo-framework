#@ Execute python script
#^ Couchbase
SET~PFILE~./lib/get_pod_by_svc.py
MESSAGE~Enter the following arguments:
MESSAGE~-ns namespace [default]
MESSAGE~-p prefix [cb-example]
MESSAGE~-s service [kv, index, n1ql, fts, analytics, eventing]
PROMPT~Enter any additional args~ARGS~-ns default -p cb-example -s kv
CODE~wrapper_python.ksh~{{PFILE}},{{ARGS}}~RETPOD
MESSAGE~Detected pod[{{RETPOD}}]
