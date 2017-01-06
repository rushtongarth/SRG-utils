#!/bin/bash

export PYTHONSTARTUP="${HOME}/.python/pythonrc.py"
test `which keychain` && eval $(keychain --quiet --eval --agents ssh id_rsa)



if [ -d $HOME/.utils ]
then
	export PATH=$HOME/.utils:$PATH
	. ~/.utils/envprep
fi

function packlist
{
	if [[ -z $1 ]]
	then
		printf "please provide a package\n"
	else
		dpkg -l | grep $1
	fi
}


function latexlist
{
	local use="USAGE: ${FUNCNAME} [OPTIONS] <pattern to find>\n\n"
	use=${use}"OPTIONS:\n"
	use=${use}"\t${FUNCNAME} -s <pattern name starts with>\n"
	use=${use}"\t${FUNCNAME} -n <pattern not in name>\n\n"
	local texsrcroot=/usr/share/texlive/texmf-dist/tex/latex
	local texlocs="${texsrcroot}"
	local texsrcfull
	if [[ $# -eq 0 ]]
	then
		printf "please provide a package\n${use}"
	elif [[ $# -eq 1 &&  $1 == -* ]] || ([[ $# -eq 2 ]] && ([[ $1 != '-n' ]] && [[ $1 != '-s' ]]))
	then
		printf "Command not understood: $1\n${use}"
	else
		printf "Searching in: $texlocs\n"
		texsrcfull=$( find $texsrcroot -type f -name '*sty' -o -name '*tex' | sort -u )
		if [[ $# -eq 1 ]] && [[ $1 != -* ]]
		then
			printf "Results:\n"
			printf "$texsrcfull\n" | grep $1
		elif [[ $# -eq 2 ]]
		then
			if [[ $1 == '-s' ]]
			then
				printf "Results:\n"
				printf "$texsrcfull\n" | while read line
				do
					if grep -q '^'$2 <<<${line##*/}
					then
						printf ${line}
						break
					fi
				done
			elif [[ $1 == '-n' ]]
			then
				printf "Results:\n"
				printf "$texsrcfull\n" | grep -v $2
			fi
		fi
	fi
	printf "\n"
}
