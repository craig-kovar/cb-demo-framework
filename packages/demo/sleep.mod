#@ Sleep for specified time in seconds
#^ generic
PROMPT~Enter time to sleep in seconds~SLEEP~30
MESSAGE~Sleeping for {{SLEEP}} seconds
EXEC~sleep {{SLEEP}}
