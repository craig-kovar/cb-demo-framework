#@ This is an example of wrapping a python script into framework
PROMPT~Enter the bash script to run~SFILE~test.sh
PROMPT~Enter any additional args~ARGS~
CODE~wrapper_bash.ksh~{{SFILE}},{{ARGS}}
