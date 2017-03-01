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
########################### Utility Aliases #############################
alias myfunctions="grep function ${HOME}/.bash_profile ${HOME}/.utils/funcs/* | awk -F/ '{print \$NF}' | sed 's#\(.*\):function \(.*\)#\1-->\2#g'"
alias shells='cat /etc/shells'
alias piplist="pip list --format=freeze | column -s== -t | sed 's/ /./g'"
########################### Remote Locations ############################
alias mathhost="ssh ${CUID}@mathsci03.ces.clemson.edu"
alias tmpemail="bash ${HOME}/.utils/getemail"
########################### Local Locations #############################
alias todev="cd ${HOME}/Code/dev"
