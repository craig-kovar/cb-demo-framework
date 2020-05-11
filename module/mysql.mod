#@ Deploy a MySQL pod
PROMPT~MySQL root password~ROOT_PASSWORD
PROMPT~Enter MySQL Port~PORT~3306
PROMPT~Enter Location for a Dataset file to load~DATASET
KUBECTL~cp -n {{NS}} {{FILE}} {{POD}}:/tmp
CODE~mysql.ksh~{{ROOT_PASSWORD}},{{PORT}},{{DATASET}}
