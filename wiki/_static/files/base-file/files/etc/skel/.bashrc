
if [ "`id -u`" -eq 0 ]; then
	PS1="\[\e[01;31m\]\u\[\e[01;32m\]@\h:\[\e[01;34m\]\w\[\e[0m\]# "

      #PS1='# '
    else
      #PS1='$ '
	PS1="\[\e[01;31m\]\u\[\e[01;32m\]@\h:\[\e[01;34m\]\w\[\e[0m\]$ "

    fi
    
    export NO_AT_BRIDGE=1
