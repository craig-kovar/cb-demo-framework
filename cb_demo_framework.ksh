#!/bin/ksh

#----------------------------------------------------------------------------------#
#			Couchbase Demo Framework
#
#	This script is designed to be a modular approach to deploying
#	custom and standard demos in a standard and repeatable manner.
#
#
#	@Author - Craig Kovar
#	@Version - 0.0.1
#----------------------------------------------------------------------------------#


#----------------------------------------------------------------------------------#
#	FUNCTIONS
#----------------------------------------------------------------------------------#

exec_module_code()
{
	#Get the name of the command
	script=${1}

	#Split the arguments
	IFS=','; typeset -a arg_array=($2); unset IFS;

	args=""
	i=0;
	while [ $i -lt ${#arg_array[@]} ];do
		args="$args \"${arg_array[$i]}\""
		let i=i+1
	done
	command="$script $args"

	eval $command
}

prompt()
{
	echo "${1} [$3]: "
	read input < /dev/tty
	if [ -z "$input" ];then
		RESPONSES[$2]=$3
	else
		RESPONSES[$2]="$input"
	fi
}


display()
{
	echo "Entered into display"
}

run_module()
{
	file="./module/test.mod"
	while read line
	do
		IFS='~'; typeset -a inp_array=($line); unset IFS;
		case ${inp_array[0]} in
			"PROMPT")
				prompt "${inp_array[1]}" "${inp_array[2]}" "${inp_array[3]}"
				;;
			"CODE")
				IFS=','; typeset -a arg_array=(${inp_array[2]}); unset IFS;
				args=""
				i=0
				while [ $i -lt ${#arg_array[@]} ];do
					temp=${arg_array[$i]}
                			args="$args${RESPONSES[$temp]},"
                			let i=i+1
        			done
			
				exec_module_code "./lib/${inp_array[1]}" "$args"
				;;
			"SOURCE")
				. ./lib/${inp_array[1]}
				;;
			"KUBECTL")
				echo $line			
				;;
			* )
				echo "Unknown command"
				;;
		esac
	done < $file
}

#----------------------------------------------------------------------------------#
#	MAIN PROGRAM
#----------------------------------------------------------------------------------#
typeset -A RESPONSES
export RESPONSES

run_module
