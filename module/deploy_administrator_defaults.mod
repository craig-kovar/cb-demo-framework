#@ Deploy default admin user 'Administrator' and password to specified namespace
#^ Couchbase, User Management
PROMPT~Enter the namespace to deploy into~NS~default
KUBECTL~create -f ./artifacts/cbao/cb-example-auth.yaml -n {{NS}} --save-config
