#@ This is an example calling the NoSQL Summit Script
PROMPT~Enter the namespace to generate certs for~NS~default
PROMPT~Enter the cluster name~CLUSTER~cb-example
PROMPT~Enter the working directory to use~WORKDIR~./work
CODE~generate_tls_cert.ksh~{{WORKDIR}},{{CLUSTER}},{{NS}}
