# List of scripts available in _lib_ directory

|Script                   |Description                            |Arguments    |
|:------------------------|:--------------------------------------|:------------|
|check_make_dir.ksh   |  Check if directory exists. If not, create directory | WORKDIR  |
|config_secret.ksh   | Read input and generate secret yaml  |   |
|create_cb_cluster_yaml.ksh   | Read input and generate couchbase cluster yaml  | WORKDIR  |
|generate_tls_cert.ksh  | Use easyrsa3 to generate certificates and deploy them as secrets into specified namespace  | WORKDIR, CLUSTER NAME, NAMESPACE  |
|get_nodeport.ksh   | Review svcs in a given namespace to detect NodePort for a given pod port  | NAMESPACE, POD NAME PREFIX, SSL FLAG, POD PORT TO DETECT  |
|get_pod_by_nameprefix.ksh   | Retrieve full pod name by specifying a name prefix similiar to wildcard statement  | NAME PREFIX, NAMESPACE  |
|git_helper.ksh   | Helper script to pull down any registered github repos registered in **import_git.txt**  |   |
|load_dir.ksh   | **PENDING REVIEW**  |   |
|mysql.ksh   | **PENDING REVIEW**  |   |
|reset_kube_cluster.ksh   | Retrieve and confirm deletion of deployed resources within the Kubernetes cluster  |   |
|stop_port_forwarding.ksh   | Stop all port-forwarding commands running  |   |
|wait_till_cluster_ready.ksh   | Retry a specified number of attempts to detect that the correct number of pods matching a name prefix are in a 1/1 Ready status. This will sleep a configured number of seconds between attempts  | NAME PREFIX, EXPECTED NUMBER OF PODS, NAMESPACE, MAX ATTEMPTS, SLEEP TIME BETWEEN ATTEMPTS  |
|wrapper_bash.ksh   | A helper script to call external bash scripts  | SCRIPT, ARGS - space seperated list of additional arguments |
|wrapper_python.ksh   | A helper script to call external python scripts   | SCRIPT, ARGS - space seperated list of additional arguments |
