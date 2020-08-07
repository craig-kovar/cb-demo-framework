#@ Load a data using cbimport-csv
#^ Couchbase CLI command
PROMPT~Enter data location you want to load (Local path)~FILEPATH~
PROMPT~Enter data file you want to load (Local file)~FILE~
PROMPT~Enter name prefix of the pod to load from~PODPFX~cb-example-0
PROMPT~Enter namespace of your cluster~NS~default
CODE~get_pod_by_nameprefix.ksh~{{PODPFX}},{{NS}}~POD
PROMPT~Enter bucket name~BUCKET~default
PROMPT~Enter username~USER~Administrator
PROMPT~Enter password~PASS~password
PROMPT~Enter key generation pattern (#MONO_INC#, #UUID#, %attribute%, etc...); enclose in ''~KEY~'#UUID#'
PROMPT~Enter the number of threads~THREADS~1
PROMPT~Enter the delimiter of the dataset~FORMAT~,
KUBECTL~cp -n {{NS}} {{FILEPATH}}/{{FILE}} {{POD}}:/tmp
KUBEEXEC~{{POD}} -n {{NS}} -- bash -c "cbimport csv -c couchbase://localhost -u {{USER}} -p {{PASS}} -b {{BUCKET}} --field-separator {{FORMAT}} -d file:///tmp/{{FILE}} -g {{KEY}} -t {{THREADS}}"
