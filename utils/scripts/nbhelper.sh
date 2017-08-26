#!/bin/bash

LOCAL_CODE="${HOME}/Code"
SHARE_CODE="${HOME}/Dropbox/Code"
LOCAL_NBS="${LOCAL_CODE}/dev/notebooks"
SHARE_NBS="${SHARE_CODE}/notebooks"
STND_DIR="stdnotes"
SAGE_DIR="sagebooks"
THIS_SCRIPT=$(basename $0)
NB_STYLE=( "$@" )

function usage {
if [[ $# -gt 1 ]]
then
	printf "ERROR: Exactly 2 arguments are required, [received %s]\n\n" $1
fi
cat <<EOF
$THIS_SCRIPT [stnd|sage] [local|share]
USAGE:
Script for loading the appropriate jupyter notebook
possible options are:
-stnd local:
--load notebook from: "${LOCAL_NBS}/${STND_DIR}"
-stnd share:
--load notebook from: "${SHARE_NBS}/${STND_DIR}"
-sage local
--load notebook from: "${LOCAL_NBS}/${SAGE_DIR}"
-sage share
--load notebook from: "${SHARE_NBS}/${SAGE_DIR}"
EOF
}

function pathcheck {
	local toadd="${LOCAL_CODE}/softpacks/cling/bin"
	need=$(echo $PATH | awk -v var=$toadd -F':' '
		{
			for(i=1;i<=NF;i++){
				if(index($i,var)>0){
					print $1
				}
		}
	}')
	if [[ ${#need} ]]
	then
		export PATH=${toadd}:$PATH
	fi
}
function nblocation {
	local nb=$1
	local bookloc=$2
	if [[ "$bookloc" == share ]]
	then
		NB_DIR="${SHARE_NBS}"
	elif [[ "$bookloc" == local ]]
	then
		NB_DIR="${LOCAL_NBS}"
	fi
	if [[ "$nb" == sage ]]
	then
		NB_EXE="${LOCAL_CODE}/softpacks/SageMath/sage --notebook=jupyter"
		NB_DIR="${NB_DIR}/sagebooks"
	elif [[ "$nb" == stnd ]]
	then
		NB_EXE="jupyter-notebook"
		NB_DIR="${NB_DIR}/stdnotes"
	fi
}
function cmddef {
	if [[ $# -eq 2 ]]
	then
		nblocation $1 $2
		echo "$NB_EXE --notebook-dir=${NB_DIR}"
	else
		if [[ $# -eq 0 ]]
		then
			return 1
		fi
		return 2
	fi
}

CMD=$(cmddef ${NB_STYLE[@]} || echo $?)
#echo $CMD
#exit 0
if [[ ${#CMD} -ne 1 ]]
then
	eval $CMD
else
	usage $CMD
fi
#eval $(
#|| echo echo 'ERROR')
#usage 1
