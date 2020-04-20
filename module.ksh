#!/bin/ksh

# Module Details

echo "Enter module name"
read mod

## check if the file already exists
if test -f $mod.mod; then
    echo "${mod}.mod exists, Do want to replace it?? Y/N"
    read ans
    case $ans in
           Y|y)
                   rm -rf ${mod}.mod
                   ;;
           N|n)
                   exit
                   ;;
    esac
fi
echo " "

#Capture Kuberntenes related variables

echo "Enter Namespace name:"
read NS
if test -z "$NS"
then
      echo "Namespace is set to "default""
      NS=default
fi

echo "Enter Bucket name:"
read bucket
if test -z "$bucket"
then
      echo "Bucket is set to "default""
      bucket=default
fi


echo "Enter POD name:"
read pod
if test -z "$pod"
then
      echo "pod is set to "cb-example-0000""
      pod=cb-example-0000
fi


# Capture PROMPT
echo " "
echo "What do you need end user to provide?"
echo " "
array=()
while IFS= read -r -p "Next item (end with an empty line): " line; do
    [[ $line ]] || break  # break if line is empty
    array+=("$line")
done

len=`echo ${#array[@]}`

for i in "${!array[@]}"
do
	printf '%s\n' "PROMPT~${array[$i]}~VAR$((i+1))" >> ${mod}.mod

done



#Capture CODE

echo "Do you have a script that you want to run?(Y/N)"
read ans
case $ans in
           Y|y)
                   echo "what is the script name"
		   read script
		   echo "CODE~${script}~{{NS}},{{bucket}},{{pod}}" >> ${mod}.mod

                   ;;
           N|n)
                   exit
                   ;;
    esac
echo "module ${mod}.mod has been generated"
