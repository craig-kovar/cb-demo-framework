PROMPT~Enter data location you want to load (Local path)~FILEPATH~
PROMPT~Enter data file you want to load (Local file)~FILE~
PROMPT~Enter name of the pod to load to~POD~cb-example-0000
PROMPT~Enter namespace of your cluster~NS~default
PROMPT~Enter Bucket name~BUCKET~default
KUBECTL~cp -n {{NS}} {{FILEPATH}}/{{FILE}} {{POD}}:/tmp
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b {{BUCKET}} -f lines -d file:///tmp/{{FILE}} -g key::%_id% -t 4"
