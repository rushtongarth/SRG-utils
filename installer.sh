#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f $0))
HOME_DIRS=( .utils .python Code/{dev,softpacks} )
FILE_LIST=( .python/pythonrc.py pip devmode srg )
TEX_FILES=( GarthTex.sty GarthTexNotes.sty )


function dirBuilder {
	arr_tobuild=( "$@" )
	tobuild=( $(printf "%s\n" ${arr_tobuild[@]/#/$HOME/} | sort -u) )
	for((i=0;i<${#tobuild[@]};i++))
	do
		test -d "${tobuild[i]}" || echo mkdir -p "${tobuild[i]}"
	done
	find $SCRIPT_DIR/.utils -type f | while read line
	do 
		SFILE=$(sed 's#'$SCRIPT_DIR'#'$HOME'#g' <<<$line)
		cp -u $line $SFILE
	done
}
function pythonconfig { 
	. .utils/envload
	export PYENV_ROOT=${HOME}/.utils/pyenv
	if [ ! -d $PYENV_ROOT ]
	then
		mkdir $PYENV_ROOT
		wget -q -O- https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
	fi
	pyenv_exe=$(find $PYENV_ROOT -type l -name pyenv | xargs -I@ readlink -f @)
	$pyenv_exe update
	if [ ! -e $HOME/.python/pythonrc.py ]
	then
		( cat <<EOF
#!/usr/bin/env python
import os

def clear(funcname=None):
	if funcname:
		if globals().has_key(funcname):
			_ = globals().pop(funcname)
			print "Function <%s> removed from namespace"%funcname
		else:
			print "Function <%s> not found in the namespace"%funcname
	else:
		_ = os.system('clear')
EOF
		)> $HOME/.python/pythonrc.py
	fi
	pyenv_init
	pyenv install 2.7.12
	pip install -U pip
	pyenv_teardown
}

#dirBuilder "${HOME_DIRS[@]}"
#pythonconfig


