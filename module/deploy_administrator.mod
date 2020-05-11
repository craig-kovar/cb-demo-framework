#@ Deploy non-default Administrator secret into specified namespace
PROMPT~Enter the namespace to deploy into~NS~default
PROMPT~Enter the secret yaml file to deploy~YAML~
KUBECTL~create -f {{YAML}} -n {{NS}} --save-config
