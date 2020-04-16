#!/bin/ksh

#----------------------------------------------------------------------------------#
#			Couchbase Demo Framework
#
#	This script is designed to be a modular approach to deploying
#	custom and standard demos in a consistent and repeatable manner.
#
#
#	@Author - Craig Kovar
#----------------------------------------------------------------------------------#
VERSION=0.0.1

#----------------------------------------------------------------------------------#
#	FUNCTIONS
#----------------------------------------------------------------------------------#

info() {
	if [ $INFO -eq 1 ];then
		echo "[`date '+%m/%d/%y %H:%M:%S'`] INFO $1 " | tee -a $LOGFILE
	fi
}

debug() {
	if [ $DEBUG -eq 1 ];then
		echo "[`date '+%m/%d/%y %H:%M:%S'`] DEBUG $1 " | tee -a $LOGFILE
	fi
}

usage() {
	echo ""
	echo "Couchbase Demo Framework Usage"
	echo "Version: $VERSION"
	echo ""
	echo "$1 [-n|--nolog] [-d|--debug] [-l|-logfile <filename>] [-h|--help]"
	echo "		[-p|--pagesize]"
	echo ""
	echo "	-n | --nolog	=	Disables logging. Logging is enabled by default"
	echo "	-d | --debug	=	Enables debug logging.  Disabled by default"
	echo "	-l | --logfile	=	Specify the log file to use,  defaults to cb_demo.log"
	echo "	-p | --pagesize	=	Specify the pagesize to display. This defaults to 20"
	echo "	-h | --help	=	Display usage information"
	echo ""
}

exec_module_code()
{
	#Get the name of the command
	debug "[EXEC CODE] Running script ${1}"
	script=${1}

	#Split the arguments
	IFS=','; typeset -a arg_array=($2); unset IFS;

	args=""
	i=0;
	while [ $i -lt ${#arg_array[@]} ];do
		debug "[EXEC CODE] Arg detected - ${arg_array[$i]}"
		args="$args \"${arg_array[$i]}\""
		let i=i+1
	done
	command="$script $args"

	debug "[EXEC CODE] Evaluating command : $command"
	eval $command
}

prompt()
{
	echo ""
	echo "${1} [$3]: "
	read input < /dev/tty
	if [ -z "$input" ];then
		RESPONSES[$2]=$3
	else
		RESPONSES[$2]="$input"
	fi
	echo ""
}


replace_var()
{
	orig=$1
	final=`echo $orig | sed -e 's/{{/${RESPONSES[/g'`
	final=`echo $final | sed -e 's/}}/]}/g'`

	echo $final
}

load_modules()
{
	debug "Loading modules"
	for file in ./module/*.mod
	do
		temp=`echo $(basename $file)`
		MODULES+=($temp)
	done
}

display() {
	startnum=$1
	offset=$2

	clear	
	echo "==========================================================================================="
	echo "				Couchbase Demo Framework					 "
	echo "												 "
	echo "				Total Modules: ${#MODULES[@]}					 "
	echo "												 "
	echo "			< Page Back = 'b'          'p' = Page Forward >				 "
	echo "												 "
	echo "					q - quit						 "
	echo "==========================================================================================="

	j=0	
	i=$startnum
	let max=startnum+offset
	debug "Displaying modules $startnum to (<) $max"
	echo ""
	echo ""
	while [[ $i -lt $max && $i -lt ${#MODULES[@]} ]];do
		echo "[$j] - ${MODULES[$i]}"
		let j=j+1
		let i=i+1
	done
	echo ""
}

run_module()
{
	file="./module/${1}"
	info "Running module $file"
	while read line
	do
		debug "[RUN_MODULE] Line : $line"
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
					updated=`replace_var $temp`
                			args="$args$updated,"
					debug "[CODE] Processing ARG : $temp -> $updated"
                			let i=i+1
        			done
				debug "[CODE] Final args: $args"
			
				exec_module_code "./lib/${inp_array[1]}" "$args"
				;;
			"SOURCE")
				debug "[SOURCE] Sourcing code ${inp_array[1]}"
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
#	SCRIPT VARIABLES
#----------------------------------------------------------------------------------#
script=$0
typeset -A RESPONSES
typeset -a MODULES
export RESPONSES
START=0
PAGESIZE=20
SELECTION="0"
INFO=1
DEBUG=0
LOGFILE=./cb_demo.log

#----------------------------------------------------------------------------------#
#	MAIN PROGRAM
#----------------------------------------------------------------------------------#
#Process Arguments
while [ "$1" != "" ]; do
	ARG=$1
	case $ARG in
		-h | --help)
            		usage $script
            		exit
            		;;
        	-n | --nolog)
            		INFO=0
	    		DEBUG=0
            		;;
        	-d | --debug)
            		DEBUG=1
            		;;
        	-l | --logfile)
			shift
			LOGFILE=$1
			debug "Logfile set to $LOGFILE"
			;;
		-p | --pagesize)
			shift
			PAGESIZE=$1
			debug "Pagesize set to $PAGESIZE"
			;;
        	*)
            		echo "ERROR: unknown parameter \"$ARG\""
            		usage $script
            		exit 1
            		;;
    	esac
	shift
done

echo ""
info "[MAIN] ---------------------------------------------------------------------"
info "[MAIN] 		Starting cb_demo_framework				  "
info "[MAIN] ---------------------------------------------------------------------"
load_modules
MODCNT=${#MODULES[@]}

#MAIN LOOP
while [[ ! -z $SELECTION && $SELECTION != "q" ]];do
	display $START $PAGESIZE
	echo ""
	echo "Enter your selection: "
	read input

	SELECTION=$input
	typeset -i NUM=$SELECTION
	let MODNUM=START+NUM
	let MODMAX=MODCNT-START

	if [[ -z $SELECTION || $SELECTION == "q" ]];then
		break;
	elif [ $SELECTION == "p" ];then
		let START=START+PAGESIZE
		if [ $START -ge ${#MODULES[@]} ];then
			debug "Paged past max size, setting back to 0"
			START=0
		fi
		continue
	elif [ $SELECTION == "b" ];then
		let START=START-PAGESIZE
		if [ $START -le 0 ];then
			debug "Paged past min size, setting back to 0"
			START=0
		fi
		continue
	elif [[ $NUM -ge 0 && $NUM -lt $MODMAX && $NUM -lt $PAGESIZE ]];then
		if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
			info "Unknown selection [$SELECTION], hit any key to continue..."
			read pause
			continue
		fi
		
		run_module ${MODULES[$MODNUM]}
	else
		info "Unknown selection [$SELECTION], hit any key to continue..."
		read pause
		continue
	fi
done

