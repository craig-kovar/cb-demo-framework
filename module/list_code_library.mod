#@ List all code in lib directory
EXEC~ls -ltra ./lib/*.ksh | tr -s " " | cut -d " " -f 9 | sed -e s+./lib/++g | more
