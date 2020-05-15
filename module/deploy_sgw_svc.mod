#@ Deploy a service to expose SGW as NodePort
PROMPT~Enter SGW port~PORT~4984
PROMPT~Enter the namespace where sgw is deployed~NS~default
TEMPLATE~sgw_svc.template~{{WORKDIR}}~yaml~SGWSVC
KUBECTL~create -f {{SGWSVC}} -n {{NS}}
