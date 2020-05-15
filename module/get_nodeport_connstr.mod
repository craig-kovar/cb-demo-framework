#@ Get the connection string information when exposing services using NodePort
PROMPT~Enter namespace~NS~default
PROMPT~Enter Couchbase Cluster or SGW name prefix to search for~NAME~cb-example-0
PROMPT~Retrieve SSL port [y/n]~SSL~n
PROMPT~Enter default port to look for~PORT~8091
CODE~get_nodeport.ksh~{{NS}},{{NAME}},{{SSL}},{{PORT}}~LINE
MESSAGE~======================================================================
MESSAGE~Connection String::  {{LINE}}
MESSAGE~
MESSAGE~If this is SGW service when connecting emulator use 10.0.2.2 instead of localhost
MESSAGE~
MESSAGE~======================================================================
