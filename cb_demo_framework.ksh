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
VERSION=0.7.1

#----------------------------------------------------------------------------------#
#	SCRIPT VARIABLES
#----------------------------------------------------------------------------------#
script=$0
typeset -A RESPONSES   		#Associative array to hold responses, "variables" from user input
typeset -a MODULES     		#List of modules to display in build mode
typeset -A MODDESC     		#Associative array to hold descriptions for related module
typeset -a DEMOS       		#List of recorded demos to display
typeset -A DEMODESC    		#Associative array to hold descriptions for related demo
typeset -a TAGS			#Numeric list of possible tags
typeset -A TAGMAP		#Mapping of modules to tags
typeset -a FILTERMODS		#Filtered list of modules to display when using filtering

PACKAGE="demo"
FILTERSTRING=""
BUILDFILTER=0
TYPE="DEMO"	       		#The display mode: MOD or DEMO
TYPELOCK=0	       		#Lock the type to prevent switching, used when bundling demos for distribution
export RESPONSES
START=0		       		#Starting location to display from
PAGESIZE=20	       		#Page size to display
SELECTION="0"          		#Default selection value
INFO=1                 		#Enable Info logging by default
DEBUG=0                		#Disable debug logging by default
LOGFILE=./cb_demo.log  		#Default log file
writemode=""           
recordfile=""

#----------------------------------------------------------------------------------#
#	FUNCTIONS
#----------------------------------------------------------------------------------#

#-----------------------
# Info logging method
#-----------------------
info() {
	if [ $INFO -eq 1 ];then
		echo "[`date '+%m/%d/%y %H:%M:%S'`] INFO $1 " | tee -a $LOGFILE
	fi
}

#-----------------------
# Debug logging method
#-----------------------
debug() {
	if [ $DEBUG -eq 1 ];then
		echo "[`date '+%m/%d/%y %H:%M:%S'`] DEBUG $1 " | tee -a $LOGFILE
	fi
}

#-----------------------
# Pause method - Prompts and pauses until user enters any key
#-----------------------
pause() {
	echo ""
	echo "Hit any key to continue..."
	read pause
}

#-----------------------
# Evaluate a variable to corresponding RESPONSES entry and returns that value
#-----------------------
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
	echo "		[-b|--bundle-demo <package name>] [-s|--set <varname>=<value>]"
	echo "		[-m|--module <module name>]"
	echo ""
	echo "	-n | --nolog		=	Disables logging. Logging is enabled by default"
	echo "	-d | --debug		=	Enables debug logging.  Disabled by default"
	echo "	-l | --logfile		=	Specify the log file to use,  defaults to cb_demo.log"
	echo "	-p | --pagesize		=	Specify the pagesize to display. This defaults to 20"
	echo "	-h | --help		=	Display usage information"
	echo "	-g | --git-refresh	=	Refresh the recorded git repositories"
	echo "	--list git|mod|demo	=	List the specified resource"
	echo "	-b | --bundle-demo	=	Deploy demo and bundle to sharable gzip file"
	echo "	-s | --set		=	Set a variable on launch"
	echo "	-m | --module		=	Launch a specific module or demo instead of display"
	echo ""
}

#-----------------------
# Executed when parsing CODE command from a module.
# This method will parse the comma seperated list of variables from a module
# into space delimited variable to be passed to the specified ksh script in the
# lib directory, and then execute that script
#-----------------------
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

#-----------------------
# This method will prompt the user for input and record that input to the RESPONSES array.
# If no input is provided then it will set the provided default value to the RESPONSES array.
#-----------------------
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
	#debug "[MESSAGE] - Orig: $orig Fmt: $message"
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

parse_tags()
{
	line=$1
	module=$2

	debug "Parsing tags: $line"

	IFS=','; typeset -a tag_array=($line); unset IFS;
	for i in "${tag_array[@]}"
	do
		typeset -l parsedval=`echo "$i" | sed -e 's/^ //g' | sed -e 's/ /_/g'`
		debug "[PARSE_TAG] Tag $i mapped to ${parsedval}..."
		
		currmap=`echo ${TAGMAP[$parsedval]}`
		if [ -z $currmap ];then
			TAGS+=($parsedval)
			currmap="$module"
		else
			currmap="$currmap,$module"
		fi
		TAGMAP[$parsedval]=$currmap
	done
}

