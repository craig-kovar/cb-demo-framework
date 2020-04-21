#@ This is an example of wrapping a python script into framework
PROMPT~Enter the python file to run~PFILE~test.py
PROMPT~Enter any additional args~ARGS~
CODE~wrapper_python.ksh~{{PFILE}},{{ARGS}}
