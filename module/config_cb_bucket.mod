PROMPT~Enter working directory~WORKDIR~./work
PROMPT~Enter namespace where cluster is located~NS~default
PROMPT~Enter bucket name~BUCKET~default
PROMPT~Enter CB Cluster to create bucket in~CLUSTER~cb-example
PROMPT~Enter bucket memory quota in Mi~MEMORYQUOTA~256
PROMPT~Enter number of replicas~REPLICAS~1
PROMPT~Enter eviction policy (valueOnly | fullEviction)~EVICTIONPOLICY~valueOnly
PROMPT~Enter conflict resolution (lww | seqno)~CONFLICT~seqno
PROMPT~Enable flush (true | false)~FLUSH~false
TEMPLATE~couchbase_bucket.template~{{WORKDIR}}~yaml~BUCKETTEMP
