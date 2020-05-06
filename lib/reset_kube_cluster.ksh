#!/bin/ksh

#==========
# Get and store resources to remove
#==========
#Get NS to delete
typeset -a namespaces

IFS='
'
for raw_ns in `kubectl get ns`
do
	ns=`echo "$raw_ns" | cut -d' ' -f 1`
	if [[ $ns != "default" && $ns != "docker" && $ns != "kube-node-lease" \
		&& $ns != "kube-public" && $ns != "kube-system" && $ns != "NAME" ]];then
		namespaces+=("$ns")
	fi
done

typeset -a default_deployments
for raw_deployment in `kubectl get deployments | grep couchbase`
do
	deployment=`echo "$raw_deployment" | cut -d' ' -f 1`
	if [ $deployment != "NAME" ];then
		default_deployments+=("$deployment")
	fi
done

typeset -a clusterroles
for raw_cr in `kubectl get clusterroles | grep couchbase`
do
	cr=`echo "$raw_cr" | cut -d' ' -f 1`
	clusterroles+=("$cr")
done

typeset -a clusterrolebindings
for raw_crb in `kubectl get clusterrolebindings | grep couchbase`
do
	crb=`echo "$raw_crb" | cut -d' ' -f 1`
	clusterrolebindings+=("$crb")
done

typeset -a mwebhooks
for raw_mwh in `kubectl get mutatingwebhookconfiguration | grep couchbase`
do
	mwh=`echo "$raw_mwh" | cut -d' ' -f 1`
	mwebhooks+=("$mwh")
done

typeset -a vwebhooks
for raw_vwh in `kubectl get validatingwebhookconfiguration | grep couchbase`
do
	vwh=`echo "$raw_vwh" | cut -d' ' -f 1`
	vwebhooks+=("$vwh")
done

typeset -a crds
for raw_crd in `kubectl get crd | grep couchbase`
do
	crd=`echo "$raw_crd" | cut -d' ' -f 1`
	crds+=("$crd")
done

typeset -a serviceaccounts
for raw_sa in `kubectl get sa | grep couchbase`
do
	sa=`echo "$raw_sa" | cut -d' ' -f 1`
	serviceaccounts+=("$sa")
done

typeset -a secrets
for raw_sec in `kubectl get secrets | grep couchbase | grep -v "token"`
do
	secret=`echo "$raw_sec" | cut -d' ' -f 1`
	secrets+=("$secret")
done

typeset -a svcs
for raw_svc in `kubectl get svc | grep couchbase`
do
	svc=`echo "$raw_svc" | cut -d' ' -f 1`
	svcs+=("$svc")
done

#==========
#Display and prompt to continue
#==========
echo "Resetting Kubernetes cluster will remove the following resources..."
echo "Namespaces: "
for i in ${namespaces[@]};do
	echo -e "\t$i"
done

echo ""
echo "Deployments: "
for i in ${default_deployments[@]};do
	echo -e "\t$i"
done

echo ""
echo "ClusterRoles"
for i in ${clusterroles[@]};do
	echo -e "\t$i"
done

echo ""
echo "ClusterRoleBindings"
for i in ${clusterrolebindings[@]};do
	echo -e "\t$i"
done

echo ""
echo "Webhooks"
echo -e "\tMutatingWebHooks"
for i in ${mwebhooks[@]};do
	echo -e "\t\t$i"
done
echo -e "\tValidatingWebHooks"
for i in ${vwebhooks[@]};do
	echo -e "\t\t$i"
done

echo ""
echo "CustomResourceDefinitions"
for i in ${crds[@]};do
	echo -e "\t$i"
done

echo ""
echo "ServiceAccounts"
for i in ${serviceaccounts[@]};do
	echo -e "\t$i"
done

echo ""
echo "Secrets"
for i in ${secrets[@]};do
	echo -e "\t$i"
done

echo ""
echo "Services"
for i in ${svcs[@]};do
	echo -e "\t$i"
done

echo ""
echo "Do you want to continue with resetting kubernetes cluster [y/n]: "
read resetflag

while [[ $resetflag != "y" && $resetflag != "n" ]];do
	echo "Do you want to continue with resetting kubernetes cluster [y/n]: "
	read resetflag
done

if [ $resetflag == "y" ];then
	for i in ${namespaces[@]};do
		kubectl delete ns $i
	done

	for i in ${default_deployments[@]};do
        	kubectl delete deployment $i
	done	

	for i in ${clusterroles[@]};do
        	kubectl delete clusterrole $i
	done

	for i in ${clusterrolebindings[@]};do
        	kubectl delete clusterrolebinding $i
	done	

	for i in ${mwebhooks[@]};do
        	kubectl delete mutatingwebhookconfiguration $i
	done

	for i in ${vwebhooks[@]};do
        	kubectl delete validatingwebhookconfiguration $i
	done

	for i in ${crds[@]};do
        	kubectl delete crd $i
	done

	for i in ${serviceaccounts[@]};do
        	kubectl delete sa $i	
	done

	for i in ${secrets[@]};do
        	kubectl delete secret $i
	done

	for i in ${svcs[@]};do
        	kubectl delete svc $i
	done
fi
