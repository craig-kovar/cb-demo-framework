# Installing and Running Couchbase Demo framework

## Prerequisites

In order to run the CB Demo Framework this requires a kubernetes cluster to be available, and your user to have the necessary permissions to create the resources planned for any given demo.  Some example options on creating Kubernetes clusters can be found below.

&nbsp;&nbsp;&nbsp;&nbsp;[Kubernetes on Docker](https://www.techrepublic.com/article/how-to-add-kubernetes-support-to-docker-desktop/)

&nbsp;&nbsp;&nbsp;&nbsp;[Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

&nbsp;&nbsp;&nbsp;&nbsp;[EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)

&nbsp;&nbsp;&nbsp;&nbsp;[AKS Cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal)

&nbsp;&nbsp;&nbsp;&nbsp;[GKE Cluster](https://cloud.google.com/kubernetes-engine/docs/quickstart)


## Running the CB Demo framework

The CB Demo Framework is a simple shell script and as such can be run as follows

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`./cb_demo_framework.ksh`

You can optionally pass the following optional arguments.

![usage](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-usage.png)

Upon successful execution of the script you should see the following

![screen](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-screen.png)
