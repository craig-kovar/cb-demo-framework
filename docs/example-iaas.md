# Using Couchbase Demo Framework to mimic IaaS

While the demo framework is built on top of Kubernetes and is designed to work with the Couchbase Autonomous Operator,  you may need to demonstrate deploying and configuring Couchbase as if on-prem or using a hyperscaler as a IaaS provider.

This example is designed to show how you can use this framework to demonstrate the non-operator deployment approach.

## Creating a namespace

While we are still using Kubernetes, we will be deploying Couchbase instances as pods that will not be managed by an operator.  These can logically be thought of as VM instances of Couchbase.  That said,  it is good practice to scope resources into non-default namespaces.  We will take this approach as well.

The first step we will do is run the module **build_ns.mod**

> Select a unique namespace and a non-default workspace for isolation and easy access to any generated files

## Creating Couchbase pods

We now have a namespace to create our pods in, so let's go ahead and create our Couchbase pods (again we can think of these as VMs in this case)

In order to generate these pods we will run the module **deploy_cb_appserver.mod**.  This will prompt for the following values

> * Enter working directory [./work]: **Select the same working directory we used for namespace**
> * Enter name of deployment [cbappserver]: **Provide a unique name for the pods. This will be suffixed with unique ids such as _cbappserver-94c4b4dd4-8mz9w_**
> * Enter the image to deploy [couchbase:enterprise-6.5.1]: **Select the couchbase version to deploy**
> * Enter the namespace to deploy to [default]: **Select the namespace we created in the previous step**
> * Enter the number of pods to create [1]: **Enter the number of pods to create**

## Exposing the admin ui

In order to expose the admin console we will run a module named **port_forward_pod.mod**.  We need to set the following values when going through the prompts

> * Enter name prefix of the pod to connect to [cb-example]: **Select the name of the deployment from the previous step, such as cbappserver**
> * Enter namespace of your pod [default]: **Select the namespace we created in the first step**
> * Enter local port to use [8091]: **Select a unique port that is not already used**
> * Enter remote port to use [8091]: **Leave this as default**

If this is successful you should see the following

![bundle](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/example-iaas-ui.png)

You can now manually  configure the Couchbase server to your specifications.

## Adding new servers to the cluster

As noted,  since the cluster is not being managed by the Autonomous Operator, we are responsible for adding new servers to the cluster.  So let's add an additional server to the cluster assuming you created more than one pod in the previous step.

### Get ip addresses of the servers to adding

The first step we need to perform is to identify the ip addresses of the servers (pods) that we want to add to the cluster. We can do this by running the module **get_pods_in_ns.mod**

We will provide the following input:

> * Enter namespace to get pods [default]: **Select the namespace we created previously in this example**
> * Enter -w if you want to watch pod events, leave blank otherwise []: **Enter the argument _-o wide_ to display a more detailed output**

If this is successful it should look like below

![pods](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/example-iaas-getpods.png)

Note the IP column which we will use to add the server to the clusters through the UI as shown below

![add_server](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/example-iaas-addserver.png)

We should now see two servers in our cluster

![two_servers](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/example-iaas-twoservers.png)
