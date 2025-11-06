
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
alias i='sudo ag install'
alias u='sudo ag update'
alias upp='sudo ag update && sudo ag upgrade'
alias uppr='sudo ag update && sudo ag dist-upgrade'
alias yt-dlp='$my_bin_path/yt-dlp -o "%(title)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133'
alias yt-dlp_uniq='$my_bin_path/yt-dlp -o "%(title)s - %(epoch)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133'
alias yt-dlp_best='$my_bin_path/yt-dlp -o "%(title)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133 -f "bestvideo+bestaudio"'
alias yt-dlp_1080p='$my_bin_path/yt-dlp -o "%(title)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133 -f '\''bestvideo[height<=1080]+bestaudio'\'''
alias yt-dlp_1440p='$my_bin_path/yt-dlp -o "%(title)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133 -f '\''bestvideo[height<=1440]+bestaudio'\'''
alias yt-dlp_onlybestaudio='$my_bin_path/yt-dlp -o "%(title)s.%(ext)s" --parse-metadata "[%(title)s](%(webpage_url)s):%(meta_description)s" --parse-metadata ":(?P<meta_synopsis>)" --embed-metadata --impersonate Chrome-133 -f bestaudio --extract-audio --audio-format best'
alias free='free -ht'
alias update_my_sysupdate_script='sudo bash -c '\''rm -f $my_bin_path/sysupdate && wget -q -P $my_bin_path "https://raw.githubusercontent.com/NRGLine4Sec/config-l/main/sysupdate" && chmod +x $my_bin_path/sysupdate'\'''
alias update_my_auditd_rules='sudo bash -c '\''rm -f /etc/audit/rules.d/audit.rules && wget -q -P /etc/audit/rules.d/ "https://raw.githubusercontent.com/NRGLine4Sec/config-l/main/audit.rules" && augenrules --check && systemctl restart auditd'\'''
alias showshortcut='dconf dump /org/gnome/settings-daemon/plugins/media-keys/'
alias sshuttle='sudo /root/.local/bin/sshuttle'
alias my_ext_ip="curl --silent --location 'https://ipinfo.io/ip'"
alias last_apt_kernel='apt-cache search --names-only "linux-(headers|image)-[[:digit:]]\.[[:digit:]]+\.[[:digit:]]+(-[[:digit:]]+|\+bpo)-(amd64$|amd64-unsigned$)" | sort'
is_bad_hash() { curl https://api.hashdd.com/v1/knownlevel/$1 ;}
to_lower() { tr [:upper:] [:lower:] <<< "$@" ;}
mpv_youtube() { mpv <($my_bin_path --impersonate Chrome-133 -o - "$1") }
mpv_youtube_audio() { mpv --no-video <($my_bin_path -f bestaudio --extract-audio --audio-format best --impersonate Chrome-133 -o - "$1") }
youtube_description() { $my_bin_path/yt-dlp --impersonate Chrome-133 --playlist-items 0 --print description "$1" ;}

# for Ansible vault editor
export EDITOR=nano

# for python binnary
export PATH="$PATH:/home/$local_user/.local/bin"