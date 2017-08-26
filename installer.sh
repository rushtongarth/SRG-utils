#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f $0))
# config file of remote resources to pull
URL_CFG=${SCRIPT_DIR}/remote.cfg
# tmp directory where remote files are landed
TMP_DL_DIR=/tmp/util-dl-tmp
# sigh... this really should be done with getopts
if [[ $1 == '-t' ]]; then
  printf "executing in test mode\n"
  UTIL_ROOT=/tmp/util-test
  INST_ROOT=/tmp/home-test
elif [[ $1 == '-i' ]]; then
  INST_ROOT=${HOME}
  UTIL_ROOT=${INST_ROOT}/.utils
  printf "performing install to: %s\n" ${UTIL_ROOT}
else
  printf "please specify one of the following\n"
  printf "%s -t <executes in testmode>\n" $0
  printf "%s -i <installs files to home directory>\n" $0
  exit 1
fi
# these are used enough it makes sense to just define them
UTIL_BIN=${UTIL_ROOT}/bin
UTIL_SRC=${UTIL_ROOT}/src
# test to see if these need to be built later on
ROOT_DIRS=( .python Code/{dev,softpacks} )
# subdirs for util dir these are built later on
UTIL_DIRS=( bin funcs logs scripts src )
# associative array containing files to create
#  with keys denoting the program (by extension)
#  they belong to
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


