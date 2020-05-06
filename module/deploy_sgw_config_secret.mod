PROMPT~Enter sgw config file to load~SGWFILE~
PROMPT~Enter name of secret for config file~SECRET~
PROMPT~Enter namespace to deploy SGW into~NS~
KUBECTL~create secret generic {{SECRET}} --from-file=config.json={{SGWFILE}} -n {{NS}}
