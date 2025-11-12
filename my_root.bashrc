
# alias perso
alias ll='ls --color=always -l -h'
alias la='ls --color=always -A'
alias l='ls --color=always -CF'
alias asearch='apt-cache search'
alias ashow='apt-cache show'
alias h='history'
alias nn='nano -c'
alias cl='clear'
alias grep='grep --color=auto'
alias diff='diff --unified=0 --color=auto'
alias diff_side_by_side='/usr/bin/diff --color=auto --side-by-side --width=$COLUMNS'
alias i='ag install'
alias ip='ip --color=auto'
alias u='ag update'
alias upp='ag update && ag upgrade'
alias uppr='ag update && ag dist-upgrade'
alias free='free -ht'
HISTTIMEFORMAT=\"%Y/%m/%d %T   \"
to_lower() { tr [:upper:] [:lower:] <<< "$@" ;}
to_upper() { tr [:lower:] [:upper:] <<< "$@" ;}

# share history between terminals
# ref : https://subbass.blogspot.com/2009/10/howto-sync-bash-history-between.html
# ref : https://stackoverflow.com/questions/15116806/how-can-i-see-all-of-the-bash-history
shopt -s histappend
PROMPT_COMMAND="history -n; history -a"
unset HISTFILESIZE
HISTSIZE=20000