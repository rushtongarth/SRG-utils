alias recall="tail -n+2 ~/.bash_aliases"
########################### Aliases for ls ##############################
alias la="ls -A"
alias ll="ls -l"
alias ltr="ls -ltr"
########################### Admin Aliases ###############################
alias sudo='sudo '
alias clearcache="bash ${HOME}/.utils/clearcache"
alias doupdate="bash ${HOME}/.utils/updater"
########################### Utility Aliases #############################
alias myfunctions="grep function ${HOME}/.bash_profile"
alias shells='cat /etc/shells'
####
# this should be the default soon...
alias mypip="pip install --user "
####
alias mypy="ipython --profile=srg"
alias devpy="ipython --profile=devmode"
alias piplist="pip list --format=freeze | column -s== -t | sed 's/ /./g'"
########################### Remote Locations ############################
alias mathhost="ssh USERNAME@mathsci03.ces.clemson.edu"
alias myip="echo $(curl -s http://ipecho.net/plain)"
########################### Utility Aliases #############################
alias sage="bash ${HOME}/Code/softpacks/SageMath/sage"
alias sage-nb="bash ${HOME}/Code/softpacks/SageMath/sage --notebook=sagenb"
########################### Local Locations #############################
alias todev="cd ${HOME}/Code/dev"