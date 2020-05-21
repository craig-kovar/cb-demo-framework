# Couchbase Demo Framework Quickstart Tutorial

This tutorial will walk through a simple example of configuring two Couchbase clusters, loading some data into a cluster and creating some indexes through the **Couchbase Demo Framework**

## Prerequisites

You should have downloaded the **CB Demo Framework** and have a kubernetes cluster available.  This quickstart was recorded using Docker Kubernetes.

## Setting up first cluster

The first item we will perform with the **Couchbase Demo Cluster** is configuring our first Couchbase Cluster.

* CD to the directory where you installed the CB Demo Framework
* Run the command `./cb_demo_framework.ksh`

You should see the following

![screen](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-screen.png)

Using the **p** and **b** selections,  page through the list of available modules till you see **set_up_k8s.mod**.

> set_up_k8s.mod is a helper module that runs the modules to create a namespace, deploy the Couchbase Admission Controller, Deploy the Administrator user credentials and Couchbase Autonomous Operator

Select the corresponding value for **set_up_k8s.mod** and follow the onscreen prompts.  In most cases we can use the defaults.

> For easy access to any intermediate files, select your work directory as **./work/couchbase**

> Deploy all kubernetes resources into our newly created namespace **couchbase**

We now have our namespace **couchbase** created with all the required resources available to deploy a couchbase cluster.  This means that the next step we should select is the module named **config_cb_cluster.mod**

> For the working directory select **./work/couchbase**.

> Configuring the Couchbase Cluster yaml we will select the defaults for most options.  A few ones to note through
> * Do you want Operator to manage RBAC [y/n]: **Select n**
> * Do you want to expose services and/or enable TLS [y/n]: **Select n**
> * Enter the services [data|index|query|search|eventing|analytics] or q to stop: **This will repeat until q is selected. Select data, index, and query**
> * Do you want to specify resource limits/requests [y/n]: **Select n**
> * Specify a node selector [y/n]: **Select n**
> * Configure another Couchbase Server [y/n]: **Select n**
> * Should the operator manage buckets within this cluster [y/n]: **Select y**

We have now generated our Couchbase Cluster yaml file.  Feel free to take a look at it, it will be located at _./work/couchbase/cb-cluster.yaml_ if you have followed along with the tutorial

It is now time to deploy the cluster we just configured.  To do this we will select the module named **deploy_cb_cluster.mod**

> Specify the working directory as **./work/couchbase**

> Specify the namespace to deploy into as couchbase.
>>  _Enter namespace to deploy into [default]: couchbase_

 The Couchbase Cluster is deployed and the Operator is spinning up pods for our cluster.  However,  before we can load data or any other items we need to make sure that our cluster is ready.  In order to systematically check this there is a module named **wait_for_pods.mod**

 > Select the namespace of **couchbase** and use defaults for all other values

When this is complete you should see a Cluster is ready message as shown below

![screen](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-ready.png)

At this point our cluster is now ready but we do not have any buckets configured, data loaded, or indexes created, so let's take care of that.

## Create and deploy a bucket

If you selected the Operator to manage buckets within your Couchbase Cluster you need to configure and deploy a couchbasebucket resource into your namespace.  We will use a module named **config_bucket_and_deploy.mod** to configure our bucket and deploy it into our **couchbase** namespace

> We will leave everything else as default except a few prompts as shown
> * Enter working directory [./work]: **./work/couchbase**
> * Enter namespace where cluster is located [default]: **couchbase**
> * Enter bucket name [default]: **test**

This will alert the Operator that a bucket should be created in our **cb-example** cluster.

## Loading data into test bucket

There are a couple of small data files packaged with the CB Demo Framework that you can use to test loading data in either csv or json formats using the cbimport tool.

In this cluster we will load the json data.  To do that we will now select a module named **load_json_file.mod** and enter the following input for the prompts

> * Enter data location you want to load (Local path) []: **./artifacts/data**
> * Enter data file you want to load (Local file) []: **test.json**
> * Enter namespace of your cluster [default]: **couchbase**
> * Enter name of the pod to load to [cb-example-0]: _use default here_ or **cb-example**
> * Enter bucket name [default]: **test**
> * Enter username [Administrator]: _use default here_ or **Administrator**
> * Enter password [password]: _use default here_ or **password**
> * Enter key generation pattern (#MONO_INC#, #UUID#, %attribute%, etc...); enclose in '' ['#UUID#']: _use default here_ or **'#UUID#'**
> * Enter the number of threads [1]: **1**
> * Enter the format of the dataset (lines, list) [lines]: **lines**

You should see a message showing how many documents were loaded and how many failed as shown

![load](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-load.png)

## Create indexes

Couchbase provides a utility called CBQ which is a shell utility that allows you to execute N1QL statements.  The framework provides two options to take advantage of this, which is running a single query or providing a file with a series of queries to execute.

In this tutorial we will use the second option to create two indexes.

Run the module named **cbq_file.mod** and enter the following values when prompted

> * Enter data location you want to load (Local path) []: **./artifacts/data**
> * Enter data file you want to load (Local file) []: **test_query.txt**
> * Enter namespace of your cluster [default]: **couchbase**
> * Enter name of the pod to load to [cb-example-0]: _use default here_ or **cb-example**
> * Enter username [Administrator]: _use default here_ or **Administrator**
> * Enter password [password]: _use default here_ or **password**

You should see the statements being executed and the results from each statement

![cbq](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-cbq.png)

## Exposing admin console

Great we now have a Couchbase cluster deployed with some data loaded into a bucket and some indexes created.  The next step is to access the admin console.  Since we are using kubernetes we need to use port-forwarding to access the console in this example.  

> **Exposing services is beyond the scope of this tutorial**

In order to expose the admin console we will run a module named **port_forward_pod.mod**

> Use the defaults for all prompts except namespace.  Set namespace to **couchbase**

At this point, open your favorite browser and go to localhost:8091.  Log in with the credentials Administrator/password.  You should see one bucket with 2 documents loaded.

![adminui](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-adminui.png)

## Setting up second cluster

For the first cluster we used the set_up_k8s module.  However,  that creates certain cluster level objects we do not need to recreate.  So we will set up our second namespace by hand running the following modules (in order).

> As an exercise try and run the following modules to create and prepare a namespace named **xdcr**

* **build_ns.mod**
* **deploy_administrator_defaults.mod**
* **deploy_cb_operator.mod**

We will re-use the couchbase-cluster.yaml file we created earlier in the tutorial but instead this time deploying it to our xdcr namespace. To deploy this cluster we will re-run the module **deploy_cb_cluster.mod**, so let's do that.

> **It is important to note that while we are deploying to xdcr the work directory we will be using for this is actually ./work/couchbase**

## Creating bucket on secondary cluster

Using the workspace of **./work/xdcr** and the namespace **xdcr** repeat the steps we performed in [Create and deploy a bucket](#create-and-deploy-a-bucket)

## Exposing the admin ui on secondary cluster

We will expose the admin cluster ui on the secondary cluster the same way that we did from the primary cluster.  However,  in this instance we need to use the namespace **xdcr** and **the local port should be different from 8091 (as that is being used by primary cluster)**.  Please refer to the section [Exposing admin console](#exposing-admin-console) for reference on how to expose the Admin Console.

After this the secondary cluster can now be accessed at localhost:<port> where the port is the local port you chose when executing the port-forward module.
