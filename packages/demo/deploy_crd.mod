#@ Deploy Couchbase CRD resources
#^ couchbase
KUBECTL~create -f ./artifacts/cbao/crd.yaml --save-config
