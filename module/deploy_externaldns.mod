#@ Deploy ExternalDNS into specified namespace
#^ kubernetes
PROMPT~Enter NS to deploy external DNS into~NS~default
PROMPT~Enter working directory~WORKDIR~./work
TEMPLATE~externaldns-cr.template~{{WORKDIR}}~yaml~TFILE
KUBECTL~create -f {{WORKDIR}}/externaldns-cr.yaml -n {{NS}} --save-config
TEMPLATE~externaldns-sa.template~{{WORKDIR}}~yaml~TFILE
KUBECTL~create -f {{WORKDIR}}/externaldns-sa.yaml -n {{NS}} --save-config
TEMPLATE~externaldns-crb.template~{{WORKDIR}}~yaml~TFILE
KUBECTL~create -f {{WORKDIR}}/externaldns-crb.yaml -n {{NS}} --save-config
TEMPLATE~externaldns-deployment.template~{{WORKDIR}}~yaml~TFILE
KUBECTL~create -f {{WORKDIR}}/externaldns-deployment.yaml -n {{NS}} --save-config
