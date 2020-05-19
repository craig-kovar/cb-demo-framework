# List of modules available in Couchbase Demo framework

|Module                   |Description                                          |
|:------------------------|:----------------------------------------------------|
|build_ns.mod   |  Create a Namespace within Kubernetes cluster. |
|cbq_file.mod   |  Run a file of statements using CBQ utility.   |
|cbq_single_query.mod   | Run a single statement using CBQ utility   |
|config_bucket_and_deploy.mod   | Configure a Couchbase bucket and deploy resource to spcified namespace  |
|config_cb_bucket.mod   | Configure a Couchbase bucket but don't deploy it  |
|config_cb_cluster.mod   | Configure a Couchbase Cluster yaml but does not deploy it. **Due to the number of prompts the user import will not be recorded in a demo during recording mode** |
|config_secret.mod   | Configure a generic secret.  **Input values will not be recorded during recording mode.  All input values will be base64 encoded in generated secret yaml**  |
|config_sgw.mod   |  Configure SGW configuration json based upon SGW template. An example template is _couchmart_sgw.template_ |
|deploy_administrator_defaults.mod   | Deploy the default Administrator user secret into specified namespace  |
|deploy_admission_controller.mod   |  Deploy the Couchbase Admission Controller.  This only needs to be done once per Kubernetes cluster |
|deploy_cb_appserver.mod   | Deploy an application server with Couchbase installed but not managed by the Operator or part of any cluster.  Can be used to show IaaS approach,  running tools like CBQ, N1QLBACK, etc... from outside the cluster  |
|deploy_cb_cluster.mod   | Deploy a Couchbase Cluster yaml into specified namespace  |
|deploy_cb_operator.mod   | Deploy the Couchbase Autonomous Operator into specified namespace  |
|deploy_couchmart.mod   | Deploy the Couchmart application as a pod in a given namespace  |
|deploy_crd.mod   | Deploy the Couchbase Custom Resource Definitions (CRDs) into a Kubernetes cluster  |
|deploy_externaldns.mod   | Deploy ExternalDNS if using EKS. **Still validating**  |
|deploy_pod.mod   | Deploy generic yaml file into specified namespace  |
|deploy_sdk_demo.mod   | Deploy the SDK Demo into a specified namespace. GitHub repo located here: [SDK Demo](https://github.com/thejcfactor/sdk-demo.git)  |
| deploy_secret.mod  |  Deploy generated secret yaml into specified namespace |
| deploy_sgw_config_secret.mod |  Deploy a SGW configuration json as a secret into a specified namespace |
|deploy_sgw_svc.mod   | Deploy SGW deployment into specified namespace using SGW config secret as config json  |
|generate_tls.mod   | Generate certificates for given namespace and cluster name. Deploy these certificates as following secrets _couchbase-server-tls_ and _couchbase-operator-tls_ |
|generic_template.mod   | Process a generic template from the _template_ directory, substituting any templated variables  |
|generic_term_command.mod   |  Execute a generic terminal command, i.e. ls -ltra . |
|get_namespaces.mod   | Get namespaces within a Kubernetes cluster  |
|get_nodeport_connstr.mod   | Get formatted connection string for Couchbase or SGW if exposed using NodePort vs port-forwarding  |
|get_pods_in_ns.mod   | Get pods in specified namespace  |
|list_code_library.mod   | Helper module to list all scripts in _lib_ directory  |
|list_directory.mod   | Helper module to list a generic directory  |
|list_templates.mod   | Helper module to list all the templates in the _template_ directory  |
|list_var_in_template.mod   | Helper module to list all the templated variables that will be substituted within a template  |
|load_csv_file.mod   | Use cbimport to load a CSV file  |
|load_json_file.mod   | Use cbimport to load a JSON file  |
|mysql.mod   | **PENDING REVIEW**  |
|port_forward_pod.mod   | Run port-forward from a given pod on specified ports in the background  |
|reset_kube_cluster.mod   | Reset the Kubernetes cluster back to defaults, removing any deployed demos  |
|run_bash.mod   | Helper module to run external bash script  |
|run_python.mod   | Helper module to run external python script  |
|set_up_k8s.mod   | Run common commands to setup Kubernetes cluster.  This includes _Deploying CRDs_, _Deploying Admission Controller_, _Build a namespace_, _Deploy default Administrator user_, _Deploy Couchbase Autonomous Operator_  |
|shell_into_pod.mod   | shell into a pod within specified namespace  |
|sleep.mod   | Sleep for specified seconds  |
|stop_port_forwarding.mod   | Stop all ongoing port-forwarding commands  |
|wait_for_pods.mod   | Wait for desired number of pods matching name prefix to be in 1/1 Ready status  |
