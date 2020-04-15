PROMPT~Enter data location you want to load (Local directory)~Directory~
PROMPT~Enter name of the pod to load to~POD~cb-example-0000
PROMPT~Enter namespace of your cluster~NS~default
PROMPT~Enter Bucket name~BUCKET
KUBECTL~cp -n {{NS}} {{FILE}} {{POD}}:/tmp
KUBEEXEC~ -n {{NS}} {{POD}} -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b {{BUCKET}} -f list -d file:///tmp/{{FILE}} -g key::%_id% -t 4"
