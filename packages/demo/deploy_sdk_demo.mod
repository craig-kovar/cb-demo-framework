#@ Module to deploy the SDK Demo as a pod
#^ Couchbase, Couchbase Demo Container
PROMPT~Enter the NS to deploy into~NS~default
KUBECTL~create -f ./artifacts/config/sdk-demo.yaml -n {{NS}} --save-config
PROMPT~Enter local port for 8080 to use~LPORT1~8080
PROMPT~Enter local port for 8081 to use~LPORT2~8081
CODE~get_pod_by_nameprefix.ksh~sdkdemo,{{NS}}~POD
KUBECTL~port-forward {{POD}} {{LPORT1}}:8080 -n {{NS}} > /dev/null 2>&1 &
KUBECTL~port-forward {{POD}} {{LPORT2}}:8081 -n {{NS}} > /dev/null 2>&1 &
