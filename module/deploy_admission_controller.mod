#@ Deploy Admission Controller into default namespace
EXEC~bin/cbopcfg --no-operator | kubectl create -f -
