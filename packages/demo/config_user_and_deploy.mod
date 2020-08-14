#@ Configure and deploy a Couchbase User
#^ Couchbase

PROMPT~Enter username~USERNAME~user1
PROMPT~Enter cluster name~CLUSTER~default
PROMPT~Enter user full name~FULLNAME~User One
PROMPT~Enter name of secret with user's password~PASSWORDSECRET~user-password
PROMPT~Enter the working directory~WORKDIR~./work
TEMPLATE~cb_user.template~{{WORKDIR}}~yaml~USERTEMP
KUBECTL~create -f {{USERTEMP}} -n {{NS}} --save-config
