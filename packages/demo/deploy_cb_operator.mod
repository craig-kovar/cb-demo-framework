#@ Deploy Couchbase Operator to specificed namespace
#^ couchbase
PROMPT~Enter namespace to deploy into~NS~default
EXEC~bin/cbopcfg --no-admission --namespace {{NS}} | kubectl create -n {{NS}} -f -
