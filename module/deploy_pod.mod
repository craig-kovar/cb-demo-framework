PROMPT~Enter working directory~WORKDIR~./work
PROMPT~Enter namespace where cluster is located~NS~default
PROMPT~Enter name of configuration file~FILE~couchbase_bucket.yaml
KUBECTL~create -f {{WORKDIR}}/{{FILE}} -n {{NS}} --save-config