load_modules()
{
	debug "Loading modules"
	for file in ./packages/${PACKAGE}/*.mod
	do
		temp=`echo $(basename $file)`
		MODULES+=($temp)
		
		topline=`head -1 $file`
		secondline=`head -2 $file | tail -1`
		if [[ ! -z $topline && ${topline:0:2} == "#@" ]];then
			MODDESC[$temp]="${topline:2}"
		elif [[ ! -z $topline && ${topline:0:2} == "#^" ]];then
			parse_tags "${topline:2}" $temp
		fi

		if [[ ! -z $secondline && ${secondline:0:2} == "#^" ]];then
			parse_tags "${secondline:2}" $temp
		fi
	done

	set -A orderedTags $(printf "%s\n" "${TAGS[@]}" | sort -n | tr "\n" " ");
	TAGS=("${orderedTags[@]}")
	set_filtered_list
}

load_demos()
{
	debug "Loading demos"
	for file in ./packages/${PACKAGE}/*.demo
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

set_filtered_list()
{
	#If FILTERSTRING is empty set FILTERMODS to entire MODULE array
	if [ -z $FILTERSTRING ];then
		FILTERMODS=("${MODULES[@]}")
	else
		u=0
		while [ $u -lt ${#FILTERMODS[@]} ];do
			unset FILTERMODS[$u]
			let u=u+1
		done

		IFS=','; typeset -a filter_array=($FILTERSTRING); unset IFS;
		typeset -a tmpArray=()
		typeset -A dedupe=()
        	for i in "${filter_array[@]}"
        	do
			IFS=','; typeset -a flt_mod_array=(${TAGMAP[$i]}); unset IFS;
			for j in "${flt_mod_array[@]}"
			do
				if [ -z ${dedupe[$j]} ];then
					tmpArray+=(${j})
					dedupe[$j]="Added"
				fi
			done
		done

		FILTERMODS=("${tmpArray[@]}")
	fi

}


list_tar_values() {
	if [ ! -f $TARFILE ];then
		info "Tarfile [$TARFILE] not found"
	else
		tar tf $TARFILE
	fi
}

manually_set_tar() {
	
	prompt_file="z"
	while [ "$prompt_file" != "n" ];do
		echo ""
		info "Following artifacts bundled into $TARFILE"
		list_tar_values
		echo ""
		echo "Do you want to manually add additional files [y/n]?"
		read prompt_file

		if [ "$prompt_file" == "y" ];then
			echo "Enter file to include in bundle (use relative path): "
			read add_file
			debug "[MANUAL BUNDLE] - Adding $add_file to $TARFILE"
			tar rf $TARFILE $add_file
		fi
	done

}


display() {
	startnum=$1
	offset=$2
	type=$3

	debug "Starting Number - $1 :: Offset - $2 :: Type - $3"

	if [ $TYPELOCK -lt 1 ];then
		dstring="d - Switch between builder and demo mode"
	else
		dstring="d - Bundling demo - disabled"
	fi

	#Messages
	divider="==========================================================================================="
	title="Couchbase Demo Framework"
	#VERSION
	modulesmsg="Total Modules : "
	demosmsg="Total Demos : "
	recordmodemsg="w - Toggle recording mode"
	recordfilemsg="c - Set or change recording file"
	pageback="b - Page back"
	pageforward="p - Page forward"
	setvarmsg="s - Set variable"
	displayvarmsg="v - Display variables"
	quitmsg="q - quit"
	buildfiltermsg="f - Toggle filter criteria mode"
	resetfiltermsg="r - Reset filter string"

	clear	
	printf "%s\n" $divider
	printf "%35s%-24s\n" " " "$title"
	printf "%35sVersion: %-s\n" " " "$VERSION"
	printf "\n"

	if [ $BUILDFILTER -eq 0 ];then
		printf "%35s%-13s: ${#FILTERMODS[@]}\n" " " "$modulesmsg"
		printf "%35s%-13s: ${#DEMOS[@]}\n" " " "$demosmsg"
		printf "\n"
		printf "%12s%-40s%15s[$writemode]\n" " " "$recordmodemsg" " " 
		printf "%12s%-40s%15s[$recordfile]\n" " " "$recordfilemsg" " "
		printf "\n"
		printf "%12s%-40s%15s%-35s\n" " " "$pageback" " " "$pageforward"
		printf "%12s%-40s%15s%-35s\n" " " "$setvarmsg" " " "$displayvarmsg"
		printf "%12s%-40s%15s%-35s\n" " " "$dstring" " " "$quitmsg"
		printf "%12s%-40s%15s[$FILTERSTRING]\n" " " "$buildfiltermsg" " " 
	else
		printf "%12s%-40s%15s%-35s\n" " " "$pageback" " " "$pageforward"
		printf "%12s%-40s\n" " " "$resetfiltermsg"
		printf "%12s%-40s\n" " " "$buildfiltermsg"
		printf "\n"
		printf "%12sCurrent Filter Criteria: $FILTERSTRING\n"
	fi

	printf "%s\n" $divider

	j=0	
	i=$startnum
	let max=startnum+offset
	debug "Displaying modules $startnum to (<) $max"
	echo ""
	echo ""
	if [ $type == "MOD" ];then
		if [ $BUILDFILTER -eq 0 ];then
			while [[ $i -lt $max && $i -lt ${#FILTERMODS[@]} ]];do
				printf "[%3s] - %-35s: %-100s\n" "$j" "${FILTERMODS[$i]}" "${MODDESC[${FILTERMODS[$i]}]}"
				let j=j+1
				let i=i+1
			done
		else
			while [[ $i -lt $max && $i -lt ${#TAGS[@]} ]];do
				printf "[%3s] - %-50s\n" "$j" "${TAGS[$i]}" 
				let j=j+1
				let i=i+1
			done
		fi
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

debug_array() 
{
	print ""
	print "-------------------------"
        for i in "${!RESPONSES[@]}"
        do
                print "key  : $i"
                print "value: ${RESPONSES[$i]}"
        done
	print "------------------------"
	print ""
}

escape_back_tick() 
{
        escapeline=$1
        start=`echo $escapeline | awk 'END{print index($0,"\\\\\`{{")}'`
        end=`echo $escapeline | awk 'END{print index($0,"}}\\\\\`")}'`

        while [ $end -gt 0 ];do
                if [[ $start -ge 0 && $end -gt $start ]];then
                        let startloc=$start+3
                        let endloc=$end-1
                        let length=$endloc-$startloc
                        tmpname=`echo ${escapeline:$startloc:$length}`
                        tmpvalue=${RESPONSES[$tmpname]}
                        RESPONSES["TEBT_${tmpname}"]="\`${tmpvalue}\`"
                        escapeline="${escapeline:0:$start-1}{{TEBT_${tmpname}}}${escapeline:end+3}"
                fi

                start=`echo $escapeline | awk 'END{print index($0,"\\\\\`{{")}'`
                end=`echo $escapeline | awk 'END{print index($0,"}}\\\\\`")}'`
        done

        echo $escapeline
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

			#Check for `{{ and replace that with new variable named TEBT_<NAME> with value `<VALUE>`
			escape_back_tick $final 2>&1 > /dev/null
			final=`escape_back_tick $final`
			final=`echo $final | sed -e 's/\;/\\\\\;/g'`

			debug "[TEMPLATE] - pre evaluation line: $final"
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
		echo "#==================== SET COMMAND =========================" >> ./packages/${PACKAGE}/$recordfile
		final=`echo $varvalue | sed -e 's/\"/\\\\\"/g'`
		final=`echo $final | sed -e "s/\'/\\\\\'/g"`
		final=`echo $final | sed -e 's/\`/\\\\\`/g'`
		echo $final
		eval echo "SET~${varname}~${final}" >> ./packages/${PACKAGE}/$recordfile
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

	if [ ! -f ./packages/${PACKAGE}/$recordfile ];then
		echo "Enter a brief description for this recording: "
		read desc

		echo "#@ $desc" > ./packages/${PACKAGE}/$recordfile
	else
		echo "Override existing file [y/n]: "	
		read override
		if [ $override == "y" ];then
			echo "Enter a brief description for this recording: "
			read desc

			echo "#@ $desc" > ./packages/${PACKAGE}/$recordfile
		fi
	fi

}

run_module()
{
	file="./packages/${PACKAGE}/${1}"
	info "Running module $file"
	if [ ! -z $writemode ];then
		echo "#======================= $file ===============================" >> ./packages/${PACKAGE}/$recordfile
	fi
	while read line
	do
		debug "[RUN_MODULE] Line : $line"
		RECORDLINE=$line
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
			
				exec_module_code "./lib/${PACKAGE}/${inp_array[1]}" "$args" "${inp_array[3]}"
				;;
			"SOURCE")
				debug "[SOURCE] Sourcing code ${inp_array[1]}"
				. ./lib/${PACKAGE}/${inp_array[1]}
				;;
			"KUBECTL")
				kcommand=`replace_var "${inp_array[1]}"`

				if [ $TYPELOCK -eq 1 ];then
					if [[ ${kcommand:0:6} == "create" ]];then
						debug "[BUNDLE] - Detected a kubectl create statement to bundle"
						debug "[BUNDLE] - $kcommand"
						secondpos=`echo $kcommand | cut -d' ' -f2`
						if [ "$secondpos" == "-f" ];then
							tar_add_file=`echo $kcommand | cut -d' ' -f3`
							eval "tar rf $TARFILE $tar_add_file"
						elif [ "$secondpos" == "secret" ];then
							tar_add_file=`echo $kcommand | cut -d' ' -f5`
							final_tar_file=`echo ${tar_add_file##*=}`
							eval "tar rf $TARFILE $final_tar_file"
						fi
					elif [[ ${kcommand:0:2} == "cp" ]];then
						debug "[BUNDLE] - Detected a kubectl cp statement to bundle"
						debug "[BUNDLE] - $kcommand"
						secondpos=`echo $kcommand | cut -d' ' -f2`
						if [ $secondpos == "-n" ];then
							cpfile=`echo $kcommand | cut -d' ' -f4`
							eval "tar rf $TARFILE $cpfile"
						else
							eval "tar rf $TARFILE $secondpos"
						fi
					fi	
				fi				

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
				if [ $TYPELOCK -eq 1 ];then
					debug "[BUNDLE] Detected template file"
					suffix=`echo ${inp_array[1]##*.}`
					#echo "SUFFIX = $suffix"
					if [ "$suffix" == "template" ];then
						eval "tar rf $TARFILE ./templates/${inp_array[1]}"
					else
						template=`get_var_val ${inp_array[1]}`
						#echo "DEBUG: $template"
						if [ ${template:0:11} != "./templates" ];then
							eval "tar rf $TARFILE ./templates/$template"
						else
							eval "tar rf $TARFILE $template"
						fi
					fi
				fi

				parse_template ${inp_array[1]} ${inp_array[2]} ${inp_array[3]} ${inp_array[4]}
				;;
			* )
				echo "Unknown command [${inp_array[0]}]"
				;;
		esac
	
		#record values
		if [ ! -z $writemode ];then
			if [ ${inp_array[0]} == "PROMPT" ];then
				echo "# $line" >> ./packages/${PACKAGE}/$recordfile
				final=`echo ${RESPONSES[${inp_array[2]}]} | sed -e 's/\"/\\\\\"/g'`
				final=`echo $final | sed -e "s/\'/\\\\\'/g"`
				final=`echo $final | sed -e 's/\`/\\\\\`/g'`
				eval echo "SET~${inp_array[2]}~$final" >> ./packages/${PACKAGE}/$recordfile
			else
				debug "[RECORDING] Line = $line"
				echo $line >> ./packages/${PACKAGE}/$recordfile
			fi
		fi
		
	done < $file

	if [ $TYPELOCK -ge 1 ];then
		#echo "TODO - prompt for additional files"
		manually_set_tar

		gzip $TARFILE
	fi
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
                -b | --bundle-demo)
			info "Bundling demo(s)"
			TYPE="DEMO"
			TYPELOCK=1
			shift
			TARFILE=$1
			if [ -z $TARFILE ];then
				echo ""
				info "ERROR - Tarfile must be provided with -b option"
				echo ""
				exit 1
			fi

			if [ -f $TARFILE ];then
				info "Tarfile [$TARFILE] detected, removing..."
				rm $TARFILE
			fi

			info "Packaging demo to $TARFILE"
			pause
			;;
		--list)
			echo "Listing ... "
			pause
			exit 0
			;;
                -s | --set)
			shift
			TMPVAR=$1
			tmp_var_name=`echo $TMPVAR | cut -d'=' -f1`
			tmp_var_value=`echo $TMPVAR | cut -d'=' -f2`
			if [[ ! -z $tmp_var_name && ! -z $tmp_var_value ]];then
				RESPONSES[$tmp_var_name]=$tmp_var_value
			fi	
			;;
		-m | --module)
			shift
			tmp_module=$1
			run_module $tmp_module	
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
TAGCNT=${#TAGS[@]}

#MAIN LOOP
while [[ $SELECTION != "q" ]];do
	FILTERCNT=${#FILTERMODS[@]}
	display $START $PAGESIZE $TYPE
	echo ""
	echo "Enter your selection: "
	read input

	SELECTION=$input
	typeset -i NUM=$SELECTION
	let MODNUM=START+NUM
	let MODMAX=MODCNT-START
	let DEMOMAX=DEMOCNT-START
	let TAGMAX=TAGCNT-START
	let FILTERMAX=FILTERCNT-START

	if [ -z $SELECTION ];then
		echo "Selection can not be blank"
		pause
		continue
	elif [[ $SELECTION == "q" ]];then
		break;
	elif [ $SELECTION == "d" ];then
		if [ $TYPELOCK -lt 1 ];then
			if [ $TYPE == "MOD" ];then
				START=0
				TYPE="DEMO"
			else
				START=0
				TYPE="MOD"
			fi
		fi
		continue
	elif [ $SELECTION == "p" ];then
		let START=START+PAGESIZE
		if [ $TYPE == "MOD" ];then
			if [ $BUILDFILTER -eq 0 ]; then
				if [ $START -ge ${#FILTERMODS[@]} ];then
					debug "Paged past max size, setting back to 0"
					START=0
				fi
			else
				if [ $START -ge ${#TAGS[@]} ];then
					debug "Paged past max size, setting back to 0"
					START=0
				fi
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
		continue
	elif [ $SELECTION == "v" ];then
		dump_var
		continue
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
		continue
	elif [ $SELECTION == "c" ];then
		new_record_file
		continue
	elif [ $SELECTION == "r" ];then
		if [[ $TYPE == "MOD" && $BUILDFILTER -eq 1 ]];then
			FILTERSTRING=""
			set_filtered_list
		else
			info "Resetting filtering criteria only available from filter screen 'f' in builder mode"
			pause
		fi
		continue
	elif [ $SELECTION == "f" ];then
		if [ $TYPE == "MOD" ];then
			if [ $BUILDFILTER -eq 0 ];then
				START=0
				BUILDFILTER=1
			else
				BUILDFILTER=0
				set_filtered_list
			fi
		else
			info "Filtering is only available in builder mode"
			pause
		fi
		continue	
	elif [[ $NUM -ge 0 ]];then
		if [[ $TYPE == "MOD" && $NUM -lt $FILTERMAX && $NUM -lt $PAGESIZE && $BUILDFILTER -eq 0 ]];then
			if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
				info "Unknown selection [$SELECTION], hit any key to continue..."
				read pause
				continue
			fi
			run_module ${FILTERMODS[$MODNUM]}
			pause
			continue
		fi
		
		if [[ $TYPE == "MOD" && $NUM -lt $TAGMAX && $NUM -lt $PAGESIZE && $BUILDFILTER -eq 1 ]];then
			if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
				info "Unknown selection [$SELECTION], hit any key to continue..."
				read pause
				continue
			fi
		
			if [ -z $FILTERSTRING ];then
				FILTERSTRING="${TAGS[$MODNUM]}"
			else
				FILTERSTRING="$FILTERSTRING,${TAGS[$MODNUM]}"
			fi
			continue
		fi

		if [[ $TYPE == "DEMO" && $NUM -lt $DEMOMAX && $NUM -lt $PAGESIZE ]];then
			if [[ $NUM -eq 0 && $SELECTION != "0" ]];then
				info "Unknown selection [$SELECTION], hit any key to continue..."
				read pause
				continue
			fi
			
			if [ $TYPELOCK -ge 1 ];then
				tar rf $TARFILE ./packages/${PACKAGE}/${DEMOS[$MODNUM]}
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

