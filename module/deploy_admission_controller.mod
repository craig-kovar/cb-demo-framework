#@ Deploy Admission Controller into default namespace
#^ Couchbase
EXEC~bin/cbopcfg --no-operator | kubectl create -f -
