
# alias perso
alias ll='ls --color=always -l -h'
alias la='ls --color=always -A'
alias l='ls --color=always -CF'
alias asearch='apt-cache search'
alias ashow='apt-cache show'
alias h='fc -li 1'
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
is_bad_hash() { curl https://api.hashdd.com/v1/knownlevel/$1 ;}
to_lower() { tr [:upper:] [:lower:] <<< "$@" ;}