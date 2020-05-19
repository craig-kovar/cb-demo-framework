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
#	SCRIPT VARIABLES
#----------------------------------------------------------------------------------#
script=$0
typeset -A RESPONSES
typeset -a MODULES
typeset -A MODDESC
typeset -a DEMOS
typeset -A DEMODESC
TYPE="MOD"
export RESPONSES
START=0
PAGESIZE=20
SELECTION="0"
INFO=1
DEBUG=0
LOGFILE=./cb_demo.log
writemode=""
recordfile=""

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

pause() {
	echo ""
	echo "Hit any key to continue..."
	read pause
}

get_var_val() {
	temp=`replace_var "${1}"`
	final=`eval echo "$temp"`
	echo $final
}

usage() {
	echo ""
	echo "Couchbase Demo Framework Usage"
	echo "Version: $VERSION"
	echo ""
	echo "$1 [-n|--nolog] [-d|--debug] [-l|-logfile <filename>] [-h|--help]"
	echo "		[-p|--pagesize <size>] [-g|--git-refresh] [--list <git|mod|demo>]"
	echo ""
	echo "	-n | --nolog		=	Disables logging. Logging is enabled by default"
	echo "	-d | --debug		=	Enables debug logging.  Disabled by default"
	echo "	-l | --logfile		=	Specify the log file to use,  defaults to cb_demo.log"
	echo "	-p | --pagesize		=	Specify the pagesize to display. This defaults to 20"
	echo "	-h | --help		=	Display usage information"
	echo "	-g | --git-refresh	=	Refresh the recorded git repositories"
	echo "	--list git|mod|demo	=	List the specified resource"
	echo ""
}

exec_module_code()
{
	#Get the name of the command
	debug "[EXEC CODE] Running script ${1}"
	script=${1}
	retvar=${3}

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
	
	if [ ! -z $retvar ];then
		retval=`eval $command < /dev/tty`
		debug "[EXEC CODE] Setting return argument $retvar to $retval"
		RESPONSES[$retvar]=$retval
	else
		eval $command < /dev/tty
	fi

}

prompt()
{
	echo ""
	echo "${1} [$3]: "
	read input < /dev/tty
	if [ -z "$input" ];then
		RESPONSES[$2]=$3
		debug "[PROMPT] Setting $2 to $3"
	else
		RESPONSES[$2]="$input"
		debug "[PROMPT] Setting $2 to $input"
	fi
}

message()
{
	orig=$1
	message=`IFS=''; replace_var "$orig"; unset IFS`
	debug "[MESSAGE] - Orig: $orig Fmt: $message"
	eval echo "$message"
}

replace_var()
{
	orig=$1
	ssq=$2  #Skip escaping single quotes
	final=`echo $orig | sed -e 's/{{/${RESPONSES[/g'`
	final=`echo $final | sed -e 's/}}/]}/g'`

	if [[ -z $ssq || "$ssq" != "true" ]]; then
		#final=`echo $final | sed -e 's/\"/\\\\\"/g'`
		final=`echo $final | sed -e "s/\'/\\\\\'/g"`
		#final=`echo $final | sed -e 's/\`/\\\\\`/g'`
	fi
	
	final=`echo $final | sed -e 's/"${/\"${/g'`
	final=`echo $final | sed -e 's/}"/}\"/g'`

	echo $final
}

