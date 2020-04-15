#!/bin/ksh
ROOT_PASSWORD=$1
PORT=$2
DATASET=$3
file=`echo ${DATASET} | awk -F "/" '{print $NF}'`
kubectl run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=${ROOT_PASSWORD} --port=${PORT} --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
sleep 15
kubectl expose pod  mysql --type=LoadBalancer --port=${PORT} --target-port=${PORT}
kubectl cp ${DATASET}  mysql:/tmp/${file}
kubectl exec mysql -- bash -c "cd /tmp/; mysql -uroot -p${ROOT_PASSWORD} < ${file}"
echo " "
