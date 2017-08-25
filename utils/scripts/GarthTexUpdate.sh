#!/bin/bash
THISSCRIPT=$(readlink -f $0)
SCRIPTNAME=$(basename $THISSCRIPT)
SOURCE_DIR=${HOME}/Code/bylang/GarthTex
TARGET_DIR=${HOME}/texmf/tex/latex/GarthTex
TEXLOC=/usr/share/texlive
SCR_USER=${SUDO_USER:-$USER}

function eproc {
	local OUTSTR
	OUTSTR=( "$@" )

	cat <<-EOF1
	ERROR: [ ${OUTSTR[@]} ]
	EOF1
}

function usage {

cat <<EOF
${SCRIPTNAME}:
USAGE:
	Automated update process for user defined LaTeX packages.
	Performs the following:

sudo -u $SCR_USER cp -uv $SOURCE_DIR/GarthTexNotes.sty $TARGET_DIR
sudo -u $SCR_USER cp -uv $SOURCE_DIR/GarthTex.sty $TARGET_DIR
sudo texhash

EOF
}

if [[ $USER != 'root' ]];then
	eproc "Script must be run as root!"
	usage
	exit 1
fi

printf "Locating system texhash...\n"
USEHASH=$(find $TEXLOC -maxdepth 4 -path "$TEXLOC/*bin/*/texhash")
test -z $USEHASH && eproc "unable to find texhash in $TEXLOC" && exit 2

printf "Using %s\n" ${USEHASH}


sudo -u $SUDO_USER cp -uv ${SOURCE_DIR}/GarthTexNotes.sty ${TARGET_DIR}
sudo -u $SUDO_USER cp -uv ${SOURCE_DIR}/GarthTex.sty ${TARGET_DIR}

sudo $USEHASH
