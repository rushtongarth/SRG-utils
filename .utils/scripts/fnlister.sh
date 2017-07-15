#!/bin/bash

function outprep
{
	local var=$(echo $@ | awk -F/ '{print $NF}')
	echo $var | sed -n 's#\(.*\):function \(.*\)#\1,\2#g; p'
}

function lister
{
	local FULL=()
	local LOCS=()
	local tmp
	LOCS+=( .bash_profile .utils/funcs )
	for ((i=0;i<${#LOCS[@]};i++))
	do
		tmp=$(find ${HOME}/${LOCS[i]} -type f | xargs -I@ grep -H '^function' @ )
		FULL+=( $(echo "$tmp" | grep -v '#') )
	done
	(
	echo 'Location,Function'
	echo '--------------,---------------'
	for ((i=0;i<${#FULL[@]};i++))
	do
		outprep ${FULL[i]} ${FULL[++i]} #| sed 's#\(.*\):function \(.*\)#\1-->\2#g'
	done
	) | column -s',' -t
}
lister
