#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f $0))
#UTIL_ROOT=${HOME}/.utils
UTIL_ROOT=/tmp/util-test
#INST_ROOT=$HOME
INST_ROOT=/tmp/home-test
TMP_DL_DIR=/tmp/util-dl-tmp

URL_CFG=${SCRIPT_DIR}/remote.cfg

UTIL_BIN=${UTIL_ROOT}/bin
UTIL_SRC=${UTIL_ROOT}/src

ROOT_DIRS=( .python Code/{dev,softpacks} )

UTIL_DIRS=( bin funcs logs scripts src )

declare -A FILE_LIST
FILE_LIST[py]=.python/pythonrc.py
FILE_LIST[tex]=GarthTex.sty,GarthTexNotes.sty

function buildcore {
  test -d ${UTIL_ROOT} && printf "found existing %s\n" ${UTIL_ROOT} || mkdir -p ${UTIL_ROOT}
  for DIR in ${UTIL_DIRS[@]/#/${UTIL_ROOT}/}; do
    test -d $DIR && printf "found existing %s\n" ${DIR} || mkdir -p $DIR
  done
}

BIN_FILES=()
function grabremote {
  test -d ${TMP_DL_DIR} || mkdir ${TMP_DL_DIR}
  while read l; do
    ARR=( $(tr ',' ' ' <<<$l) )
    TMP=${TMP_DL_DIR}/${ARR[0]}
    MOVE_TO=$([ "${ARR[1]}" != '.' ] && printf "%s" "${UTIL_ROOT}/${ARR[1]}/${ARR[0]}" || printf "%s" "${UTIL_ROOT}/${ARR[0]}")
    fname=${ARR[2]##*/}
    if [[ "${fname#*.}" == 'zip' ]]; then
      wget ${ARR[2]} -O ${TMP}.zip
      unzip -q ${TMP}.zip -d ${TMP_DL_DIR}
      mv "${TMP_DL_DIR}/${ARR[0]}-${fname%.*}" "${MOVE_TO}"
    else
      MOVE_TO="${MOVE_TO}.${fname#*.}"
      wget ${ARR[2]} -O "${MOVE_TO}"
    fi
    test -f "${MOVE_TO}" && chmod 740 "${MOVE_TO}"
    BIN_FILES+=( "${MOVE_TO}" )
  done < $URL_CFG
  rm -r ${TMP_DL_DIR}
}

function loadbin {
  for F in ${BIN_FILES[@]}; do
    B=$(basename $F)
    noext=${B%.*}
    D=$(dirname $F)
    if [ -f $F ]; then
      TARG=$F
    elif [ -f $F/${noext}.sh ]; then
      TARG="$F/${noext}.sh"
    else
      continue
    fi
    test -L ${UTIL_BIN}/${noext} && ln -sr $TARG ${UTIL_BIN}/${noext}
  done
}

function rootprep {
  dir_arr=( "${ROOT_DIRS[@]}" )
  tobuild=( $(printf "%s\n" ${dir_arr[@]/#/${INST_ROOT}/} | sort -u) )
  for((i=0;i<${#tobuild[@]};i++)); do
    test -d "${tobuild[i]}" && printf "found existing %s\n" ${tobuild[i]} || mkdir -p "${tobuild[i]}"
  done
}

function pyconfig {
  if [ ! -e ${INST_ROOT}/${FILE_LIST[py]} ]; then
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
    )> ${INST_ROOT}/${FILE_LIST[py]}
  fi
}

buildcore

grabremote

rootprep

pyconfig

loadbin

#function pythonconfig {
#	. .utils/envload
#	export PYENV_ROOT=${HOME}/.utils/pyenv
#	if [ ! -d $PYENV_ROOT ]; then
#		mkdir $PYENV_ROOT
#		wget -q -O- https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
#	fi
#	pyenv_exe=$(find $PYENV_ROOT -type l -name pyenv | xargs -I@ readlink -f @)
#	$pyenv_exe update
#	if [ ! -e $HOME/.python/pythonrc.py ]; then
#		( cat <<EOF
#!/usr/bin/env python
#import os
#def clear(funcname=None):
#	if funcname:
#		if globals().has_key(funcname):
#			_ = globals().pop(funcname)
#			print "Function <%s> removed from namespace"%funcname
#		else:
#			print "Function <%s> not found in the namespace"%funcname
#	else:
#		_ = os.system('clear')
#EOF
#		)> $HOME/.python/pythonrc.py
#	fi
#	pyenv_init
#	pyenv install 2.7.13
#	pip install -U pip
#	pyenv_teardown
#}

#rootPrep "${ROOT_DIRS[@]}"



