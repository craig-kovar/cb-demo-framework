#@ Deploy a SGW config file as a secret into specified namespace
#^ Deploy yaml,SGW
PROMPT~Enter sgw config file to load~SGWFILE~
PROMPT~Enter name of secret for config file~SGWSECRET~
PROMPT~Enter namespace to deploy SGW into~NS~
KUBECTL~create secret generic {{SGWSECRET}} --from-file=config.json={{SGWFILE}} -n {{NS}}
