#@ Execute an arbitrary bash script
#^ generic
PROMPT~Enter the bash script to run~SFILE~test.sh
PROMPT~Enter any additional args~ARGS~
CODE~wrapper_bash.ksh~{{SFILE}},{{ARGS}}
