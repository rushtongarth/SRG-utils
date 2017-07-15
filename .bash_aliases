alias recall="tail -n+2 ~/.bash_aliases"
########################### Aliases for ls ##############################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -AlF'
alias la='ls -A'
alias l='ls -CF'
alias ltr="ls -ltr"
########################### Admin Aliases ###############################
alias sudo='sudo '
alias snano='sudo nano'
alias clearcache="bash ${HOME}/.utils/clearcache"
alias doupdate="bash ${HOME}/.utils/updater"
alias garthtex-update="${HOME}/.utils/scripts/GarthTexUpdate.sh"
########################### Utility Aliases #############################
alias myfn="${HOME}/.utils/scripts/fnlister.sh"
alias shells='cat /etc/shells'
alias piplist="pip list --format=columns"
alias tmpemail="bash ${HOME}/.utils/getemail"
########################### Remote Locations ############################
alias mathhost="ssh ${CUID}@mathsci03.ces.clemson.edu"
########################### Local Locations #############################
alias todev="cd ${HOME}/Code/dev"
