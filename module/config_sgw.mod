PROMPT~Enter working directory~WORKDIR~./work
PROMPT~Enter name of template file located in "templates" directory~TFILE~
PROMPT~Enter namespace where Couchbase is deployed~CBNS~
PROMPT~Enter cluster name~CLUSTER~cb-example
PROMPT~Enter port to use for SGW~PORT~4984
PROMPT~Enter SGW Database name~DATABASE~
SET~SERVER~couchbase://{{CLUSTER}}-0000.{{CLUSTER}}.{{CBNS}}.svc
PROMPT~Enter the CB Bucket to connect to~BUCKET~default
PROMPT~Enter the CB User to connect with~USER~Administrator
PROMPT~Enter the password~PASS~password
TEMPLATE~{{TFILE}}~{{WORKDIR}}~json~SGWFILE