load_modules()
{
	debug "Loading modules"
	for file in ./module/*.mod
	do
		temp=`echo $(basename $file)`
		MODULES+=($temp)
		
		topline=`head -1 $file`
		debug "$topline"
		if [[ ! -z $topline && ${topline:0:2} == "#@" ]];then
			MODDESC[$temp]="${topline:2}"
		fi
	done
}

load_demos()
{
	debug "Loading demos"
	for file in ./module/*.demo
	do
		temp=`echo $(basename $file)`
		DEMOS+=($temp)

		topline=`head -1 $file`
		debug "$topline"
		if [[ ! -z $topline && ${topline:0:2} == "#@" ]];then
			DEMODESC[$temp]="${topline:2}"
		fi
	done
}


display() {
	startnum=$1
	offset=$2
	type=$3

	clear	
	echo "==========================================================================================="
	echo "				Couchbase Demo Framework					 "
	echo "												 "
	echo "				Total Modules: ${#MODULES[@]}					 "
	echo "				Total Demos  : ${#DEMOS[@]}					 "
	echo "												 "
	echo "			w - Toggle recording mode		[$writemode]			 "
	echo "			c - Set or change recording file	[$recordfile]			 "
	echo "												 "
	echo "			< Page Back = 'b'              'p' = Page Forward >			 "
	echo "		        s - Set variable	        v - Display Variables			 "
	echo "			d - Switch to demo display	q - quit				 "
	echo "==========================================================================================="

	j=0	
	i=$startnum
	let max=startnum+offset
	debug "Displaying modules $startnum to (<) $max"
	echo ""
	echo ""
	if [ $type == "MOD" ];then
		while [[ $i -lt $max && $i -lt ${#MODULES[@]} ]];do
			printf "[%3s] - %-35s: %-100s\n" "$j" "${MODULES[$i]}" "${MODDESC[${MODULES[$i]}]}"
			let j=j+1
			let i=i+1
		done
	elif [ $type == "DEMO" ];then
		while [[ $i -lt $max && $i -lt ${#DEMOS[@]} ]];do
			printf "[%3s] - %-20s: %-100s\n" "$j" "${DEMOS[$i]}" "${DEMODESC[${DEMOS[$i]}]}"
			#echo "[$j] - ${DEMOS[$i]}	: ${DEMODESC[$i]}"
			let j=j+1
			let i=i+1
		done
	fi
	echo ""
}

get_leading_space()
{
        mystring=$1
        i=0
        while (( i <= ${#mystring} ))
        do
                char=${mystring:$i:1}
                if [[ ! -z $char && $char == " " ]];then
                        (( i += 1 ))
                else
                        break
                fi
        done

        echo $i
}

parse_template()
{
	debug "[TEMPLATE] Parsing template $1"
	template=`get_var_val $1`
	debug "[TEMPLATE] Retrieved template of $template"
	name=$(echo "$template" | cut -f 1 -d '.')
	workdir=`get_var_val $2`
	suffix=`get_var_val $3`
	varname=$4

	if [ ! -z $varname ];then
		RESPONSES[$varname]="${workdir}/${name}.${suffix}"
	fi

	if [ -f ${workdir}/${name}.${suffix} ];then
		debug "[TEMPLATE] - File detected (${workdir}/${name}.${suffix}) removing..."
		rm ${workdir}/${name}.${suffix}
	fi

	debug "[TEMPLATE] Processing file ./templates/$template"	
	IFS=''	
	while read fline
	do
		debug "[TEMPLATE] raw_line: $fline"
		spacecnt=`get_leading_space $fline`
		valline=`echo "$fline"`
		printline=""
		if [ `echo "$fline" | grep -c "{{"` -ge 1 ];then
			debug "[TEMPLATE] Variable detected..."
			final=`echo $fline | sed -e 's/\"/\\\\\"/g'`
                        final=`echo $final | sed -e "s/\'/\\\\\'/g"`
                        final=`echo $final | sed -e 's/\`/\\\\\`/g'`
			valline=`get_var_val $final`
		
			printline=""
			i=0
			while [ $i -lt $spacecnt ];
			do
  				printline="$printline "
				let i=i+1
			done
		fi
		
		printline="${printline}${valline}"

		debug "[TEMPLATE] - Adding line: $printline"
		echo "$printline" >> ${workdir}/${name}.${suffix}
	done < ./templates/$template
	unset IFS
}

set_var()
{
	debug "[SETVAR] Setting variable..."
	echo "Enter variable name to set: "
	read varname
	echo "Enter value for $varname: "
	read varvalue
	debug "[SETVAR] Setting $varname to $varvalue"
	RESPONSES[$varname]=$varvalue
	
	#record values
	if [ ! -z $writemode ];then
		echo "#==================== SET COMMAND =========================" >> ./module/$recordfile
		final=`echo $varvalue | sed -e 's/\"/\\\\\"/g'`
		final=`echo $final | sed -e "s/\'/\\\\\'/g"`
		final=`echo $final | sed -e 's/\`/\\\\\`/g'`
		echo $final
		eval echo "SET~${varname}~${final}" >> ./module/$recordfile
	fi
	echo "$varname set to $varvalue, hit any key to continue..."
	read pause
}

dump_var()
{
	debug "[DUMPVAR] Dumping all known variables"
	for i in "${!RESPONSES[@]}"
	do
  		echo "$i : ${RESPONSES[$i]}"
	done	
	echo "Hit any key to continue..."
	read pause
}

new_record_file()
{
	echo "Enter name of file to record responses, i.e. test.demo, test.mod: "
	read recordfile
	fileext=`echo ${recordfile##*.}`

	while [[ $fileext != "demo" && $fileext != "mod" ]];do
		echo "Enter name of file to record responses, i.e. test.demo, test.mod: "
		read recordfile
		fileext=`echo ${recordfile##*.}`
	done

	if [ ! -f ./module/$recordfile ];then
		echo "Enter a brief description for this recording: "
		read desc

		echo "#@ $desc" > ./module/$recordfile
	else
		echo "Override existing file [y/n]: "	
		read override
		if [ $override == "y" ];then
			echo "Enter a brief description for this recording: "
			read desc

			echo "#@ $desc" > ./module/$recordfile
		fi
	fi

}

run_module()
{
	file="./module/${1}"
	info "Running module $file"
	if [ ! -z $writemode ];then
		echo "#======================= $file ===============================" >> ./module/$recordfile
	fi
	while read line
	do
		debug "[RUN_MODULE] Line : $line"
		CHECKLINE=`echo $line | awk '{$1=$1};1'`
		FIRSTCHAR=${CHECKLINE:0:1}
		if [[ ! -z $FIRSTCHAR && $FIRSTCHAR == "#" ]];then
			continue
		elif [[ -z $FIRSTCHAR ]];then
			continue
		fi

		IFS='~'; typeset -a inp_array=($line); unset IFS;
		case ${inp_array[0]} in
			"PROMPT")
				prompt "${inp_array[1]}" "${inp_array[2]}" "${inp_array[3]}"
				;;
			"MESSAGE")
				message "${inp_array[1]}"
				;;
			"SET")
				tmpvalue=`replace_var "${inp_array[2]}"`
				RESPONSES[${inp_array[1]}]=`eval echo "$tmpvalue"`
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
			
				exec_module_code "./lib/${inp_array[1]}" "$args" "${inp_array[3]}"
				;;
			"SOURCE")
				debug "[SOURCE] Sourcing code ${inp_array[1]}"
				. ./lib/${inp_array[1]}
				;;
			"KUBECTL")
				kcommand=`replace_var "${inp_array[1]}"`
				kcommand="kubectl $kcommand"
				debug "[KUBECTL] Running command $kcommand"
				eval $kcommand
				;;
			"KUBEEXEC")
				kcommand=`replace_var "${inp_array[1]}" "true"`
				kcommand="kubectl exec $kcommand"
				debug "[KUBEEXEC] Running command $kcommand"
				eval $kcommand < /dev/tty
				;;
			"MODULE")
				run_module "${inp_array[1]}"
				;;
			"EXEC")
				command=`replace_var "${inp_array[1]}"`
				debug "[EXEC] Running command $command"
				eval $command < /dev/tty
				;;
			"TEMPLATE")
				parse_template ${inp_array[1]} ${inp_array[2]} ${inp_array[3]} ${inp_array[4]}
				;;
			* )
				echo "Unknown command [${inp_array[0]}]"
				;;
		esac
	
		#record values
		if [ ! -z $writemode ];then
			if [ ${inp_array[0]} == "PROMPT" ];then
				echo "# $line" >> ./module/$recordfile
				final=`echo ${RESPONSES[${inp_array[2]}]} | sed -e 's/\"/\\\\\"/g'`
				final=`echo $final | sed -e "s/\'/\\\\\'/g"`
				final=`echo $final | sed -e 's/\`/\\\\\`/g'`
				eval echo "SET~${inp_array[2]}~$final" >> ./module/$recordfile
			else
				echo $line >> ./module/$recordfile
			fi
		fi
		
	done < $file
}

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
		-g | --git-refresh)
			info "Refreshing the git repositories..."
			ksh lib/git_helper.ksh
			info "hit any key to continue..."
			pause
			;;
		--list)
			echo "Listing ... "
			pause
			exit 0
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
load_demos
MODCNT=${#MODULES[@]}
DEMOCNT=${#DEMOS[@]}

#MAIN LOOP
while [[ ! -z $SELECTION && $SELECTION != "q" ]];do
	display $START $PAGESIZE $TYPE
	echo ""
	echo "Enter your selection: "
	read input

	SELECTION=$input
	typeset -i NUM=$SELECTION
	let MODNUM=START+NUM
	let MODMAX=MODCNT-START
	let DEMOMAX=DEMOCNT-START

	if [[ -z $SELECTION || $SELECTION == "q" ]];then
		break;
	elif [ $SELECTION == "d" ];then
		if [ $TYPE == "MOD" ];then
			START=0
			TYPE="DEMO"
		else
			START=0
			TYPE="MOD"
		fi
		continue
	elif [ $SELECTION == "p" ];then
		let START=START+PAGESIZE
		if [ $TYPE == "MOD" ];then
			if [ $START -ge ${#MODULES[@]} ];then
				debug "Paged past max size, setting back to 0"
				START=0
			fi
		elif [ $TYPE == "DEMO" ];then
			if [ $START -ge ${#DEMOS[@]} ];then
				debug "Paged past max size, setting back to 0"
				START=0
			fi
		fi
		continue
	elif [ $SELECTION == "b" ];then
		let START=START-PAGESIZE
		if [ $START -le 0 ];then
			debug "Paged past min size, setting back to 0"
			START=0
		fi
		continue
	elif [ $SELECTION == "s" ];then
		set_var
	elif [ $SELECTION == "v" ];then
		dump_var
	elif [ $SELECTION == "w" ];then
		#echo "Entered into switch mode"
		if [ -z $writemode ];then
			if [ -z $recordfile ];then
				new_record_file
			fi
			writemode="recording"
		else
			writemode=""
		fi
	elif [ $SELECTION == "c" ];then
		new_record_file
	elif [[ $NUM -ge 0 ]];then
		if [[ $TYPE == "MOD" && $NUM -lt $MODMAX && $NUM -lt $PAGESIZE ]];then
			if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
				info "Unknown selection [$SELECTION], hit any key to continue..."
				read pause
				continue
			fi
			run_module ${MODULES[$MODNUM]}
			pause
			continue
		fi
		
		if [[ $TYPE == "DEMO" && $NUM -lt $DEMOMAX && $NUM -lt $PAGESIZE ]];then
			if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
				info "Unknown selection [$SELECTION], hit any key to continue..."
				read pause
				continue
			fi
			run_module ${DEMOS[$MODNUM]}
			pause
			continue
		fi

		info "Unknown selection [$SELECTION], hit any key to continue..."
		read pause
		continue
	else
		info "Unknown selection [$SELECTION], hit any key to continue..."
		read pause
		continue
	fi
done

