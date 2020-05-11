#@ Get the connection string information when exposing services using NodePort
PROMPT~Enter namespace~NS~default
PROMPT~Enter Couchbase Cluster name prefix to search for~NAME~cb-example-0
PROMPT~Retrieve SSL port [y/n]~SSL~n
CODE~get_nodeport.ksh~{{NS}},{{NAME}},{{SSL}}~LINE
MESSAGE~Retrieved {{LINE}}
