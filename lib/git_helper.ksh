#!/bin/ksh

#Check if git_repos directory exists
if [ ! -d "./git_repos" ];then
	mkdir ./git_repos
fi

file="import_git.txt"
IFS=''
while read fline
do
	FIRSTCHAR=${fline:0:1}
        if [[ ! -z $FIRSTCHAR && $FIRSTCHAR == "#" ]];then
                        continue
        fi

	IFS='~'; typeset -a inp_array=($fline); unset IFS;

	echo "Processing repository ${inp_array[1]} as ${inp_array[0]}"	
	if [ ! -d ./git_repos/${inp_array[0]} ];then
		git clone ${inp_array[1]} ./git_repos/${inp_array[0]}
	else
		olddir=`pwd`
		cd ./git_repos/${inp_array[0]}
		git stash
		git pull
		cd $olddir
	fi

done < $file
