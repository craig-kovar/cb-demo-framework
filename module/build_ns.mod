#@ Configure and build a namespace in the k8s cluster
#Prompt for the namespace to create
PROMPT~Enter the namespace~NS~couchbase
#Prompt for working directory to use
PROMPT~Enter the working directory to use~WORKDIR~.
#Create working directory if does not exist
CODE~check_make_dir.ksh~{{WORKDIR}}
#Create Template for NS yaml
TEMPLATE~namespace.template~{{WORKDIR}}~yaml~NSTEMP
#Execute kubectl create -f ns.yaml
KUBECTL~create -f {{NSTEMP}}
