#!/bin/bash

noteloc="${HOME}/Documents/Library/study/notes"
codeloc="${HOME}/Code"
backloc="${HOME}.coderepo"
logloc="${backloc}/logs"
stamp=$(date +%Y%m%d%S)
logdump="${logloc}/codeback.${stamp}.log"
currstatus=0
mode=0

function existance
{
test -d ${codeloc} || currstatus=1
test -d ${noteloc} || currstatus=2

if [[ $currstatus -eq 1 ]]; then
  printf "unable to find %s\n" "${codeloc}" >> ${logdump}
  printf "aborting backup\n" >> ${logdump}
  exit $currstatus
elif [[ $currstatus -eq 2 ]]; then
  printf "unable to find %s\n" "${noteloc}" >> ${logdump}
  printf "aborting backup\n" >> ${logdump}
  exit $currstatus
else
  printf "found %s\n" "${codeloc}" >> ${logdump}
  printf "Starting backup\n" >> ${logdump}
fi

if [[ ! -d ${backloc} ]]; then
  mkdir ${backloc}
  test -s ${codeloc}/.known || find {${codeloc},${noteloc}} -type f -exec md5sum {} \; > ${codeloc}/.known
#  test -s ${codeloc}/.known || find ${noteloc} -type f -exec md5sum {} \; >> ${codeloc}/.known
  cp -v ${codeloc}/.known ${backloc}/.known
  mode=1
else
  test -s ${codeloc}/.known || find {${codeloc},${noteloc}} -type f -exec md5sum {} \; > ${codeloc}/.known
#  test -s ${codeloc}/.known || find ${noteloc} -type f -exec md5sum {} \; >> ${codeloc}/.known
  test -s ${backloc}/.known || cp -v ${codeloc}/.known ${backloc}/.known
fi
oldtar=$(sort <( ls -1 $backloc ) | tail -n 1)
newtar="code.backup.${stamp}.tar"
curtar="${backloc}/${newtar}"
}

function uniqueness
{
printf "performing md5sum file update for %s\n" "$codeloc" > ${logdump}
find {${codeloc},${noteloc}} -type f -exec md5sum {} \; > ${codeloc}/.known

found=`diff -y --suppress-common-lines <( awk '{print $1}' ${codeloc}/.known ) <( awk '{print $1}' ${backloc}/.known )`
foundfiles=()
if [[ ${#found} -ne 0 ]]; then
  printf '%0.1s' '#'{1..5} >> ${logdump}
  printf '\n' >> ${logdump}
  tar -cvf "${curtar}" {${noteloc},${codeloc}} 2>&1 | grep -v 'Removing leading' >> ${logdump}
  printf '%0.1s' '#'{1..5} >> ${logdump}
  printf '\n' >> ${logdump}
  printf "created new tar file: %s, " "${curtar}" >> ${logdump}
  nos=( `grep -n '#####' ${logdump} | cut -d':' -f 1` )
  printf "containing %s files\n" "$(( ${nos[1]} - ${nos[0]} -1 ))" >> ${logdump}
else
  printf "everything is up to date\n" >> ${logdump}
  exit 0
fi
}
function cleanup
{
printf "syncing md5 files\n" >> ${logdump}
cp -v "${codeloc}/.known" "${backloc}/.known" >> ${logdump}
oldfiles=( $(find ${backloc} -name '*tar' -o -name '*tar.xz' -o -name '*tar.gz' | sort -r ) )
numfound=${#oldfiles[@]}
if [[ $numfound -ge 3 ]]; then
    for i in ${oldfiles[@]:2}
    do
      rm -v $i >> ${logdump}
    done
fi
oldlogs=( $(find $logloc -name '*log' | sort -r ) )
logcount=${#oldlogs[@]}
if [[ $logcount -ge 3 ]]; then
  for i in ${oldlogs[@]:2}
  do
    rm -v $i >> ${logdump}
  done
fi
}
function compressor
{
  if [[ -e ${curtar} ]] && [[ ! -e ${curtar}.gz ]]; then
      gzip -9 ${curtar}
  fi
}
### MAIN ###

existance
uniqueness
compressor
cleanup



