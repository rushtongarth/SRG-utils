#!/bin/bash

export PYTHONSTARTUP="${HOME}/.python/pythonrc.py"

function pathext
{
  # Test path for string pattern
  # return 1 if not found so needs to be added to path
  # return 0 if found, so does not need to be added to path
  test 0 -eq $(grep -c $1 <( echo $2 | tr ':' '\n') ) && echo 1 || echo 0
}

# Following an update to texlive we adjust
# the following to correctly identify the
# location of latex documentation
# the commands which update the system path
# are located in: /etc/profile.d/texmf.sh
if [ -d /usr/share/texlive/2017 ]
then
  # update manpath if needed
  if (( `pathext texlive $MANPATH` ))
  then
    export MANPATH="/usr/share/texlive/2017/texmf-dist/doc/man:$MANPATH"
  fi
  # update info path if needed
  if (( `pathext texlive $INFOPATH` ))
  then
    export INFOPATH="/usr/share/texlive/2017/texmf-dist/doc/info:$INFOPATH"
  fi
fi

if [ -d ${HOME}/.utils ]
then
  if (( `pathext utils $PATH` ))
  then
    export PATH="${HOME}/.utils/bin:$PATH"
  fi
  . ~/.utils/funcs/helpers
fi
if $(shopt -q login_shell); then
  . ~/.bashrc
fi

export GZIP=-9
test -z $HISTTIMEFORMAT && export HISTTIMEFORMAT="[%F]@[%T] "
