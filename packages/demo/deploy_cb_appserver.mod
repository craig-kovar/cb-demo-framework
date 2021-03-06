#@ Deploy a appserver pod with CB installed but not in a cluster
#^ Couchbase,Deploy Yaml,Application Server
PROMPT~Enter working directory~WORKDIR~./work
PROMPT~Enter name of deployment~NAME~cbappserver
PROMPT~Enter the image to deploy~IMAGE~couchbase:enterprise-6.5.1
PROMPT~Enter the namespace to deploy to~NS~default
PROMPT~Enter the number of pods to create~NUMREPS~1
#PROMPT~Enter name of template file located in "templates" directory~TFILE~
SET~TFILE~generic-with-replica.template
SET~EXTENSION~yaml
TEMPLATE~{{TFILE}}~{{WORKDIR}}~{{EXTENSION}}~TFILE
KUBECTL~create -f {{TFILE}} -n {{NS}} --save-config
