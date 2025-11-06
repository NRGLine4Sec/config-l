#!/bin/bash
##
## Made by NRGLine4Sec
##


## Pour obtenir toutes les commandes utilisés sur un système : sudo grep -o "COMMAND.*" /var/log/auth.log

## Pour désactiver le bip système : xset b off

# Regarder comment ils font avec le script shell de remediation : http://static.open-scap.org/ssg-guides/ssg-debian8-guide-anssi_np_nt28_high.html#xccdf_org.ssgproject.content_rule_sshd_disable_root_login
# Regarder aussi pour ajouter cette conf la : http://static.open-scap.org/ssg-guides/ssg-debian8-guide-anssi_np_nt28_high.html#xccdf_org.ssgproject.content_rule_sshd_disable_empty_passwords
##
## On peut aussi utiliser "if !" pour indiquer la négation de la condition d'un if par exempe if ! wget www.google.Fr; then echo "pas d'accès à Internet";fi
##
## Regarder de près cet outil la : https://github.com/gustavo-iniguez-goya/arpsentinel-applet
##
## Regarder pour voir si on install gnome-boxes
##
## Regarder pour voir si on install zulucrypt
##
## Une extension Gnome permet de faire en sorte de désactivé le black screen après avoir vérouiller la session (Win + L) : https://extensions.gnome.org/extension/1414/unblank/
##
## ajouter l'outil suivant https://github.com/orhun/kmon
##
## regarder pour savoir s'il y a besoin d'ajouter : https://github.com/imsnif/bandwhich
##
## regarder si on a besoin de ça : https://github.com/denisidoro/navi
## ça fonctionne vriament bien et c'est simple d'utilisation, il faudrait simplement créer les cheatsheats en fonction des besoins
##
## a garder dans un coin en cas d'upgrade de Gnome ( pour installer des gnom-extension) : https://github.com/gustavo-iniguez-goya/opensnitch/issues/44#issuecomment-654373737
##
## Tester l'outil ultracopier (apt-get install ultracopier) et notamment son intégration avec nautilus
##
## Regarder pour installer tumbler-plugins-extra
#
# ----
# apparement ce fichier de conf est renseigner par libreoffice en faisant le delta entre la conf par défaut et les modifs de conf, il faudrait donc voir ce que contient le fichier après une install, faire les modifs nécessaire et faire un diff pour obtenir les paramètres qui sont ajouter dans le fichier
# /.config/libreoffice/*/user/registrymodifications.xcu
# https://forum.openoffice.org/en/forum/viewtopic.php?f=16&t=64520
# https://askubuntu.com/questions/83605/how-do-i-export-customized-libreoffice-config-files
# ----

# ref : [Configurer sa souris Logitech MX Master sous Linux (Ubuntu) – Miximum](https://www.miximum.fr/blog/configurer-sa-souris-logitech-mx-master-sous-linux-ubuntu/)

## copier leur système d'affiche pour l'usage : [Remove Elasticsearch indices that older than a given date.](https://gist.github.com/yumminhuang/ec03bcacbbc6434412b82ca0c34e7a18)

## regarder de plus près cette outil : https://github.com/jwyllie83/tcpping (ou au moins trouver la commande équivalente pour faire du ping TCP avec nmap)
## https://hub.packtpub.com/discovering-network-hosts-with-tcp-syn-and-tcp-ack-ping-scans-in-nmaptutorial/

## regarder nsntrace (apt-get install -y nsntrace)
## sudo nsntrace -d enp -o result.pcap -u $USER signal-desktop

# script à regarder de plus près pour voir comment intégrer un affichage des tirets et des hashtags en fonction de la longueur du terminal et du message a afficher
# declare -ag COL_LEN=($(wget -qO- http://bit.ly/cpu_flags | awk -F\| 'BEGIN { NR==1;getline; H1=$1; H2=$2; H3=$3 } { for (i=1; i<=NF; i++) { max[i] = length($i) > max[i] ? length($i) : max[i] ;ncols = i > ncols ? i : ncols }} END { {print H2":"max[2]"\n"H3":"max[3]"\n"H1":"max[1]"\n"}}'))
# export LS='─'
# (printf "%s\n" ${COL_LEN[@]%%:*} | paste -sd\| && printf "%s\n" ${COL_LEN[@]##*:} | xargs -n1 bash -c 'eval printf "%.3s" ${LS}{1..${0}};echo' | paste -sd"|"
# wget -qO- http://bit.ly/cpu_flags | awk -F\| '!/^CLASS/{print $2"|"$3"|"$1}') | column -nexts '|' | sed '1,2s/.*$/'$(printf "\e[1m")'&'$(printf "\e[0m")'/'

################################################################################
## ROADMAP
##------------------------------------------------------------------------------
# - tester de faire l'instllation des apps avec apt-fast à la place de apt-get et mesurer la différence de temps d'excution du script
# - essayer de comprendre pouquoi il y a parfois un certain nombre de fichier qui devrait appartenir à l'utilisaeur et qui appartiennet pourtant à l'utilisateur root, parfois, c'est des rerpertoire entier qui appartiennent à root dans .config/
# Peut être un problème dans l'utilisation de ExeAsUser ?, essayer de monitorer avec des tests.
# - regarder de près concernant l'intéret de d'installer le librairie du wivedine de google dans le chromium de debian
# - rajouter une variable qui contient l'usage du script pour afficher de quel manière l'utiliser lorsque d'un des arguments n'est pas correct (l'équivalent d'un --help)
# - potentiellement intégrer l'installation de l'outil xdotool (pour wayland il faut plutot ydotool)
# - potentiellement installer le paquet iozone3
# - potentiellement installer qview (https://interversehq.com/qview/download/)
# - regarder pour voir si on peut gérer la taille de la ligne affiché avec fmt --width=60 en se basant sur la longueur max donné par la fonction check_available_columns_in_terminal
# regarder si on ajoute les commandes suivantes :
# Stop and disable apt-daily upgrade services;
# systemctl stop apt-daily.timer
# systemctl stop apt-daily-upgrade.timer
# - rajouter dans le script sysupdate la possibilité de n'update qu'un seul paquet en particulier en le méttant en argument de l'apelle au script

################################################################################

################################################################################
## Test que le script est executé en tant que root
##------------------------------------------------------------------------------
check_script_run_with_privileges() {
  if [ $EUID != 0 ]; then
    echo "Le script doit être executer en tant que root: # sudo $0" 1>&2
    exit 1
  fi
}
check_script_run_with_privileges
################################################################################

################################################################################
## Log de debug (on redirige set -x dans /tmp/ng_install_set-x_logfile)
##------------------------------------------------------------------------------
redirect_and_enable_bash_debug_log() {
  exec 19>/tmp/ng_install_set-x_logfile
  export BASH_XTRACEFD='19'
  set -x
  export SHELLOPTS
}
redirect_and_enable_bash_debug_log
# à noter qu'on utilise : set +x
# à l'intérieur des fonctions qui nécessient d'installer DKMS car sinon cela pose problème pour l'install de DKMS et en plus la variable BASH_XTRACEFD n'est pas respéctée, donc la sortie de XTRACE se retrouve dans la stderr, et donc dans le fichier de log, et surtout DKMS produit une quantité de log XTRACE absolument énorme car ça doit faire appel à beaucoup de scripts qui font beaucoup de check
################################################################################

################################################################################
## Initialisation de la variable qui permet le calcul du temps d'execution du script
##------------------------------------------------------------------------------
#juste pour vérifier que la fonction de calcul du temps d'execution fonctionne correctement, essayer ensuite de trouver une meilleur solution et de supprimer cette ligne
timedatectl set-timezone Europe/Paris >/dev/null
systemctl restart systemd-timesyncd >/dev/null
# utilisé à des fin de stats pour l'éxecution du script
start_time="$(date +%s)"
# pose problème lorsque la date et l'heure ne sont pas à jour (ce qui arrive souvent lors de reprise de snapshot)
# on est obliger de récuperer le start_time une fois la resyncro éffectué, sinon la valeur du temps d'éxecution du script est abérante
################################################################################

script_name='ng_install.sh'
log_dir_path='/var/log/postinstall'

################################################################################
## Vérification que le script s'execute pour la première fois
##------------------------------------------------------------------------------
check_if_fisrt_time_script_executed() {
  if $(grep -qE '[[:blank:]]+Fin du script[[:blank:]]+' "$log_dir_path"/*/log_script_install*.log 2>/dev/null); then
    fisrt_time_script_executed=1
  fi
}
check_if_fisrt_time_script_executed
################################################################################

################################################################################
## usage guide
##------------------------------------------------------------------------------
print_usage_guide() {
  cat << EOF
Usage: sudo bash $script_name [OPTIONS]
Options:
  -l or --log 			Print the log file when the script terminated.
  -s or --shutdown 			Shutdown the PC when the script terminated.
  -r or --reboot 			Reboot the PC when the script terminated.
  -h or --help 			Print this message.
  -e or --error 			Print error.
  -v or --version 			Print the script version.
  -pr or --pro 			Configure the PC with the PRO configuration.
  -pe or --perso 			Configure the PC with the PERSO configuration.
  Usage examples:
  $script_name -e			# Execute the script and print errors in stdout.
EOF
}
################################################################################

################################################################################
## options d'execution du script
##------------------------------------------------------------------------------
for param in "$@"; do
  case $param in
    '-h'|'--help')
        print_usage_guide ;;
    '-v'|'--version')
        echo "$script_version" ;;
    '-s'|'--shutdown')
        shutdown_after_install=1 ;;
    '-pr'|'--pro')
        conf_pro=1 ;;
    '-pe'|'--perso')
        conf_perso=1 ;;
    '-l'|'--log')
        show_log=1 ;;
    '-e'|'--error')
        show_only_error=1 ;;
    '-r'|'--reboot')
        reboot_after_install=1 ;;
    *) echo 'Invalid option'; print_usage_guide; exit 1 ;;
  esac
done

# [Multiple arguments using "case" : bash](https://www.reddit.com/r/bash/comments/brfsf8/multiple_arguments_using_case/)
################################################################################

# Définition des variables de couleur
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
NOIR='\e[0;30m'

is_dir_present() {
  local dir="$1"
  [ -d "$dir" ]
}
export -f is_dir_present

is_file_present() {
  local file="$1"
  [ -f "$file" ]
}
export -f is_file_present

is_dir_present_or_mkdir() {
  local dir="$1"
  [ -d "$dir" ] || mkdir -p "$dir"
}
export -f is_dir_present_or_mkdir

is_dir_present_and_rmdir() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  [ -d "$dir" ] && rm -rf "$dir"
}
export -f is_dir_present_and_rmdir

reset_dir() {
  local dir="$1"
  is_dir_present_and_rmdir "$dir"
  is_dir_present_or_mkdir "$dir"
}
export -f reset_dir

is_file_present_and_rmfile() {
  local file="$1"
  [ -f "$file" ] || return 0
  [ -f "$file" ] && rm -f "$file"
}
export -f is_file_present_and_rmfile

# PS: à noter qu'on utilise [ -f "$file" ] || return 0 pour ne pas renvoyer de code d'érreur si le fichier n'existe pas
# on ne peut pas rajouter le || return 0 à la fin de la commande rm car sinon on aura un retour positif même dans les cas ou la suppression du fichier a été un échec

is_dir_empty() {
  local dir="$1"
  find "$dir" -maxdepth 0 -type d -empty 2>/dev/null | grep -q .
}
export -f is_dir_empty
# inspiré de : [Bash scripting: test for empty directory - Super User](https://superuser.com/questions/352289/bash-scripting-test-for-empty-directory/352387#352387)

is_dir_not_present_or_empty() {
  local dir="$1"
  ( is_dir_present "$dir" && is_dir_empty "$dir" ) || return 0
}
export -f is_dir_not_present_or_empty

is_dir_present_and_empty() {
  local dir="$1"
  is_dir_present "$dir" && is_dir_empty "$dir"
}
export -f is_dir_present_and_empty

################################################################################
## création des fichiers de log
##------------------------------------------------------------------------------
create_log_files() {
  now="$(date +"%d-%m-%Y")"
  log_dir=""$log_dir_path"/"$now""
  is_dir_present_or_mkdir "$log_dir"
  log_file=""$log_dir"/log_script_install-"$now".log"
  touch "$log_file"
  stdout_file=""$log_dir"/stdout_on_script_execution-"$now".log"
  touch "$stdout_file"
  cat> "$log_file" << 'EOF'
####################################################################
#                          Debut du script                         #
####################################################################

--------------------------------------------------------------------
EOF
}
create_log_files
################################################################################

################################################################################
## copie du script ng_install.sh dans "$log_dir"
##------------------------------------------------------------------------------
cp "$(readlink -f "${BASH_SOURCE[0]}")" "$log_dir"/"$(basename "${BASH_SOURCE[0]}")-"$now"" && \
chmod 600 "$log_dir"/"$(basename "${BASH_SOURCE[0]}")-"$now""
# on copie le contenu du script dans le répertoire $log_dir pour pouvoir savoir plus tard ce qu'il y avait dans le script au moment de son execution
# le chmod permet de s'assurer qu'il ne sera pas executer par mégarde et qu'il n'est accessible qu'en lecture pour root
# si le cp ne marche pas, tenter de faire cat "$(readlink -f "${BASH_SOURCE[0]}")" > "$log_dir"/"$(basename "$0")"
################################################################################

script_path="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
# équivalent POSIX compliant :
# script_path=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
# ref : [Determine the path of the executing BASH script - Stack Overflow](https://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script/630645#630645)

################################################################################
## redirection du current directory dans le HOME directory
##------------------------------------------------------------------------------
cd
################################################################################

################################################################################
## définition de certaines variables
##------------------------------------------------------------------------------
# importation des varaibles d'environnement
#source ./env.sh
SSH_Port=''
################################################################################

################################################################################
## fonction d'éxecution et d'affichage displayandexec
##------------------------------------------------------------------------------
# Premier parametre: message
# Autres parametres: command
displayandexec() {
  local message=$1
  echo -n "[En cours] $message" | tee --append "$stdout_file"
  shift
  echo ">>> $*" >> "$log_file" 2>&1
  bash -c "$*" >> "$log_file" 2>&1
  local ret=$?
  if [ $ret != 0 ]; then
    echo -e "\r $message                ${RED}[ERROR]${RESET} " | tee --append "$stdout_file"
  else
    echo -e "\r $message                ${GREEN}[OK]${RESET} " | tee --append "$stdout_file"
  fi
  return $ret
  export BASH_XTRACEFD='19'
  # on ré-export la variable BASH_XTRACEFD au cas ou que certains scripts bash exécuter à l'intérieur des fonctions l'ait supprimé ou modifier (exemple DKMS)
}
# la variable message récupère la valeur du premier argument passé à la fonction "le message", c'est à dire ce que l'on veut afficher à l'écran lors de l'execution du script (to stdout)
# shift permet de remplacer sur la même ligne l'affichage de "[En cours]" à "[ERROR]" ou "[OK]"
# le premier echo permet de reproduire tout ce qu'on voit dans le stdout dans le fichier $stdout_file
# les >>> dans le deuxième echo ne servent qu'à la présentation dans le fichier de log, cette ligne correspond à la ligne de la commande qui sera effectuée
# local ret=$? on défini la variable ret qui contiendra la valeur de retour de l'execution de la commande
# la ligne du bash -c correspond à l'envoi dans bash de l'exuction de la commande passé en paramètre dans la fonction displayandexec par le contenu de "$COMMAND" (récupéré ici à l'aide de $*). L'execution de la commande ainsi que son résultat, même en cas d'érreur sont envoyés dans le fichier de log et n'apparaissent pas sur le stdout

# regarder ce que fait l'option echo -e "\r $message"
# car lorsque j'ai executer le script sans cette option, il mettait deux fois sur la même ligne le contenu de $message et ensuite le [OK]
################################################################################

################################################################################
## fonction d'éxecution et de redirection dans le fichier de log execandlog
##------------------------------------------------------------------------------
# Premier parametre: message
# Autres parametres: command
# fonction pour faire les executions et envoyer les commandes ainsi que leurs résultats dans le fichier de log (pas d'affichage sur stdout)
execandlog() {
  echo ">>> $*" >> "$log_file" 2>&1
  bash -c "$*" >> "$log_file" 2>&1
  local ret=$?
  return $ret
  export BASH_XTRACEFD='19'
  # on ré-export la variable BASH_XTRACEFD au cas ou que certains scripts bash exécuter à l'intérieur des fonctions l'ait supprimé ou modifier (exemple DKMS)
}
################################################################################

################################################################################
## vérification de l'espace disponnible minimum sur /
##------------------------------------------------------------------------------
check_available_space_in_root() {
  local min_require_space="$1"
  local available_space="$(df --block-size=G / | awk '(NR>1){print $4}' | sed 's/.$//')"
  # peut aussi se faire en utilisant une seule redirection : "$(df --block-size=G / | awk '(NR>1){gsub(/.$/,"",$4); print $4}')"
  if [ "$available_space" -lt "$min_require_space" ]; then
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET}  Il faut au minimum "$min_require_space" Go d'espace libre pour executer le script.  ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    exit 1
  fi
}
if [ -z "$fisrt_time_script_executed" ]; then
  check_available_space_in_root "10"
else
  check_available_space_in_root "8"
fi
# On vérifie qu'il y a au minimum 10 Go de disponnible sur / (partition root) lorsque le script s'execute pour la première fois
################################################################################

################################################################################
## vérification de l'espace disponnible minimum sur /var
##------------------------------------------------------------------------------
check_available_space_in_var() {
  local min_require_space="$1"
  local available_space="$(df --block-size=G /var | awk '(NR>1){print $4}' | sed 's/.$//')"
  # peut aussi se faire en utilisant une seule redirection : "$(df --block-size=G /var | awk '(NR>1){gsub(/.$/,"",$4); print $4}')"
  if [ "$available_space" -lt "$min_require_space" ]; then
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET}  Il faut au minimum "$min_require_space" Go d'espace libre pour executer le script.   ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    exit 1
  fi
}
if [ -z "$fisrt_time_script_executed" ]; then
  check_available_space_in_var "5"
else
  check_available_space_in_var "2"
fi
# On vérifie qu'il y a au minimum 5 Go de disponnible sur /var lorsque le script s'execute pour la première fois
################################################################################

################################################################################
## utilisation du DNS de Cloudflare durant l'execution du script
##------------------------------------------------------------------------------
force_dns_for_install() {
  execandlog "cp /etc/resolv.conf /etc/resolv.conf.old"
  cat> /etc/resolv.conf << 'EOF'
# DNS Cloudflare
nameserver 1.1.1.1
# DNS Google
nameserver 8.8.8.8
EOF
}
force_dns_for_install
################################################################################

################################################################################
## vérification de l'accès à Internet
##------------------------------------------------------------------------------
check_internet_access() {
  displayandexec "Vérification de la connection internet (ICMP+DNS)   " "\
  ping -c 1 www.google.com" && \
  displayandexec "Vérification de la connection internet (HTTPS)      " "\
  wget --server-response --spider --quiet 'https://www.google.com' 2>&1 | grep -iq 'HTTP.*200 OK'"
  if [ $? != 0 ]; then
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET} Pour executer ce script, il faut disposer d'une connexion Internet ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    exit 1
  fi
}
check_internet_access
# ref : [bash - Script to get the HTTP status code of a list of urls? - Stack Overflow](https://stackoverflow.com/questions/6136022/script-to-get-the-http-status-code-of-a-list-of-urls/53358157#53358157)
################################################################################

################################################################################
## synchronisation de l'heure et de la time zone
##------------------------------------------------------------------------------
sync_date_and_time() {
  displayandexec "Synchronisation de l'heure et de la time zone       " "\
  systemctl restart systemd-timesyncd"
}
sync_date_and_time
# voir comment faire lorsque la machine n'est pas à la bonne date et qu'elle a créer le fichier de log en se basant sur la date à laquelle elle était. regarder concernant le bon moment pour executer la commande car elle a besoin de displayandexec qui utilise notamment le fait qu'un fichier de log soit créé
################################################################################

################################################################################
## vérification que le script s'execute sur une debian
##------------------------------------------------------------------------------
check_distrib_is_debian() {
  if $(grep '^NAME=' /etc/os-release | grep -i 'debian' &>/dev/null); then
    version_linux='Debian'
  else
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET}             Ce script s'execute seulement sur Debian !             ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}######################################################################${RESET}" | tee --append "$log_file"
    exit 1
  fi
}
check_distrib_is_debian
################################################################################

script_version='2.0'
system_version="$(cat /etc/debian_version)"
CURL='curl --silent --location --show-error'
# la variable $CURL ne doit pas être appelé avec des double quote

################################################################################
## vérification que le script s'execute depuis un terminal graphique (gnome-terminal)
##------------------------------------------------------------------------------
# on check si le script est lancé depuis un tty (comme SSH) ou bien depuis un terminal graphique (comme gnome-terminal)
# si le script est executé depuis un terminal graphique, on n'execute pas la fonction enable_GSE, car le relancement du Gnome Shell provoque l'arrêt du script et de tout ce qui tourne au moment de son execution
# on créer donc à la place un script dans /home à executer (en temps voulu) manuellement par l'utilisateur une fois que ng_install.sh aura terminé

# on check si les processus parents qui ont lancés le bash qui executera les commandes a été lancé à partir d'un processus parent qui correspond à "gnome-terminal"
# ref de la méthode : [macos - How to identify the terminal from a script? - Super User](https://superuser.com/questions/683962/how-to-identify-the-terminal-from-a-script/683973#683973)

# peut aussi se faire à l'aide de pstree avec cette commande : if ! $(pstree -sg $$ | grep 'gnome-terminal' &>/dev/null); then
# ref : [How to get parent PID of a given process in GNU/Linux from command line? - Super User](https://superuser.com/questions/150117/how-to-get-parent-pid-of-a-given-process-in-gnu-linux-from-command-line/1043124#1043124)
is_script_launch_with_gnome_terminal() {
  get_all_parent_PID() {
    ps --pid ${1:-$$} --no-headers --format pid,ppid,args | \
      (
        read pid ppid args
        echo "$args"
        [[ $pid -gt 1 ]] && get_all_parent_PID $ppid
      )
  }
  if get_all_parent_PID | grep 'gnome-terminal' &>/dev/null; then
    script_is_launch_with_gnome_terminal='1'
  fi
}
is_script_launch_with_gnome_terminal
################################################################################

################################################################################
## vérification que le SecureBoot est activé
##------------------------------------------------------------------------------
check_secureboot_enabled() {
  if command -v mokutil >/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q 'SecureBoot enabled'; then
      secureboot_enable=1
    fi
  fi
}
check_secureboot_enabled
################################################################################

################################################################################
## fonction qui permet de checker automatiquement les versions des logiciels qui s'installent manuellement, de façon automatique
##------------------------------------------------------------------------------
check_latest_version_manual_install_apps() {
  veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:alnum:]]+|[[:digit:]]+\.[[:digit:]]+-[[:alnum:]]+|[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+|[[:digit:]]+\.[[:digit:]]+)(?=-setup)')"
  # permet de récupérer la version lorsque la release est du type 'veracrypt-1.24-Update3-setup.tar.bz2' ainsi que 'veracrypt-1.24.3-Update3-setup.tar.bz2' ou 'veracrypt-1.24-setup.tar.bz2' ou 'veracrypt-1.24.4-setup.tar.bz2'
  if [ $? != 0 ] || [ -z "$veracrypt_version" ]; then
      veracrypt_version='1.26.7'
  fi
  # check version : https://www.veracrypt.fr/en/Downloads.html

  drawio_version="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$drawio_version" ]; then
    drawio_version='24.7.5'
  fi
  # check version : https://github.com/jgraph/drawio-desktop/releases

  boostnote_version="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$boostnote_version" ]; then
    boostnote_version='0.16.1'
  fi
  # check version : https://github.com/BoostIO/boost-releases/releases/

  etcher_version="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$etcher_version" ]; then
    etcher_version='1.18.4'
  fi
  # check version : https://github.com/balena-io/etcher/releases/

  shotcut_version="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$shotcut_version" ]; then
    shotcut_version='24.06.26'
  fi
  shotcut_appimage="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"name": "\K.*?(?=")' | grep 'AppImage')"
  if [ $? != 0 ] || [ -z "$shotcut_appimage" ]; then
    shotcut_appimage='shotcut-linux-x86_64-240626.AppImage'
  fi
  # check version : https://github.com/mltframework/shotcut/releases/

  keepassxc_version="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$keepassxc_version" ]; then
    keepassxc_version='2.7.9'
  fi
  # check version : https://github.com/keepassxreboot/keepassxc/releases/

  bat_version="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$bat_version" ]; then
    bat_version='0.24.0'
  fi
  # check version : https://github.com/sharkdp/bat/releases/

  joplin_version="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$joplin_version" ]; then
    joplin_version='3.0.14'
  fi
  # check version : https://github.com/laurent22/joplin/releases/

  krita_version="$($CURL 'https://krita.org/fr/download/'| tr -s '<' '\n' | grep 'stable' | grep -m1 -e '.appimage' | grep -Po '(?<=/stable/krita/)([[:digit:]]+\.+[[:digit:]]+\.[[:digit:]]+)')"
  if [ $? != 0 ] || [ -z "$krita_version" ]; then
    krita_version='5.2.3'
  fi
  # check version : https://krita.org/fr/download/

  opensnitch_stable_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$opensnitch_stable_version" ]; then
    opensnitch_stable_version='1.6.6'
  fi
  # check version : https://github.com/evilsocket/opensnitch/releases/

  opensnitch_latest_version="$(curl --silent 'https://api.github.com/repos/evilsocket/opensnitch/releases' | awk 'BEGIN{RS="}"} /"prerelease": true,/ {for (x=1;x<=NF;x++) if ($x~"tag_name") {gsub(/[v|"|,$]/,"");print $(x);exit;}}')"
  if [ $? != 0 ] || [ -z "$opensnitch_latest_version" ]; then
    opensnitch_latest_version='1.6.0-rc.5'
  fi
  # check version : https://github.com/evilsocket/opensnitch/releases/
  # je suis obligé de ne pas utilisé l'option --show-error car sinon j'obtiens une erreur : curl: (23) Failure writing output to destination
  # il semble qu'il faille ajouté 2>&1 à la fin de la commande curl pour pouvoir utiliser --show-error sans obtenir l'érreur mentionnée

  hashcat_version="$($CURL 'https://api.github.com/repos/hashcat/hashcat/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$hashcat_version" ]; then
    hashcat_version='6.2.6'
  fi
  # check version : https://github.com/hashcat/hashcat/releases/

  winscp_version="$($CURL 'https://winscp.net/eng/downloads.php' | grep -Po '(?<=WinSCP-)([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)(?=-Portable.zip")')"
  if [ $? != 0 ] || [ -z "$winscp_version" ]; then
    winscp_version='5.21.8'
  fi
  # check version : https://winscp.net/eng/downloads.php

  geeqie_version="$($CURL 'https://api.github.com/repos/BestImageViewer/geeqie/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$geeqie_version" ]; then
    geeqie_version='2.4'
  fi
  # check version : https://github.com/BestImageViewer/geeqie/releases

  ytdlp_version="$($CURL 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$ytdlp_version" ]; then
    ytdlp_version='2024.07.25'
  fi
  # check version : https://github.com/yt-dlp/yt-dlp/releases/

  ventoy_version="$($CURL 'https://api.github.com/repos/ventoy/Ventoy/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  if [ $? != 0 ] || [ -z "$ventoy_version" ]; then
    ventoy_version='1.0.99'
  fi
  # check version : https://github.com/ventoy/Ventoy/releases
}


# OU alors on récupère le lien directement du .deb avec la commande suivante
# $CURL https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | jq -r '.assets[2].browser_download_url'
# il faut changer la valeur dans assets[2] pour alterner entre les différents liens dispos (.deb, .rpm, .AppImage, ...)
################################################################################

################################################################################
## Pour obtenir un listing des logiciels avec les dernières versions disponnibles
##------------------------------------------------------------------------------
CURL='curl --silent --location --show-error'
manual_check_latest_version() {
  veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:alnum:]]+|[[:digit:]]+\.[[:digit:]]+-[[:alnum:]]+|[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+|[[:digit:]]+\.[[:digit:]]+)(?=-setup)')"
  echo 'VeraCrypt : '"$veracrypt_version"
  drawio_version="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'drawio : '"$drawio_version"
  boostnote_version="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Boosnote : '"$boostnote_version"
  etcher_version="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Etcher : '"$etcher_version"
  shotcut_version="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Shotcut : '"$shotcut_version"
  shotcut_appimage="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"name": "\K.*?(?=")' | grep 'AppImage')"
  echo 'Shotcut AppImage : '"$shotcut_appimage"
  keepassxc_version="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  echo 'KeePassXC : '"$keepassxc_version"
  bat_version="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'bat : '"$bat_version"
  joplin_version="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Joplin : '"$joplin_version"
  krita_version="$($CURL 'https://krita.org/fr/download/'| tr -s '<' '\n' | grep 'stable' | grep -m1 -e '.appimage' | grep -Po '(?<=/stable/krita/)([[:digit:]]+\.+[[:digit:]]+\.[[:digit:]]+)')"
  echo 'Krita : '"$krita_version"
  opensnitch_stable_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'OpenSnitch stable : '"$opensnitch_stable_version"
  opensnitch_latest_version="$(curl --silent 'https://api.github.com/repos/evilsocket/opensnitch/releases' | awk 'BEGIN{RS="}"} /"prerelease": true,/ {for (x=1;x<=NF;x++) if ($x~"tag_name") {gsub(/[v|"|,$]/,"");print $(x);exit;}}')"
  echo 'OpenSnitch latest (dev) : '"$opensnitch_latest_version"
  hashcat_version="$($CURL 'https://api.github.com/repos/hashcat/hashcat/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'hashcat : '"$hashcat_version"
  winscp_version="$($CURL 'https://winscp.net/eng/downloads.php' | grep -Po '(?<=WinSCP-)([[:digit:]]+\.+[[:digit:]]+\.[[:digit:]]+)(?=-Portable.zip")')"
  echo 'WinSCP : '"$winscp_version"
  geeqie_version="$($CURL 'https://api.github.com/repos/BestImageViewer/geeqie/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Geeqie : '"$geeqie_version"
  ytdlp_version="$($CURL 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  echo 'yt-dlp : '"$ytdlp_version"
  ventoy_version="$($CURL 'https://api.github.com/repos/ventoy/Ventoy/releases/latest' | grep -Po '"tag_name": "v\K.*?(?=")')"
  echo 'Ventoy : '"$ventoy_version"
}
# manual_check_latest_version
################################################################################

export local_user="$(awk -F':' '/:1000:/{print $1}' /etc/passwd)"
# Peut aussi se faire avec getent passwd 1000 | awk -F':' '{print $1}'
# l'inconvénient des autres méthodes ci-dessous c'est que leur execution suppose qu'on se soit loggé avec le user avant de lancer le script (ce n'est pas le cas s'il est executer directement en post-install du preseed par exemple)
# autre méthode pour obtenir le user, lorsqu'il est à l'origine de la session en cour : "$(who | awk 'FNR == 1 {print $1}')"
# ou encore id -nu "$(cat /proc/self/loginuid)"
# encore une autre méthode qui fonctionne aussi dans un sudo : who | awk -v vt=tty$(fgconsole 2>/dev/null) '$0 ~ vt {print $1}'

export local_user_UID="$(id -u "$local_user")"
gnome_shell_extension_path="/home/"$local_user"/.local/share/gnome-shell/extensions"
export ExeAsUser="sudo -u "$local_user""
AGI='apt-get -o DPkg::Options::=--force-confnew -o DPkg::Options::=--force-confmiss install -y'
AG='apt-get'
WGET='wget -q'
computer_proc_architecture="$(uname -r | grep -Po '(.*-)\K.*')"
# peut aussi se faire avec : "$(uname -r | /usr/bin/cut -d '-' -f 3)"

network_int_name="$(ip route list default | awk 'NR==1,/^default/{print $5}')"
# on remplace l'ancienne commande par celle qui prend le retour de ip route car celle ci permet d'éviter les cas ou il y a plusieurs interfaces qui commencent par en et de prendre en priorité celle qui est utilisé pour se connecter à la default gateway, en admettant donc que ce sois l'interface principale. Cela permet aussi de récupérer le nom de l'interface lorsque c'est une interface wifi
# à noter que "NR==1" dans la commande awk signifie qu'on ne choisie de ne prendre que la première ligne retournée par la commande ip
# peut être que ça peut être intéressant de rajouter un fallback : ip route get connected 1.1.1.1 | awk 'NR==1,/ dev /{print $5}'

# ancienne commande qui faisait le travail : $(ip addr | grep 'UP' | cut -d " " -f 2 | cut -d ":" -f 1 | grep 'en')
# peut potentillement se faire aussi avec ip addr | awk -F':' '/UP/ && / en/ {sub(/[[:blank:]]/,""); print $2}'
# une autre commande qui permet de se passer de la commande ip en utilisant uniquement les infos lspci et depuis /sys (ne fonctionne qu'avec une interface Ethernet connecté en PCI)
# pci=`lspci  | awk '/Ethernet/{print $1}'`; find /sys/class/net ! -type d | xargs --max-args=1 realpath | awk -v pciid=$pci -F\/ '{if($0 ~ pciid){print $NF}}'

ipv4_local_address="$(ip -o -4 addr list "$network_int_name" | awk '{print $4}' | cut -d/ -f1)"
ipv4_external_address="$(curl -4 --silent --location 'https://ipinfo.io/ip' 2>/dev/null)"
if [ -z "$ipv4_external_address" ]; then
  ipv4_external_address="$($WGET -4 --output-document - 'https://checkip.amazonaws.com')"
  if [ -z "$ipv4_external_address" ]; then
    ipv4_external_address="$(busybox nslookup -type=TXT o-o.myaddr.l.google.com ns1.google.com | sed -n 's/.*text = "\(.*\)"/\1/p')"
  fi
fi
ipv6_local_address="$(ip -o -6 addr list "$network_int_name" | awk '/fe80/{print $4}' | cut -d/ -f1)"
ipv6_external_address="$(ip -o -6 addr list "$network_int_name" | grep -v 'noprefixroute' | awk '{print $4}' | cut -d/ -f1)"
computer_ram="$(awk '/^MemTotal:/{printf("%.0f Go", $2/1024/1000 + 0.5)}' /proc/meminfo)"
# $2 est en kibioctets (KiB, 1024 octets),
# on divise d’abord par 1024 pour obtenir des mébioctets (MiB),
# puis par 1000 pour convertir en “mégaoctets commerciaux” (Mo),
# enfin on ajoute +0.5 avant le format %.0f pour forcer un arrondi à l’unité supérieure

computer_proc_nb="$(grep -c '^processor' /proc/cpuinfo)"
computer_proc_model_name="$(grep -Po -m 1 '(^model name\s*: )\K.*' /proc/cpuinfo)"
computer_proc_vendor_id="$(grep -Po -m 1 '(^vendor_id\s*: )\K.*' /proc/cpuinfo)"
debian_release="$(lsb_release -sc)"
if [ -z "$debian_release" ]; then
  debian_release="$(awk -F'=' '/^VERSION_CODENAME=/{print $2}' /etc/os-release)"
fi
DCONF_write="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write"
DCONF_read="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf read"
DCONF_list="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf list"
DCONF_dump="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf dump"
DCONF_load="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf load"
DCONF_reset="DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf reset"
# les variables DCONF_* ne doivent pas être appelés entre parenthèses

my_bin_path='/usr/local/bin'
my_local_bin_path='/home/"$local_user"/.local/bin'
# ref : [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_2.3/fhs-2.3.html#USRLOCALLOCALHIERARCHY)

# on active le mode case insensitive de bash
shopt -s nocasematch
if [[ "$debian_release" =~ bullseye ]]; then
  bullseye=1
fi
if [[ "$debian_release" =~ bookworm ]]; then
  bookworm=1
fi
if [[ "$debian_release" =~ trixie ]]; then
  trixie=1
fi
# on déscactive le mode case insensitive de bash
shopt -u nocasematch

# DISPLAY="$(ps e | grep -Po ' DISPLAY=[\.0-9A-Za-z:]* ' | sort -u | grep -Po '(DISPLAY=)\K.*')"

is_dir_present_or_mkdir_as_user() {
  local dir="$1"
  [ -d "$dir" ] || $ExeAsUser mkdir -p "$dir"
}
export -f is_dir_present_or_mkdir_as_user

reset_dir_as_user() {
  local dir="$1"
  is_dir_present_and_rmdir "$dir"
  is_dir_present_or_mkdir_as_user "$dir"
}
export -f reset_dir_as_user

is_file_present_and_rmfile_as_user() {
  local file="$1"
  [ -f "$file" ] || return 0
  [ -f "$file" ] && $ExeAsUser rm -f "$file"
}
export -f is_file_present_and_rmfile_as_user

add_to_user_crontab() {
  local crontab_line_to_add="$1"
  { crontab -l -u "$local_user" 2>/dev/null || true; echo "$crontab_line_to_add"; } | crontab -u "$local_user" -
}
export -f add_to_user_crontab
# inspiré de : [linux - How do I create a crontab through a script - Stack Overflow](https://stackoverflow.com/questions/4880290/how-do-i-create-a-crontab-through-a-script/51497394#51497394)

exec_graphic_app_with_root_privileges() {
  export DISPLAY=:0
  sudo -u "$local_user" xhost +SI:localuser:root
  sudo -u root timeout 10 "$1"
  sudo -u "$local_user" xhost -SI:localuser:root
}

exec_graphic_app_with_user_privileges() {
  export DISPLAY=:0
  sudo -u "$local_user" timeout 10 "$1"
}
# cette commande permet de lancer audacity depuis l'utilisateur root :
# DISPLAY=:0 setsid sudo -u "$local_user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" audacity &>/dev/null
# quit_graceffuly_graphic_apps_from_dbus () {
#   graphic_application="$1"
# DISPLAY=:0 sudo -u "$local_user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" sh -s << EOF
# gdbus call \
#   --session \
#   --dest org.gnome.Shell \
#   --object-path /org/gnome/Shell \
#   --method org.gnome.Shell.Eval "
# var mw =
#   global.get_window_actors()
#     .map(w=>w.meta_window)
#     .find(mw=>mw.get_title().includes('$graphic_application'));
#     mw.kill(0)" >/dev/null
# EOF
# }
# quit_graceffuly_graphic_apps_from_dbus "Audacity"
# Attention la valeur dans le includes() est sensible à la casse.
# A noter aussi que l'utilisation de org.gnome.Shell.Eval avec dbus ne sera plus possible à partir de Gnome 41

################################################################################
## désactivation de la mise en veille automatique pendant l'installation
##------------------------------------------------------------------------------
# désactivation de l'écran noir
$ExeAsUser $DCONF_write /org/gnome/desktop/session/idle-delay 'uint32 0'
# désactivation de la mise en veille automatique sur batterie
$ExeAsUser $DCONF_write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'nothing'"
# désactivation de la mise en veille automatique sur cable
$ExeAsUser $DCONF_write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"
################################################################################

################################################################################
## remise au propre du terminal
##------------------------------------------------------------------------------
clear
################################################################################

################################################################################
## vérification de la taille du terminal (largeur)
##------------------------------------------------------------------------------
check_available_columns_in_terminal() {
  available_columns_in_term="$(tput cols)"
  if [ "$available_columns_in_term" -lt 74 ]; then
    echo -e "${RED}###########################################${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET}  La taille du terminal est trop petite  ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}#${RESET}  L'affichage en sera donc impactée      ${RED}#${RESET}" | tee --append "$log_file"
    echo -e "${RED}###########################################${RESET}" | tee --append "$log_file"
  fi
}
check_available_columns_in_terminal
# peut aussi se faire avec echo $COLUMNS
# peut aussi se faire avec stty size | awk '{print $2}'
# ref : [How do I find the width & height of a terminal window? - Stack Overflow](https://stackoverflow.com/questions/263890/how-do-i-find-the-width-height-of-a-terminal-window)

# mes lignes ne dépassent pas 74 caractères dans le script, il faut donc que le tty fasse au moins cette taille
################################################################################

echo ''
echo ''
echo '     ################################################################'
echo '     #            LANCEMENT DU SCRIPT DEBIAN_POSTINSTALL            #'
echo '     ################################################################'
echo ''
echo ''
echo '     ================================================================'
echo ''
echo '              nom du script       : DEBIAN_POSTINSTALL'
echo '              auteur              : NRGLine4Sec'
echo '              version             : '"$script_version"
echo '              lancement du script : sudo bash '"$script_name"
echo '              version du système  : '"$version_linux" "$system_version" "($debian_release)"
echo '              architecture CPU    : '"$computer_proc_architecture"
echo '              nombre de coeur CPU : '"$computer_proc_nb"
echo '              mémoire RAM         : '"$computer_ram"
if [ "$secureboot_enable" == 1 ]; then
  echo '              SecureBoot          : Activé'
else
  echo '              SecureBoot          : Désactivé'
fi
echo '              adresse IPv4 local  : '"$ipv4_local_address"
echo '              adresse IPv4 extern : '"$ipv4_external_address"
if [ "$ipv6_local_address" ]; then
  echo '              adresse IPv6 local  : '"$ipv6_local_address"
fi
if [ "$ipv6_external_address" ]; then
  echo '              adresse IPv6 extern : '"$ipv6_external_address"
fi
echo ''
echo '     ================================================================'
echo ''

#//////////////////////////////////////////////////////////////////////////////#
#                                INSTALL APPS                                  #
#//////////////////////////////////////////////////////////////////////////////#

################################################################################
## application des mises à jour et modification du sources.list
##------------------------------------------------------------------------------
# suppression du CDROM dans sources.list
# displayandexec "Suppression du CDROM dans sources.list              " "sed -i '/cdrom/d' /etc/apt/sources.list"
# cette commande n'est plus nécessaire à partir du moment ou on remet au propre le contenu de /apt/souces.list

# à regarder pour désactiver la recherche de mise à jour qui provoque le lock de pdkg
# systemctl status unattended-upgrades
# systemctl stop unattended-upgrades

# remise au propre de /etc/apt/sources.list

make_apt_source_list_clean() {
  cat> /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ $debian_release main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ $debian_release main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security $debian_release-security main contrib non-free-firmware
deb-src https://security.debian.org/debian-security $debian_release-security main contrib non-free-firmware

# $debian_release-updates, to get updates before a point release is made
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb https://deb.debian.org/debian/ $debian_release-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ $debian_release-updates main contrib non-free non-free-firmware

# backports
# see https://backports.debian.org/
deb https://deb.debian.org/debian $debian_release-backports main contrib non-free non-free-firmware
EOF
}
make_apt_source_list_clean

################################################################################
## Configuration de apt
##------------------------------------------------------------------------------
configure_apt() {
  cat> /etc/apt/preferences.d/my_apt_preference << 'EOF'
# blacklist some unwanted MTA and email packages
Package: exim4-base exim4-config exim4-daemon-heavy exim4-daemon-light mailutils bsd-mailx ssmtp sendmail sendmail-base sendmail-bin sendmail-cf biabam mew mew-beta mew-beta-bin mew-bin sylpheed yample opensmtpd nullmailer msmtp esmtp dma courier-base courier-imap courier-ldap courier-mta courier-pcp courier-pop postfix
Pin: release *
Pin-Priority: -1

# blacklist some unwanted java based packages
Package: icedtea-netx libreoffice-java-common
Pin: release *
Pin-Priority: -1

# blacklist some packages to prevent conflict with manual install
Package: yt-dlp youtube-dl keepassxc python3-opensnitch-ui opensnitch ansible ansible-core bat
Pin: release *
Pin-Priority: -1

# blacklist gnome-initial-setup
Package: gnome-initial-setup
Pin: release *
Pin-Priority: -1

# blacklist most gnome-games
Package: five-or-more four-in-a-row gnome-klotski gnome-mahjongg gnome-mines gnome-nibbles gnome-robots gnome-sudoku gnome-taquin gnome-tetravex hitori iagno lightsoff quadrapassel swell-foop tali aisleriot
Pin: release *
Pin-Priority: -1

# blacklist unwanted package manager
Package: synaptic aptitude
Pin: release *
Pin-Priority: -1

# blacklist other unwanted packages
Package: malcontent malcontent-gui
Pin: release *
Pin-Priority: -1
EOF
}
configure_apt
# Cette configuration permet d'interdire l'installation de ces paquets (ligne Package:) par apt. Ca évite notamment d'avoir à gérer les problèmes de paquets qui pourraient être mis comme des dépendances d'autres paquets (comme pour youtube-dl et keepassxc) alors qu'on les install déjà d'une autre manière (par AppImage ou bien un binnaire plus récent).
# on évite qu'il y ait trop d'élements contenant des potentiels execution java en blacklistant notamment le paquet libreoffice-java-common et icedtea-netx qui peuvent poser des problèmes de sécurité
# PS: à garder pour chercher rapidement tous les paquets d'une catégorie en particulier :
# grep-aptavail -sPackage --field Tag "admin::package-management" | grep -Po '(^Package: )\K.*' | sort -u
################################################################################

################################################################################
## force kill and disable debian unattended-upgrades
##------------------------------------------------------------------------------
force_kill_and_disable_debian_unattended_upgrades() {
  displayandexec "Désactivation permanente de unattended-upgrades     " "\
  systemctl mask --now unattended-upgrades.service; \
  pgrep --full --exact '^/usr/bin/python3 /usr/share/unattended-upgrades/.*' | xargs --no-run-if-empty kill -kill"
}
force_kill_and_disable_debian_unattended_upgrades
# https://wiki.debian.org/UnattendedUpgrades
# https://debian-handbook.info/browse/fr-FR/stable/sect.regular-upgrades.html
# https://askubuntu.com/questions/1186492/terminate-unattended-upgrades-or-whatever-is-using-apt-in-ubuntu-18-04-or-later
# https://salsa.debian.org/installer-team/pkgsel/-/commit/2b9b594855a409fa6d03f259ccca4b1a1bd4727b
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=977158

# [it isn't ideal that we have two parallel mechanisms trying to upgrade packages, but this is the price we pay for Debian being a loosely-coupled system where GNOME is not the only supported desktop environment.)](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=977158#30)
# [gnome-software](https://debian-handbook.info/browse/fr-FR/stable/sect.regular-upgrades.html)
# peut être lié à ce paquer : gnome-package-updater
# [Design/OS/SoftwareUpdates - GNOME Wiki!](https://wiki.gnome.org/Design/OS/SoftwareUpdates)

# à noter qu'aver une install disposant du bureau Gnome, on a bien le service unattended-upgrades.service d'activé, mais par contre la conf dans debconf est "unattended-upgrades	unattended-upgrades/enable_auto_updates	boolean	false"
# c'est exactement la même conf que lorsque la valeure de pkgsel/update-policy est positionnée à "none" lors de l'install de Debian, ref : https://salsa.debian.org/installer-team/pkgsel/-/blob/master/pre-pkgsel.d/20update-policy?ref_type=heads#L29

# regarder également :
# gnome-software[4128]: enabled plugins: desktop-categories, fwupd, os-release, packagekit, packagekit-local, packagekit-offline, packagekit-proxy, packagekit-refine-repos, packagekit-refresh, packagekit-upgrade, packagekit-url-to-app, appstream, desktop-menu-path, hardcoded-blocklist, hardcoded-popular, modalias, odrs, packagekit-refine, rewrite-resource, packagekit-history, provenance, systemd-updates, generic-updates, provenance-license, icons, key-colors, key-colors-metadata

# apt rdepends --installed unattended-upgrades
# unattended-upgrades
# Reverse Depends:
#   Recommends: python3-software-properties

# apt rdepends --installed python3-software-properties
# python3-software-properties
# Reverse Depends:
#   Breaks: software-properties-common (<< 0.85)
#   Depends: software-properties-gtk (= 0.96.20.2-2.1)
#   Replaces: software-properties-common (<< 0.85)
#   Depends: software-properties-common (= 0.96.20.2-2.1)

# apt rdepends --installed software-properties-gtk
# software-properties-gtk
# Reverse Depends:
#   Depends: gnome-software

# apt-cache show python3-software-properties | grep 'Depends:\|Recommends:'
# Depends: iso-codes, lsb-release, python3, python3-apt (>= 0.8.8.2), python3-pycurl, python3:any
# Recommends: unattended-upgrades

# [Stop recommending unattended-upgrades (Closes: #447701) (c949db84) · Commits · PackageKit and AppStream / software-properties · GitLab](https://salsa.debian.org/pkgutopia-team/software-properties/-/commit/c949db84a3ff8057452f6167fcfc81d8b16be175)
# [#447701 - python-software-properties: dependency on unattended-upgrades has undesirable effects - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=447701)
# [Only show Updates tab if unattended-upgrades is installed (Closes: #703217) (4d05a516) · Commits · PackageKit and AppStream / software-properties · GitLab](https://salsa.debian.org/pkgutopia-team/software-properties/-/commit/4d05a5163313a062a0d3f5dd850c7f72e1b79bc5)
# [fix error in auto-upgrade settings when (a54e178c) · Commits · PackageKit and AppStream / software-properties · GitLab](https://salsa.debian.org/pkgutopia-team/software-properties/-/commit/a54e178c5581876055ed4ba10b00390b23d981a1)
# [[ Dustin Kirkland ] (bb29a9a5) · Commits · PackageKit and AppStream / software-properties · GitLab](https://salsa.debian.org/pkgutopia-team/software-properties/-/commit/bb29a9a5c500ea4a1cf37b7e4dde2bccb72b7c03)
# "python3-software-properties Recommends unattended-upgrades, which means it gets pulled in automatically on a default desktop install."
# ref : https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=447701#80

# Une autre option pour kill le PID de unattended-upgrades :
# kill -kill "$(systemctl show --property MainPID --value unattended-upgrades.service | grep -v '^0$')"

# encore une autre option pour récupérer le pid de unattended-upgrades :
# ps -eo pid,command --no-headers | grep '.*[/]usr/share/unattended-upgrades/.*' | awk '{print $1}'
################################################################################

################################################################################
## Supression de gnome-initial-setup
##------------------------------------------------------------------------------
remove_gnome_initial_setup() {
  displayandexec "Supression de gnome-initial-setup                   " "\
  pkill --echo --full --exact -KILL '^/usr/libexec/gnome-initial-setup.*'; \
  $AG purge -y gnome-initial-setup"
}
remove_gnome_initial_setup
# [linux - Prevent process from killing itself using pkill - Stack Overflow](https://stackoverflow.com/questions/15740481/prevent-process-from-killing-itself-using-pkill/15740573#15740573)
# Peut être que ce serait mieux de remplacer par pgrep avec une redirection dans kill comme décrit ici : [bash - pkill doesn't kill process - Stack Overflow](https://stackoverflow.com/questions/69560652/pkill-doesnt-kill-process/69562802#69562802)
################################################################################

echo ''
echo '     ################################################################'
echo '     #                      MISE A JOUR DU SYSTEM                   #'
echo '     ################################################################'
echo ''

update_ca_certificates() {
  displayandexec "Mise à jour des certificats racine                  " "\
  update-ca-certificates --verbose"
}
update_ca_certificates

# make debian non-interactive
export DEBIAN_FRONTEND=noninteractive DEBCONF_ADMIN_EMAIL="" UCF_FORCE_CONFFNEW=1 UCF_FORCE_CONFFMISS=1

upgrade_system_apt() {
  displayandexec "Mise à jour du system                               " "\
  $AG update && \
  $AG -o DPkg::Options::=--force-confnew -o DPkg::Options::=--force-confmiss upgrade -y"
  if [ $? != 0 ]; then
    displayandexec "Mise à jour du system                               " "\
    unset UCF_FORCE_CONFFNEW && \
    unset UCF_FORCE_CONFFMISS && \
    $AG update && \
    $AG -o DPkg::Options::=--force-confnew -o DPkg::Options::=--force-confmiss upgrade -y"
  fi
}
upgrade_system_apt

# on est parfois obliger de unset "UCF_FORCE_CONFFNEW" et "UCF_FORCE_CONFFMISS" à cause de ce cas :
# [#1002038 - noninteractive upgrade with UCF_FORCE_CONFFNEW=1 fail with ucf conflict - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1002038)
# [Bug#1024247: grub-efi-amd64: conf_force_conffnew=YES in /etc/ucf.conf breaks grub-efi-amd64.postinst](https://groups.google.com/g/linux.debian.bugs.dist/c/dSp-TmnykLE)
# [testboot/ucf at master · fliphess/testboot · GitHub](https://github.com/fliphess/testboot/blob/master/chroot/usr/bin/ucf#L488)
################################################################################

################################################################################
## Configuration des paquets avec debconf
##------------------------------------------------------------------------------
configure_debconf() {
  #wireshark
  echo 'wireshark-common	wireshark-common/install-setuid	boolean	false' | debconf-set-selections

  #macchanger
  echo 'macchanger	macchanger/automatically_run	boolean	false' | debconf-set-selections

  #apt-fast
  echo 'apt-fast	apt-fast/downloader	select	aria2c' | debconf-set-selections
  echo 'apt-fast	apt-fast/tmpdownloaddir	string	/var/cache/apt/apt-fast' | debconf-set-selections
  echo 'apt-fast	apt-fast/downloadcmd	string	aria2c --no-conf -c -j ${_MAXNUM} -x ${_MAXCONPERSRV} -s ${_SPLITCON} --min-split-size=${_MINSPLITSZ} --stream-piece-selector=${_PIECEALGO} -i ${DLLIST} --connect-timeout=600 --timeout=600 -m0 --header "Accept: */*"' | debconf-set-selections
  echo 'apt-fast	apt-fast/dlflag	boolean	true' | debconf-set-selections
  echo 'apt-fast	apt-fast/tmpdownloadlist	string	/tmp/apt-fast.list' | debconf-set-selections
  echo 'apt-fast	apt-fast/piecealgo	select	default' | debconf-set-selections
  echo 'apt-fast	apt-fast/aptmanager	select	apt-get' | debconf-set-selections
  echo 'apt-fast	apt-fast/maxconperfile	string	8' | debconf-set-selections
  echo 'apt-fast	apt-fast/minsplitsize	string	1M' | debconf-set-selections
  echo 'apt-fast	apt-fast/aptcache	string	/var/cache/apt/archives' | debconf-set-selections
  echo 'apt-fast	apt-fast/maxconpersrv	string	10' | debconf-set-selections
  echo 'apt-fast	apt-fast/maxdownloads	string	5' | debconf-set-selections
}
configure_debconf
# Solution : installer les paquets manuellement avec les bonnes config. Ensuite installer debconf-utils et faire
# debconf-get-selections | grep nom_du_paquet
# récupérer les infos obtenus et les injecter dans debconf-set-selections comme suit echo 'INFO' | debconf-set-selections
################################################################################

################################################################################
## Update PCI ID list
##------------------------------------------------------------------------------
update_pciids() {
  displayandexec "Mise à jour de la liste des ID PCI                  " "update-pciids"
}
update_pciids
# This utility requires curl, wget or lynx to be installed.
# le binnaire est situé ici : /usr/sbin/update-pciids
################################################################################

################################################################################
## installation des logiciels
##------------------------------------------------------------------------------
echo ''
echo '     ################################################################'
echo '     #                   INSTALLATION DES LOGICIELS                 #'
echo '     ################################################################'
echo ''

# si besoin de iwlwifi
# awk '{print $2}' /proc/bus/pci/devices | grep '^8086'
if awk '{print $2}' /proc/bus/pci/devices | grep '^8086' &>/dev/null; then
  for intel_device in $(grep -Po '^[[:xdigit:]]{4}[[:blank:]]+8086\K[[:xdigit:]]{4}' /proc/bus/pci/devices); do
    # on s'assure que le device intel est bien une carte wifi
    if grep "[[:blank:]]"$intel_device"[[:blank:]]" /usr/share/misc/pci.ids | grep -i -e 'wireless' -e 'Wi-Fi' -e 'WiFi' &>/dev/null; then
      displayandexec "Installation de firmware-iwlwifi                    " "$AGI firmware-iwlwifi"
    fi
  done
fi

# cat /proc/bus/pci/devices | column --table
# cat /proc/bus/pci/devices | column --table  | grep -E "^[[:xdigit:]]{4}[[:blank:]]+8086"
# lspci -nn | grep -i 'network' | grep -i 'intel'
# Pour récupérer l'id qui permet de déterminer quelle est la carte wifi utilisé : cat /proc/bus/pci/devices | column --table | grep -Po "^[[:xdigit:]]{4}[[:blank:]]+8086\K[[:xdigit:]]{4}"

# if grep '0x8086' /sys/devices/pci0000:00/*/*/ieee80211/phy0/device/vendor &>/dev/null; then
# 	displayandexec "Installation de firmware-iwlwifi                    " "$AGI firmware-iwlwifi"
# fi
# La commande précédente ne fonctionne pas car à priori il faut que iwlwifi soit déjà installé pour qu'on puiss avoir une entrée dans sysfs qui positionne le bus PCI de la carte wifi avec un sous répetoire

# Les commandes utiles qui m'ont aider à trouver la bonne commande pour détecter si la carte wifi est de chez Intel ou pas :
# find '/sys/devices/pci0000:00/' -type d -name 'ieee80211'
#
# grep '0x8086' /sys/devices/pci0000:00/*/*/ieee80211/phy0/device/vendor
#
# awk '!/^[[:blank:]]/ && /^8086/' /usr/share/misc/pci.ids
#
# # Pour obtenir tous les ID en fonction du fabricant
# grep -E "^[[:xdigit:]]{4}[[:blank:]]" /usr/share/misc/pci.ids

# script intéressant pour ce type d'élément : [Gujin: gujin.sh | Fossies](https://fossies.org/linux/gujin/gujin.sh)

# ancienne commande utilisée (avec lspci) :
# lspci -nn | grep 'Network' | grep 'Intel' &>/dev/null
# if [ $? == 0 ]; then
#    displayandexec "Installation de firmware-iwlwifi                    " "$AGI firmware-iwlwifi"
# fi

# si CPU/GPU is AMD
# awk '!/^[[:blank:]]/ && /^1002/' /usr/share/misc/pci.ids
# l'ID 1002 correspond à Advanced Micro Devices, Inc. [AMD/ATI]
if awk '{print $2}' /proc/bus/pci/devices | grep '^1002' &>/dev/null; then
  for amd_device in $(grep -Po '^[[:xdigit:]]{4}[[:blank:]]+1002\K[[:xdigit:]]{4}' /proc/bus/pci/devices); do
    # on s'assure que le device AMD est bien une carte graphique
    if grep "[[:blank:]]"$amd_device"[[:blank:]]" /usr/share/misc/pci.ids | grep -iw 'Radeon' &>/dev/null; then
      displayandexec "Installation de firmware-amd-graphics               " "$AGI firmware-amd-graphics"
      displayandexec "Installation de xserver-xorg-video-amdgpu           " "$AGI xserver-xorg-video-amdgpu"
      displayandexec "Installation de radeontop                           " "$AGI radeontop"
      displayandexec "Installation de rocminfo                            " "$AGI rocminfo"
    fi
  done
fi
# apt policy firmware-amd-graphics xserver-xorg-video-amdgpu radeontop rocminfo

# si CPU/GPU is Intel
# awk '!/^[[:blank:]]/ && /^8086/' /usr/share/misc/pci.ids
# l'ID 8086 correspond à Intel Corporation
if awk '{print $2}' /proc/bus/pci/devices | grep '^8086' &>/dev/null; then
  for intel_device in $(grep -Po '^[[:xdigit:]]{4}[[:blank:]]+8086\K[[:xdigit:]]{4}' /proc/bus/pci/devices); do
    # on s'assure que le device Intel est bien une carte graphique
    if grep "[[:blank:]]"$intel_device"[[:blank:]]" /usr/share/misc/pci.ids | grep -iw 'Graphics' &>/dev/null; then
      displayandexec "Installation de intel-gpu-tools                     " "$AGI intel-gpu-tools"
    fi
  done
fi

# si carte Ethernet Realtek
# awk '!/^[[:blank:]]/ && /^10ec/' /usr/share/misc/pci.ids
# l'ID 10ec correspond à Realtek Semiconductor Co., Ltd.
if awk '{print $2}' /proc/bus/pci/devices | grep '^10ec' &>/dev/null; then
  for realtek_device in $(grep -Po '^[[:xdigit:]]{4}[[:blank:]]+10ec\K[[:xdigit:]]{4}' /proc/bus/pci/devices); do
    # on s'assure que le device Realtek est bien une carte Ethernet
    if grep "[[:blank:]]"$realtek_device"[[:blank:]]" /usr/share/misc/pci.ids | grep -iw 'Ethernet' &>/dev/null; then
      displayandexec "Installation de firmware-realtek                    " "$AGI firmware-realtek"
    fi
  done
fi

# on active le mode case insensitive de bash
shopt -s nocasematch
if [[ "$computer_proc_vendor_id" =~ amd ]]; then
  displayandexec "Installation de amd64-microcode                     " "$AGI amd64-microcode"
fi
if [[ "$computer_proc_vendor_id" =~ intel ]]; then
  displayandexec "Installation de intel-microcode                     " "$AGI intel-microcode"
fi
# on déscactive le mode case insensitive de bash
shopt -u nocasematch

install_debian_apt_package() {
  displayandexec "Installation de ascii                               " "$AGI ascii"
  displayandexec "Installation de aria2                               " "$AGI aria2"
  displayandexec "Installation de arping                              " "$AGI arping"
  displayandexec "Installation de auditd                              " "$AGI auditd"
  displayandexec "Installation de audacity                            " "$AGI audacity"
  displayandexec "Installation de apparmor-profiles                   " "$AGI apparmor-profiles"
  displayandexec "Installation de apparmor-profiles-extra             " "$AGI apparmor-profiles-extra"
  displayandexec "Installation de b3sum                               " "$AGI b3sum"
  displayandexec "Installation de bat                                 " "$AGI bat"
  displayandexec "Installation de bind9-dnsutils                      " "$AGI bind9-dnsutils"
  displayandexec "Installation de binwalk                             " "$AGI binwalk"
  displayandexec "Installation de bpfcc-tools                         " "$AGI bpfcc-tools"
  displayandexec "Installation de bpftool                             " "$AGI bpftool"
  displayandexec "Installation de bpftrace                            " "$AGI bpftrace"
  displayandexec "Installation de bwm-ng                              " "$AGI bwm-ng"
  displayandexec "Installation de cadaver                             " "$AGI cadaver"
  displayandexec "Installation de calibre                             " "$AGI calibre"
  displayandexec "Installation de dctrl-tools                         " "$AGI dctrl-tools"
  displayandexec "Installation de chkrootkit                          " "$AGI chkrootkit"
  displayandexec "Installation de chromium                            " "$AGI chromium-l10n"
  displayandexec "Installation de clamav                              " "$AGI clamav clamtk clamtk-gnome libclamunrar"
  displayandexec "Installation de colordiff                           " "$AGI colordiff"
  displayandexec "Installation de cups                                " "$AGI cups"
  displayandexec "Installation de curl                                " "$AGI curl"
  displayandexec "Installation de debconf-utils                       " "$AGI debconf-utils"
  displayandexec "Installation de dmidecode                           " "$AGI dmidecode"
  displayandexec "Installation de dmitry                              " "$AGI dmitry"
  displayandexec "Installation de dos2unix                            " "$AGI dos2unix"
  displayandexec "Installation de elfutils                            " "$AGI elfutils"
  displayandexec "Installation de ethtool                             " "$AGI ethtool"
  displayandexec "Installation de ettercap-graphical                  " "$AGI ettercap-graphical" # à vérifier, mais peut-être que ce paquet pourra être supprimer
  displayandexec "Installation de evince                              " "$AGI evince"
  displayandexec "Installation de exiv2                               " "$AGI exiv2"
  displayandexec "Installation de libimage-exiftool-perl              " "$AGI libimage-exiftool-perl" # needed to get exiftool binnary
  displayandexec "Installation de ffmpeg                              " "$AGI ffmpeg"
  displayandexec "Installation de firefox-esr-l10n-fr                 " "$AGI firefox-esr-l10n-fr"
  displayandexec "Installation de firejail                            " "$AGI firejail firejail-profiles"
  displayandexec "Installation de flameshot                           " "$AGI flameshot"
  displayandexec "Installation de freerdp3-sdl                        " "$AGI freerdp3-sdl"
  displayandexec "Installation de freerdp3-wayland                    " "$AGI freerdp3-wayland"
  displayandexec "Installation de gcc                                 " "$AGI gcc"
  displayandexec "Installation de genisoimage                         " "$AGI genisoimage" # needed to get isoinfo binnary
  displayandexec "Installation de gimp                                " "$AGI gimp"
  displayandexec "Installation de git                                 " "$AGI git"
  displayandexec "Installation de gitk                                " "$AGI gitk"
  displayandexec "Installation de gocrypt                             " "$AGI gocryptfs"
  displayandexec "Installation de gparted                             " "$AGI gparted"
  displayandexec "Installation de gsmartcontrol                       " "$AGI gsmartcontrol"
  # displayandexec "Installation de handbrake                           " "$AGI handbrake"
  displayandexec "Installation de hardinfo                            " "$AGI hardinfo"
  displayandexec "Installation de hdparm                              " "$AGI hdparm"
  displayandexec "Installation de htop                                " "$AGI htop"
  displayandexec "Installation de hugo                                " "$AGI hugo"
  displayandexec "Installation de hydra-gtk                           " "$AGI hydra-gtk"
  displayandexec "Installation de hwinfo                              " "$AGI hwinfo"
  displayandexec "Installation de icdiff                              " "$AGI icdiff"
  displayandexec "Installation de iftop                               " "$AGI iftop"
  displayandexec "Installation de inxi                                " "$AGI inxi"
  displayandexec "Installation de iotop                               " "$AGI iotop"
  displayandexec "Installation de ipcalc                              " "$AGI ipcalc"
  displayandexec "Installation de jq                                  " "$AGI jq"
  displayandexec "Installation de libnotify-bin                       " "$AGI libnotify-bin"
  displayandexec "Installation de libsecret-tools                     " "$AGI libsecret-tools"
  displayandexec "Installation de linux-cpupower                      " "$AGI linux-cpupower"
  displayandexec "Installation de linux-perf                          " "$AGI linux-perf"
  displayandexec "Installation de lnav                                " "$AGI lnav"
  displayandexec "Installation de locate                              " "$AGI locate"
  displayandexec "Installation de lshw                                " "$AGI lshw"
  displayandexec "Installation de lynx                                " "$AGI lynx"
  displayandexec "Installation de lz4                                 " "$AGI lz4"
  displayandexec "Installation de macchanger                          " "$AGI macchanger"
  displayandexec "Installation de make                                " "$AGI make"
  displayandexec "Installation de mat2                                " "$AGI mat2"
  displayandexec "Installation de mediainfo                           " "$AGI mediainfo mediainfo-gui"
  displayandexec "Installation de mpv                                 " "$AGI mpv youtube-dl- yt-dlp-"
  # on n'install pas la dépendance youtube-dl requise par mpv car la version des dépots debian est trop ancienne
  # ref : [ubuntu - How do I get apt-get to ignore some dependencies? - Server Fault](https://serverfault.com/questions/250224/how-do-i-get-apt-get-to-ignore-some-dependencies/663803#663803)
  displayandexec "Installation de msitools                            " "$AGI msitools" # à noter qu'on peut aussi utiliser "7z x" pour extraire le contenu de fichier .msi mais msiextract a l'avantage de garder la structure des répertoires ainsi que les noms et majuscules des fichiers à l'intérieur
  if [ "$bullseye" == 1 ]; then
    displayandexec "Installation de nautilus-gtkhash                    " "$AGI nautilus-gtkhash"
  fi
  # nautilus-gtkhash a été enlevé de la release bookworm bien qu'il n'y a aucune infos à ce sujet dans le tracker du paquet ou dans le bugtrack
  # ref : [Debian -- Package Search Results -- nautilus-gtkhash](https://packages.debian.org/search?keywords=nautilus-gtkhash)
  # [Draft: Upgrade to Debian 12 (Bookworm) (!1119) · Merge requests · tails / tails · GitLab](https://gitlab.tails.boum.org/tails/tails/-/merge_requests/1119/diffs?commit_id=8d6c7499b0199f31d92566eb868d5b3fa44d2404)
  # [#1016988 - transition: nautilus 43 - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1016988)
  if [ "$bullseye" == 1 ]; then
    displayandexec "Installation de nautilus-wipe                       " "$AGI nautilus-wipe"
  fi
  # nautilus-wipe a été supprimé de bookworm car Nautilus utilise GTK4 dans bookworm
  # ref : [#1017619 - nautilus-wipe: Fails to build with nautilus 43 - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1017619)
  # il semble que la dépendance qui posait problème a été retirée et que nautilus-wipe pourrait certainement être intégré dans la release de Debian après Bookworm : [#1069334 - Not installable due to hardcoded pre-t64 library deps - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1069334)
  # [#1017619 - nautilus-wipe: Fails to build with nautilus 43 - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1017619)
  displayandexec "Installation de nbd-client                          " "$AGI nbd-client"
  displayandexec "Installation de ncdu                                " "$AGI ncdu"
  displayandexec "Installation de netdiscover                         " "$AGI netdiscover"
  displayandexec "Installation de network-manager-openvpn-gnome       " "$AGI network-manager-openvpn-gnome"
  displayandexec "Installation de network-manager-vpnc-gnome          " "$AGI network-manager-vpnc-gnome"
  # displayandexec "Installation de nextcloud-desktop                   " "$AGI nextcloud-desktop"
  displayandexec "Installation de nfs-common                          " "$AGI nfs-common"
  displayandexec "Installation de ngrep                               " "$AGI ngrep"
  displayandexec "Installation de nikto                               " "$AGI nikto"
  displayandexec "Installation de nnn                                 " "$AGI nnn"
  displayandexec "Installation de nmap                                " "$AGI nmap"
  displayandexec "Installation de nvme-cli                            " "$AGI nvme-cli"
  displayandexec "Installation de oathtool                            " "$AGI oathtool"
  displayandexec "Installation de ocrfeeder                           " "$AGI python3-standard-imghdr ocrfeeder"
  # python3-standard-imghdr seems to be an unspecified dependance to ocrfeeder because I get this error of the package is not present
#   Traceback (most recent call last):
#   File "/usr/bin/ocrfeeder", line 31, in <module>
#     from ocrfeeder.studio.studioBuilder import Studio
#   File "/usr/lib/python3/dist-packages/ocrfeeder/studio/studioBuilder.py", line 29, in <module>
#     from . import widgetPresenter
#   File "/usr/lib/python3/dist-packages/ocrfeeder/studio/widgetPresenter.py", line 21, in <module>
#     from .dataHolder import DataBox, TEXT_TYPE, IMAGE_TYPE
#   File "/usr/lib/python3/dist-packages/ocrfeeder/studio/dataHolder.py", line 20, in <module>
#     from ocrfeeder.util import graphics
#   File "/usr/lib/python3/dist-packages/ocrfeeder/util/graphics.py", line 25, in <module>
#     import imghdr
# ModuleNotFoundError: No module named 'imghdr'
  displayandexec "Installation de openvpn                             " "$AGI openvpn"
  displayandexec "Installation de p7zip-full                          " "$AGI p7zip-full"
  displayandexec "Installation de p7zip-rar                           " "$AGI p7zip-rar"
  displayandexec "Installation de pdfgrep                             " "$AGI pdfgrep"
  displayandexec "Installation de pipx                                " "$AGI pipx"
  displayandexec "Installation de pavucontrol                         " "$AGI pavucontrol"
  displayandexec "Installation de printer-driver-all                  " "$AGI printer-driver-all"
  displayandexec "Installation de pv                                  " "$AGI pv"
  displayandexec "Installation de python3-pip                         " "$AGI python3-pip"
  displayandexec "Installation de python3-scapy                       " "$AGI python3-scapy"
  displayandexec "Installation de qpdf                                " "$AGI qpdf"
  displayandexec "Installation de rclone                              " "$AGI rclone"
  displayandexec "Installation de rdesktop                            " "$AGI rdesktop"
  # displayandexec "Installation de remmina                             " "$AGI remmina"
  # displayandexec "Installation de rkhunter                            " "$AGI rkhunter" # because [#1057470 - Outdated rkhunter since 2018-02 - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1057470#10)
  displayandexec "Installation de rsync                               " "$AGI rsync"
  displayandexec "Installation de sdparm                              " "$AGI sdparm"
  displayandexec "Installation de secure-delete                       " "$AGI secure-delete"
  displayandexec "Installation de sg3-utils                           " "$AGI sg3-utils"
  displayandexec "Installation de shotwell                            " "$AGI shotwell"
  displayandexec "Installation de snmp                                " "$AGI snmp"
  displayandexec "Installation de smem                                " "$AGI smem"
  displayandexec "Installation de sqlite3                             " "$AGI sqlite3"
  displayandexec "Installation de sqlitebrowser                       " "$AGI sqlitebrowser"
  displayandexec "Installation de ssh                                 " "$AGI ssh"
  displayandexec "Installation de sshfs                               " "$AGI sshfs"
  displayandexec "Installation de sshpass                             " "$AGI sshpass"
  displayandexec "Installation de strace                              " "$AGI strace"
  displayandexec "Installation de sudo                                " "$AGI sudo"
  displayandexec "Installation de sysstat                             " "$AGI sysstat"
  displayandexec "Installation de tcpdump                             " "$AGI tcpdump"
  displayandexec "Installation de telnet                              " "$AGI telnet"
  displayandexec "Installation de tesseract-ocr                       " "$AGI tesseract-ocr tesseract-ocr-fra"
  displayandexec "Installation de testdisk                            " "$AGI testdisk"
  displayandexec "Installation de testssl.sh                          " "$AGI testssl.sh"
  displayandexec "Installation de tmux                                " "$AGI tmux"
  displayandexec "Installation de tree                                " "$AGI tree"
  displayandexec "Installation de tigervnc-viewer                     " "$AGI tigervnc-viewer"
  displayandexec "Installation de tshark                              " "$AGI tshark"
  displayandexec "Installation de ufw                                 " "$AGI ufw"
  displayandexec "Installation de unoconv                             " "$AGI unoconv"
  displayandexec "Installation de unrar                               " "$AGI unrar"
  displayandexec "Installation de vlc                                 " "$AGI vlc"
  displayandexec "Installation de vpnc                                " "$AGI vpnc"
  displayandexec "Installation de wget                                " "$AGI wget"
  displayandexec "Installation de wine                                " "$AGI wine"
  # displayandexec "Installation de wine32                              " "dpkg --add-architecture i386 && $AG update ; $AGI wine32"
  displayandexec "Installation de wipe                                " "$AGI wipe"
  displayandexec "Installation de wireshark                           " "$AGI wireshark"
  displayandexec "Installation de xclip                               " "$AGI xclip"
  displayandexec "Installation de xfsprogs                            " "$AGI xfsprogs" # nécessaire pour manipuler des filesystems XFS
  displayandexec "Installation de xinput                              " "$AGI xinput"
  displayandexec "Installation de xorriso                             " "$AGI xorriso"
  displayandexec "Installation de xxd                                 " "$AGI xxd"
  displayandexec "Installation de xxhash                              " "$AGI xxhash"
  displayandexec "Installation de xz-utils                            " "$AGI xz-utils"
  displayandexec "Installation de yersinia                            " "$AGI yersinia" # à réflechir si c'est encore utile
  displayandexec "Installation de yq                                  " "$AGI yq"
  # displayandexec "Installation de zenmap                              " "$AGI zenmap"
  # zenmap n'est pas dispo dans debian bullseye car python2 est EOL, pour traquer l'avencement du portage du code vers python3 : https://github.com/nmap/nmap/issues/1176
  displayandexec "Installation de zbar-tools                          " "$AGI zbar-tools" # utile pour lire les QRcode en CLI
  displayandexec "Installation de zip                                 " "$AGI zip"
  displayandexec "Installation de zutils                              " "$AGI zutils"
  displayandexec "Installation de zsh                                 " "$AGI zsh zsh-syntax-highlighting"
  displayandexec "Installation de zstd                                " "$AGI zstd"
  displayandexec "Installation de wireguard                           " "$AGI wireguard"
  displayandexec "Installation de whois                               " "$AGI whois"
}
install_debian_apt_package

check_if_package_is_present_in_backports_repo() {
  local package="$1"
  apt-cache policy "$package" | sed -n '/Version table:/{n;n;p;}' | grep -eq '-backports' &>/dev/null
}
# on a pas le choix de le faire comme ça car apt-cache ne supporte pas l'option --target-release
# [#115520 - --target-release (-t) for apt-cache [show?] - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=115520)
# Potentiel alternative : apt list --quiet=2 '?name(^'"$package"'$)?narrow(~Abackports)' 2>/dev/null | grep -e 'stable-backports' &>/dev/null

install_from_backports() {
  local package="$1"
  displayandexec "Installation de "$package"                            " "$AG -t "$debian_release"-backports install -y "$package""
}
# a savoir que juste après la release de la latest stable de debian, les paquets ne sont probablement pas disponnibles dans les backports et qu'il faut donc les garder aussi dans l'installation des paquets depuis le "main" standard pour pouvoir être compatible avec une install from scratch apès une nouvelle release de debian.
# On permet toutefois l'install de la dernière version disponnible dans backport si elle existe (vérification avec la commande apt-cache policy firejail | sed -n '/Version table:/{n;n;p;}' | grep -eq '-backports')

package_to_install_from_backports_if_available='
firejail
firejail-profiles
freerdp3-sdl
curl
gocryptfs
'
#remmina # useless after switching installation to flatpak

check_and_install_package_from_backports() {
  for package in $package_to_install_from_backports_if_available; do
    check_if_package_is_present_in_backports_repo "$package" && \
    install_from_backports "$package"
  done
}
check_and_install_package_from_backports

install_zfs() {
  # il peut arriver que l'install ne fonctionne pas (notamment juste après l'install de debian) car il manque le paquet linux-headers-"$(uname -r)", il faut donc s'assurer qu'il soit présent avant l'install des paquets ZFS
  execandlog "$AGI linux-headers-"$(uname -r)""
  if apt-cache policy zfsutils-linux zfs-dkms zfs-zed | sed -n '/Version table:/{n;n;p;}' | grep -e '-backports' &>/dev/null; then
    displayandexec "Installation de ZFS                                 " "\
    echo 'zfs-dkms	zfs-dkms/stop-build-for-32bit-kernel	boolean	true' | debconf-set-selections && \
    echo 'zfs-dkms	zfs-dkms/note-incompatible-licenses	note' | debconf-set-selections && \
    echo 'zfs-dkms	zfs-dkms/stop-build-for-unknown-kernel	boolean	true'| debconf-set-selections && \
    set +x && \
    $AG -t "$debian_release"-backports install -y zfsutils-linux zfs-dkms zfs-zed && \
    modprobe zfs"
  else
    displayandexec "Installation de ZFS                                 " "\
    echo 'zfs-dkms	zfs-dkms/stop-build-for-32bit-kernel	boolean	true' | debconf-set-selections && \
    echo 'zfs-dkms	zfs-dkms/note-incompatible-licenses	note' | debconf-set-selections && \
    echo 'zfs-dkms	zfs-dkms/stop-build-for-unknown-kernel	boolean	true'| debconf-set-selections && \
    set +x && \
    $AGI zfsutils-linux zfs-dkms zfs-zed && \
    modprobe zfs"
  fi
  configure_SecureBoot_params() {
    # création du script qui permet de signer les modules DKMS
    cat> /opt/sign_dkms_kernel_module.sh << 'EOF'
#!/bin/bash

# Test que le script est lancer en root
if [ $EUID != 0 ]; then
  echo "Le script doit être executer en root: # sudo $0" 1>&2
  exit 1
fi

ls -al /var/lib/dkms
mokutil --import /var/lib/dkms/mok.pub
mokutil --list-new

reboot
EOF
    chmod +x /opt/sign_dkms_kernel_module.sh
  }
  # ref : [Debian, SecureBoot et les modules noyaux DKMS - Where is it?](https://medspx.fr/blog/Debian/secure_boot_dkms/)

  if [ "$secureboot_enable" == 1 ]; then
    configure_SecureBoot_params
  fi
}
install_zfs

install_hardware_acceleration() {
  displayandexec "Installation des packages HardwareVideoAcceleration " "$AGI vainfo vdpauinfo"
}
# [HardwareVideoAcceleration - Debian Wiki](https://wiki.debian.org/HardwareVideoAcceleration)
install_hardware_acceleration
################################################################################


displayandexec "Installation des dépendances manquantes             " "$AG -o DPkg::Options::=--force-confnew -o DPkg::Options::=--force-confmiss install -y"

remove_no_longer_required_package() {
  displayandexec "Désinstalation des paquets qui ne sont plus utilisés" "$AG autoremove -y"
}
remove_no_longer_required_package

#//////////////////////////////////////////////////////////////////////////////#
#                       INSTALL MANUAL INSTALL APPS                            #
#//////////////////////////////////////////////////////////////////////////////#

echo ''
echo '     ################################################################'
echo '     #  INSTALLATION DES LOGICIELS AVEC UNE INSTALLATION MANUELLE   #'
echo '     ################################################################'
echo ''

# création du répertoire qui contiendra les logiciels avec une installation spéciale
manual_install_dir='/opt/manual_install'
execandlog "is_dir_present_or_mkdir "$manual_install_dir""

################################################################################
## instalation de WinSCP
##------------------------------------------------------------------------------
install_winscp() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de WinSCP                              " "\
reset_dir ""$manual_install_dir"/winscp/" && \
$WGET -P "$tmp_dir" https://winscp.net/download/WinSCP-"$winscp_version"-Portable.zip && \
unzip "$tmp_dir"/WinSCP-"$winscp_version"-Portable.zip -d "$manual_install_dir"/winscp/ && \
echo "wine "$manual_install_dir"/winscp/WinSCP.exe" > "$my_bin_path"/winscp && \
chmod +x "$my_bin_path"/winscp; \
rm -rf "$tmp_dir""
}
# il semblerait que WinSCP a besoin spécifiquement de wine32 et ne fonctionne pas avec wine64
# il faudrait tester à nouveau sur une machine au propre (sans wine32) et revérifier cela car j'ai pu lancer WinSCP sans problème avec wine64 /opt/manual_install/winscp/WinSCP.exe
# avec WinSCP en version
################################################################################

################################################################################
## instalation de Veracrypt
##------------------------------------------------------------------------------
install_veracrypt() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de veracrypt                           " "\
  $WGET -P "$tmp_dir" https://launchpad.net/veracrypt/trunk/"$(tr '[:upper:]' '[:lower:]' <<< "$veracrypt_version")"/+download/veracrypt-"$veracrypt_version"-setup.tar.bz2 && \
  tar xjf "$tmp_dir"/veracrypt-"$veracrypt_version"-setup.tar.bz2 --directory="$tmp_dir" && \
  "$tmp_dir"/veracrypt-"$veracrypt_version"-setup-gui-x64 --nox11 --noexec --target "$tmp_dir" && \
  tail -n +\$(sed -n 's/.*PACKAGE_START=\([0-9]*\).*/\1/p' "$tmp_dir"/veracrypt_install_gui_x64.sh) "$tmp_dir"/veracrypt_install_gui_x64.sh > "$tmp_dir"/veracrypt_installer.tar && \
  tar -C / --no-overwrite-dir -xpzvf "$tmp_dir"/veracrypt_installer.tar; \
  rm -rf "$tmp_dir""
}
# on backslash le retour de la command sed car elle est executer dans un bash -c
# https://stackoverflow.com/questions/1711970/i-cant-seem-to-use-the-bash-c-option-with-arguments-after-the-c-option-st

# ancienne version de l'URL (fonctione très bien quand la version est sous la forme 1.24)
# $WGET -P "$tmp_dir" https://launchpad.net/veracrypt/trunk/"$veracrypt_version"/+download/veracrypt-"$veracrypt_version"-setup.tar.bz2 && \
# "$(tr '[:upper:]' '[:lower:]' <<< "$veracrypt_version")" permet de corriger l'URL lorsque la version est sous la forme 1.24-Update7 car l'URL de téléchargement est comme ceci (u en lower) :
# https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-setup.tar.bz2
################################################################################

################################################################################
## instalation de Spotify
##------------------------------------------------------------------------------
install_spotify() {
  cat> /etc/apt/sources.list.d/spotify.list << 'EOF'
deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free
EOF
  spotify_repo_gpg_pubkey="$($CURL 'https://www.spotify.com/download/linux/' | tr -s '<' '\n' | grep -Po '(/pubkey_)\K[[:xdigit:]]+(?=.gpg)+')"
  displayandexec "Installation de spotify                             " "\
  is_file_present_and_rmfile "/usr/share/keyrings/spotify-archive-keyring.gpg" && \
  $CURL 'https://download.spotify.com/debian/pubkey_'"$spotify_repo_gpg_pubkey"'.gpg' | gpg --dearmor --output /usr/share/keyrings/spotify-archive-keyring.gpg && \
  $AG update && \
  $AGI spotify-client"
}
# pour obtenir la clé publique lorsqu'elle expire : https://www.spotify.com/fr/download/linux/

# Pour changer la clé après coup :
# spotify_repo_gpg_pubkey="$(curl -sL 'https://www.spotify.com/download/linux/' | tr -s '<' '\n' | grep -Po '(/pubkey_)\K[[:xdigit:]]+(?=.gpg)+')" && \
# sudo rm -f "/usr/share/keyrings/spotify-archive-keyring.gpg" && \
# curl -sL 'https://download.spotify.com/debian/pubkey_'"$spotify_repo_gpg_pubkey"'.gpg' | sudo gpg --dearmor --output /usr/share/keyrings/spotify-archive-keyring.gpg && \
# apt-get update
################################################################################

################################################################################
## instalation de apt-fast
##------------------------------------------------------------------------------
install_apt-fast() {
  cat> /etc/apt/sources.list.d/apt-fast.sources << 'EOF'
Types: deb
URIs: http://ppa.launchpad.net/apt-fast/stable/ubuntu/
Suites: plucky
Components: main
Signed-By: /usr/share/keyrings/apt-fast-archive-keyring.gpg
EOF
  displayandexec "Installation de apt-fast                            " "\
  is_file_present_and_rmfile "/usr/share/keyrings/apt-fast-archive-keyring.gpg" && \
  $WGET --output-document - 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B' | gpg --dearmor --output /usr/share/keyrings/apt-fast-archive-keyring.gpg && \
  $AG update && \
  $AGI apt-fast"
}
# Pour récupérer la clé PGP
# il faut récupérer la clé avec l'URL qui a une forme suivante :
# https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B
# Il suffit de mettre la clé (A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B) après le 0x du search
################################################################################

################################################################################
## instalation de drawio
##------------------------------------------------------------------------------
install_drawio() {
  displayandexec "Installation de drawio                              " "\
  reset_dir ""$manual_install_dir"/drawio/" && \
  $WGET -P "$manual_install_dir"/drawio/ https://github.com/jgraph/drawio-desktop/releases/download/v"$drawio_version"/drawio-x86_64-"$drawio_version".AppImage && \
  chmod +x "$manual_install_dir"/drawio/drawio-x86_64-"$drawio_version".AppImage && \
  $WGET -P "$manual_install_dir"/drawio/ 'https://raw.githubusercontent.com/jgraph/drawio/master/src/main/webapp/images/drawlogo256.png'"
  cat> /usr/share/applications/drawio.desktop << EOF
[Desktop Entry]
Name=draw.io
Exec=$manual_install_dir/drawio/drawio-x86_64-$drawio_version.AppImage
Terminal=false
Type=Application
Icon=$manual_install_dir/drawio/drawlogo256.png
StartupWMClass=draw.io
Comment=diagrams.net desktop
MimeType=application/vnd.jgraph.mxfile;application/vnd.visio;
Categories=Graphics;
EOF
}
################################################################################

################################################################################
## instalation de Typora
##------------------------------------------------------------------------------
install_typora() {
  cat> /etc/apt/sources.list.d/typora.list << 'EOF'
deb [signed-by=/usr/share/keyrings/typora-archive-keyring.gpg] https://downloads.typora.io/linux ./
# deb-src https://downloads.typora.io/linux ./
EOF
  displayandexec "Installation de Typora                              " "\
  is_file_present_and_rmfile "/usr/share/keyrings/typora-archive-keyring.gpg" && \
  $WGET --output-document - 'https://downloads.typora.io/typora.gpg' | gpg --dearmor --output /usr/share/keyrings/typora-archive-keyring.gpg && \
  $AG update && \
  $AGI typora"
}
################################################################################

################################################################################
## instalation de VirtualBox
##------------------------------------------------------------------------------
install_virtualbox_bookworm() {
  displayandexec "Installation des dépendances de VirtualBox          " "set +x && $AGI dkms"
  displayandexec "Installation de VirtualBox                          " "\
  echo 'deb [signed-by=/usr/share/keyrings/virtualbox-archive-keyring.gpg] https://download.virtualbox.org/virtualbox/debian bookworm contrib' > /etc/apt/sources.list.d/virtualbox.list && \
  is_file_present_and_rmfile "/usr/share/keyrings/virtualbox-archive-keyring.gpg" && \
  $WGET --output-document - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | gpg --dearmor --output /usr/share/keyrings/virtualbox-archive-keyring.gpg && \
  $AG update && \
  $AGI virtualbox-7.0"
  local tmp_dir="$(mktemp -d)"
  virtualbox_version="$(virtualbox --help 2>/dev/null | grep -Po '( v)\K[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')"
  displayandexec "Installation de VM VirtualBox Extension Pack        " "\
  $WGET -P "$tmp_dir" https://download.virtualbox.org/virtualbox/"$virtualbox_version"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack && \
  echo y | /usr/bin/VBoxManage extpack install --replace "$tmp_dir"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack; \
  rm -rf "$tmp_dir""
  # Une solution qui devrait marché mais il faut avoir le hachage de la licence pour pouvoir l'executer et on obtient le hachage qu'en lançant une première fois la commande
  # VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-$virtualbox_version.vbox-extpack --accept-license --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb
  # https://www.virtualbox.org/ticket/16674
  # Pour lister les extensions virutlabox une fois l'installation terminé : VBoxManage list extpacks
  # Pour supprimer une ancienne version du pack d'extension :
  # sudo VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack" && sudo VBoxManage extpack cleanup

  configure_SecureBoot_params() {
    # création du dossier qui contiendra les signatures pour le SecureBoot
    [ -d /usr/share/manual_sign_kernel_module ] && mv /usr/share/manual_sign_kernel_module /usr/share/manual_sign_kernel_module.bkp_"$now"
    mkdir /usr/share/manual_sign_kernel_module
    # création du script qui permet de signer les modules vboxdrv vboxnetflt vboxnetadp vboxpci pour VirtualBox
    cat> /opt/sign_virtualbox_kernel_module.sh << 'EOF'
#!/bin/bash

# Test que le script est lancer en root
if [ $EUID != 0 ]; then
  echo "Le script doit être executer en root: # sudo $0" 1>&2
  exit 1
fi

UNAMER="$(uname -r)"

mkdir -p /usr/share/manual_sign_kernel_module/virtualbox
cd /usr/share/manual_sign_kernel_module/virtualbox

virtualbox_modules='
vboxdrv
vboxnetflt
vboxnetadp
vboxpci
'

for module in $virtualbox_modules; do
  openssl req \
    -new \
    -x509 \
    -newkey rsa:2048 \
    -keyout "$module".priv \
    -outform DER \
    -out "$module".der \
    -nodes \
    -days 36500 \
    -subj "/CN="$module"/" && \
  /usr/src/linux-headers-"$UNAMER"/scripts/sign-file \
    sha512 \
    ./"$module".priv \
    ./"$module".der \
    /lib/modules/"$UNAMER"/misc/"$module".ko
done

# openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetflt.priv -outform DER -out vboxnetflt.der -nodes -days 36500 -subj "/CN=vboxnetflt/"
# /usr/src/linux-headers-"$UNAMER"/scripts/sign-file sha512 ./vboxnetflt.priv ./vboxnetflt.der /lib/modules/"$UNAMER"/misc/vboxnetflt.ko

# openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetadp.priv -outform DER -out vboxnetadp.der -nodes -days 36500 -subj "/CN=vboxnetadp/"
# /usr/src/linux-headers-"$UNAMER"/scripts/sign-file sha512 ./vboxnetadp.priv ./vboxnetadp.der /lib/modules/"$UNAMER"/misc/vboxnetadp.ko

# openssl req -new -x509 -newkey rsa:2048 -keyout vboxpci.priv -outform DER -out vboxpci.der -nodes -days 36500 -subj "/CN=vboxpci/"
# /usr/src/linux-headers-"$UNAMER"/scripts/sign-file sha512 ./vboxpci.priv ./vboxpci.der /lib/modules/"$UNAMER"/misc/vboxpci.ko

mokutil --import vboxdrv.der
mokutil --import vboxnetflt.der
mokutil --import vboxnetadp.der
mokutil --import vboxpci.der
# normallement on peut faire le mokutil avec l'import de plusieurs fichiers en même temps, il faudra tester si c'est possible avant d'intégrer la ligne suivante dans le script
#mokutil --import vboxdrv.der vboxnetflt.der vboxnetadp.der vboxpci.der

reboot
EOF
    chmod +x /opt/sign_virtualbox_kernel_module.sh
  }
  # ref : [Debian, SecureBoot et les modules noyaux DKMS - Where is it?](https://medspx.fr/blog/Debian/secure_boot_dkms/)

  if [ "$secureboot_enable" == 1 ]; then
    configure_SecureBoot_params
  fi
}
################################################################################

################################################################################
## instalation de KeePassXC
##------------------------------------------------------------------------------
install_keepassxc() {
  displayandexec "Installation de KeePassXC                           " "\
  reset_dir ""$manual_install_dir"/KeePassXC/" && \
  $WGET -P "$manual_install_dir"/KeePassXC/ https://github.com/keepassxreboot/keepassxc/releases/download/"$keepassxc_version"/KeePassXC-"$keepassxc_version"-x86_64.AppImage && \
  chmod +x "$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage && \
  $WGET -P "$manual_install_dir"/KeePassXC/ 'https://raw.githubusercontent.com/keepassxreboot/keepassxc/develop/share/icons/application/256x256/apps/keepassxc.png'"
  cat> /usr/share/applications/keepassxc.desktop << EOF
[Desktop Entry]
Comment=Password Manager
Terminal=false
Name=KeePassXC
Exec=$manual_install_dir/KeePassXC/KeePassXC-$keepassxc_version-x86_64.AppImage
Type=Application
Icon=$manual_install_dir/KeePassXC/keepassxc.png
Categories=Utility;Security;Qt;
MimeType=application/x-keepass2;
X-GNOME-Autostart-enabled=true
EOF
}
################################################################################

################################################################################
## instalation de Etcher
##------------------------------------------------------------------------------
install_etcher() {
  displayandexec "Installation de Etcher                              " "\
  reset_dir ""$manual_install_dir"/balenaEtcher/" && \
  $WGET -P "$manual_install_dir"/balenaEtcher/ https://github.com/balena-io/etcher/releases/download/v"$etcher_version"/balenaEtcher-"$etcher_version"-x64.AppImage && \
  chmod +x "$manual_install_dir"/balenaEtcher/balenaEtcher-"$etcher_version"-x64.AppImage && \
  $WGET -P "$manual_install_dir"/balenaEtcher/ 'https://github.com/balena-io/etcher/raw/master/assets/icon.png'"
  cat> /usr/share/applications/balena-etcher-electron.desktop << EOF
[Desktop Entry]
Name=balenaEtcher
Exec=$manual_install_dir/balenaEtcher/balenaEtcher-$etcher_version-x64.AppImage
Terminal=false
Type=Application
Icon=$manual_install_dir/balenaEtcher/icon.png
StartupWMClass=balenaEtcher
Comment=Flash OS images to SD cards and USB drives, safely and easily.
MimeType=x-scheme-handler/etcher;
Categories=Utility;
EOF
}
################################################################################

################################################################################
## instalation de Shotcut
##------------------------------------------------------------------------------
install_shotcut() {
  displayandexec "Installation de Shotcut                             " "\
  reset_dir ""$manual_install_dir"/shotcut/" && \
  $WGET -P "$manual_install_dir"/shotcut/ https://github.com/mltframework/shotcut/releases/download/v"$shotcut_version"/"$shotcut_appimage" && \
  chmod +x "$manual_install_dir"/shotcut/"$shotcut_appimage" && \
  $WGET -P "$manual_install_dir"/shotcut/ 'https://github.com/mltframework/shotcut/raw/master/icons/shotcut-logo-64.png'"
  cat> /usr/share/applications/shotcut.desktop << EOF
[Desktop Entry]
Name=shotcut
Exec=$manual_install_dir/shotcut/$shotcut_appimage
Terminal=false
Type=Application
Icon=$manual_install_dir/shotcut/shotcut-logo-64.png
Comment=a free, open source, cross-platform video editor
MimeType=video/x-matroska;video/webm;video/x-flv;video/mp4;
Categories=Graphics;
EOF
}
################################################################################

################################################################################
## instalation de Signal
##------------------------------------------------------------------------------
install_signal() {
  cat> /etc/apt/sources.list.d/signal-desktop.list << 'EOF'
Types: deb
URIs: https://updates.signal.org/desktop/apt/
Suites: xenial
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/signal-archive-keyring.gpg
EOF
  displayandexec "Installation de Signal                              " "\
  is_file_present_and_rmfile "/usr/share/keyrings/signal-archive-keyring.gpg" && \
  $CURL 'https://updates.signal.org/desktop/apt/keys.asc' | gpg --dearmor --output /usr/share/keyrings/signal-archive-keyring.gpg && \
  $AG update && \
  $AGI signal-desktop"
}
# https://signal.org/download/linux/
# curl -sL https://updates.signal.org/static/desktop/apt/signal-desktop.sources | cat
################################################################################

################################################################################
## instalation de asbru
##------------------------------------------------------------------------------
install_asbru() {
  cat> /etc/apt/sources.list.d/asbru-cm.sources << 'EOF'
Types: deb
URIs: https://packagecloud.io/asbru-cm/asbru-cm/debian/
Suites: bullseye
Components: main
Signed-By: /usr/share/keyrings/asbru-archive-keyring.gpg
EOF
  displayandexec "Installation des dépendances de Asbru               " "$AGI perl libvte-2.91-0 libcairo-perl libglib-perl libpango-perl libsocket6-perl libexpect-perl libnet-proxy-perl libyaml-perl libcrypt-cbc-perl libcrypt-blowfish-perl libgtk3-perl libnet-arp-perl libossp-uuid-perl openssh-client telnet ftp libcrypt-rijndael-perl libxml-parser-perl libcanberra-gtk-module dbus-x11 libx11-guitest-perl libgtk3-simplelist-perl gir1.2-wnck-3.0 gir1.2-vte-2.91"
  displayandexec "Installation de Asbru                               " "\
  is_file_present_and_rmfile "/usr/share/keyrings/asbru-archive-keyring.gpg" && \
  $CURL 'https://packagecloud.io/asbru-cm/asbru-cm/gpgkey' | gpg --dearmor --output /usr/share/keyrings/asbru-archive-keyring.gpg && \
  $AG update && \
  $AGI asbru-cm keepassxc-"
}

# On rajoute keepassxc- dans la commande d'install du paquet pour pas que asbru install keepassxc en tant que dépendance (même si il n'est seulement que dans les recommmends (apt-cache show asbru-cm | grep keepassxc))

# a priori le nouveau dépot serrait celui de cloudsmith.io d'après https://docs.asbru-cm.net/General/Installation/#debian
# https://dl.cloudsmith.io/public/asbru-cm/release/gpg.7684B0670B1C65E8.key
# deb [arch=amd64 signed-by=/usr/share/keyrings/asbru-archive-keyring.gpg] https://dl.cloudsmith.io/public/asbru-cm/release/deb/debian bullseye main
#deb-src https://dl.cloudsmith.io/public/asbru-cm/release/deb/debian bullseye main

# Pour voir la liste des version de debian disponibles dans les dépots de Cloudsmith : [Cloudsmith - Repositories - asbru-cm (asbru-cm) - release (release) - Packages](https://cloudsmith.io/~asbru-cm/repos/release/packages/?q=distribution%3Adebian&sort=-date)
################################################################################

################################################################################
## instalation de bat
##------------------------------------------------------------------------------
install_bat() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Bat                                 " "\
  $WGET -P "$tmp_dir" https://github.com/sharkdp/bat/releases/download/v"$bat_version"/bat_"$bat_version"_amd64.deb && \
  dpkg -i "$tmp_dir"/bat_"$bat_version"_amd64.deb; \
  rm -rf "$tmp_dir""
}
################################################################################

################################################################################
## instalation de yt-dlp
##------------------------------------------------------------------------------
install_yt-dlp() {
  # install Deno (JavaScript, TypeScript, and WebAssembly runtime) because of :
  # [[Announcement] Upcoming new requirements for YouTube downloads · Issue #14404 · yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp/issues/14404)
  # [[Announcement] Upcoming new requirements for YouTube downloads · Issue #14404 · yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp/issues/14404#issuecomment-3330980464)
  # [[ie/youtube] Force player `0004de42` by seproDev · Pull Request #14398 · yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp/pull/14398)
  # [[Announcement] Upcoming new requirements for YouTube downloads · Issue #14404 · yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp/issues/14404#issuecomment-3330980464)
  
  # local tmp_dir="$(mktemp -d)"
  # $WGET -P "$my_bin_path" https://github.com/denoland/deno/releases/download/v2.5.2/deno-x86_64-unknown-linux-gnu.zip
  # unzip "$tmp_dir"/deno-x86_64-unknown-linux-gnu.zip -d "$manual_install_dir"/ && \
  # rm -rf "$tmp_dir"
  # /tmp/test_unzip_deno/deno --version | grep -Po '^(deno )\K[0-9]+\.[0-9]+\.[0-9]+'

  displayandexec "Installation de yt-dlp                              " "\
  is_file_present_and_rmfile ""$my_bin_path"/yt-dlp" && \
  $WGET -P "$my_bin_path" https://github.com/yt-dlp/yt-dlp/releases/download/"$ytdlp_version"/yt-dlp_linux  && \
  chmod +x "$my_bin_path"/yt-dlp"
}
################################################################################

################################################################################
## instalation de joplin
##------------------------------------------------------------------------------
install_joplin() {
  displayandexec "Installation de joplin                              " "\
  reset_dir ""$manual_install_dir"/Joplin/" && \
  $WGET -P "$manual_install_dir"/Joplin/ https://github.com/laurent22/joplin/releases/download/v"$joplin_version"/Joplin-"$joplin_version".AppImage && \
  chmod +x "$manual_install_dir"/Joplin/Joplin-"$joplin_version".AppImage && \
  $WGET -P "$manual_install_dir"/Joplin/ 'https://raw.githubusercontent.com/laurent22/joplin/master/Assets/LinuxIcons/256x256.png'"
  cat> /usr/share/applications/joplin.desktop << EOF
[Desktop Entry]
Comment=Markdown Editor
Terminal=false
Name=Joplin
Exec=$manual_install_dir/Joplin/Joplin-$joplin_version.AppImage
Type=Application
Icon=$manual_install_dir/Joplin/256x256.png
EOF
}
################################################################################

################################################################################
## instalation de Krita
##------------------------------------------------------------------------------
install_krita() {
  displayandexec "Installation de Krita                               " "\
  reset_dir ""$manual_install_dir"/Krita/" && \
  $WGET -P "$manual_install_dir"/Krita/ https://download.kde.org/stable/krita/"$krita_version"/krita-"$krita_version"-x86_64.appimage && \
  chmod +x "$manual_install_dir"/Krita/krita-"$krita_version"-x86_64.appimage && \
  $WGET -P "$manual_install_dir"/Krita/ 'https://invent.kde.org/graphics/krita/-/raw/master/pics/krita.png'"
  cat> /usr/share/applications/krita.desktop << EOF
[Desktop Entry]
Name=Krita
Exec=$manual_install_dir/Krita/krita-$krita_version-x86_64.appimage
GenericName=Digital Painting
GenericName[fr]=Peinture numérique
MimeType=application/x-krita;image/openraster;application/x-krita-paintoppreset;
Comment=Digital Painting
Comment[fr]=Peinture numérique
Type=Application
Icon=$manual_install_dir/Krita/krita.png
Categories=Qt;KDE;Graphics;2DGraphics;RasterGraphics;
StartupNotify=true
StartupWMClass=krita
EOF
}
# le contenu du .desktop est basé sur celui-ci : https://github.com/KDE/krita/blob/master/krita/org.kde.krita.desktop
################################################################################

################################################################################
## instalation de OpenSnitch
##------------------------------------------------------------------------------
install_opensnitch() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation des dépendances de OpenSnitch          " "$AGI libnetfilter-queue1"
  displayandexec "Installation de OpenSnitch                          " "\
  $AGI python3-pyqt5.qtsql python3-pyinotify python3-grpcio python3-slugify python3-notify2 && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_stable_version"/python3-opensnitch-ui_"$opensnitch_stable_version"-1_all.deb && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_stable_version"/opensnitch_"$opensnitch_stable_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/opensnitch_"$opensnitch_stable_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/python3-opensnitch-ui_"$opensnitch_stable_version"-1_all.deb && \
  $AG install -f -y; \
  rm -rf "$tmp_dir""
}
# l'installation de OpenSnitch est intérecatif mais n'utilise pas d'entrés dans debconf-set-selections
# potentiellement qu'on peut corriger le problème avec debian non-interractive
# c'est probablement lié au fait que dpkg ne respect peut être pas la variable DEBIAN_FRONTEND
################################################################################

################################################################################
## instalation de Ansible
##------------------------------------------------------------------------------
install_ansible() {
  displayandexec "Installation de Ansible                             " "\
  $ExeAsUser pipx install --include-deps ansible && \
  $ExeAsUser pipx inject ansible proxmoxer && \
  $ExeAsUser pipx inject --include-deps --include-apps ansible requests && \
  $ExeAsUser pipx inject ansible pykeepass"
  $ExeAsUser cat>> /home/"$local_user"/.bashrc << 'EOF'

# for Ansible vault editor
export EDITOR=nano
EOF
}
# ref : [pipx install ansible - No binaries associated with this package. · Issue #20 · pypa/pipx](https://github.com/pypa/pipx/issues/20#issuecomment-1346446624)
################################################################################

################################################################################
## instalation de Hashcat
##------------------------------------------------------------------------------
install_hashcat() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Hashcat                             " "\
  $WGET -P "$tmp_dir" https://github.com/hashcat/hashcat/releases/download/v"$hashcat_version"/hashcat-"$hashcat_version".7z && \
  reset_dir ""$manual_install_dir"/hashcat/" && \
  7z x "$tmp_dir"/hashcat-"$hashcat_version".7z -o"$manual_install_dir"/hashcat && \
  chown -R "$local_user":"$local_user" "$manual_install_dir"/hashcat && \
  ln -s "$manual_install_dir"/hashcat/hashcat-"$hashcat_version"/hashcat.bin "$my_bin_path"/hashcat; \
  rm -rf "$tmp_dir""
# hashcat a besoin d'être capable d'écrire dans son répertoire, il faut donc soit associer le répertoire à l'utilisateur soit le lancer en sudo
}
################################################################################

################################################################################
## instalation de sshuttle
##------------------------------------------------------------------------------
install_sshuttle() {
  displayandexec "Installation de sshuttle                            " "\
  pipx install sshuttle"
}
# ref : [sshuttle · PyPI](https://pypi.org/project/sshuttle/)
# on l'install pour l'utilisateur root car sshuttle sera executer en sudo
################################################################################

################################################################################
## instalation de weasyprint
##------------------------------------------------------------------------------
install_weasyprint() {
  displayandexec "Installation de weasyprint                          " "\
  $ExeAsUser pipx install weasyprint"
}
################################################################################

################################################################################
## instalation de Geeqie
##------------------------------------------------------------------------------
install_geeqie() {
  displayandexec "Installation de Geeqie                              " "\
  reset_dir ""$manual_install_dir"/Geeqie/" && \
  $WGET -P "$manual_install_dir"/Geeqie/ https://github.com/BestImageViewer/geeqie/releases/download/v"$geeqie_version"/Geeqie-v"$geeqie_version"-x86_64.AppImage && \
  $WGET -P "$manual_install_dir"/Geeqie/ 'https://raw.githubusercontent.com/geeqie/geeqie.github.io/master/geeqie.svg' && \
  chmod +x "$manual_install_dir"/Geeqie/Geeqie-v"$geeqie_version"-x86_64.AppImage"
  cat> /usr/share/applications/geeqie.desktop << EOF
[Desktop Entry]
Name=Geeqie
GenericName=Image Viewer
GenericName[fr]=Visualisateur d'images
Comment=View and manage images
Comment[fr]=Voir et gérer des images
Exec=$manual_install_dir/Geeqie/Geeqie-v$geeqie_version-x86_64.AppImage
Icon=$manual_install_dir/Geeqie/geeqie.svg
Type=Application
Terminal=false
# Startup notification disabled, since the remote -r switch may not open a new window...
#StartupNotify=false
#StartupWMClass=geeqie
NotShowIn=X-Geeqie;
Categories=Graphics;Viewer;
MimeType=application/x-navi-animation;image/bmp;image/x-bmp;image/x-MS-bmp;image/gif;image/x-icon;image/jpeg;image/png;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-tga;image/tiff;image/x-xbitmap;image/x-xpixmap;image/svg;image/svg+xml;image/x-png;image/xpm;image/x-ico;
EOF
}
# le contenu du .desktop est basé sur celui-ci : https://github.com/geeqie/geeqie.github.io/blob/master/geeqie.desktop

# à noter que maintenant les AppImages sont générées automatiquement par la CI/CD Github dans "Continuous build" : [Release Continuous build · BestImageViewer/geeqie](https://github.com/BestImageViewer/geeqie/releases/tag/continuous)
# à priori, il ne semble plus exister de AppImage pour une version spécifiquement, mais uniquement des AppImages créées automatiquement suite à un merge request du code source : [Where can I download a Geeqie Appimage 2.4 for Xubuntu · Issue #1404 · BestImageViewer/geeqie](https://github.com/BestImageViewer/geeqie/issues/1404#issuecomment-2183912638)


# le code à utiliser si jamais ils suppriment encore une fois la génération des AppImages via des releases
#   $WGET -P "$manual_install_dir"/Geeqie/ 'https://github.com/BestImageViewer/geeqie/releases/download/continuous/Geeqie-latest-x86_64.AppImage' && \
#   chmod +x "$manual_install_dir"/Geeqie/Geeqie-latest-x86_64.AppImage"

# Exec=$manual_install_dir/Geeqie/Geeqie-latest-x86_64.AppImage
################################################################################

################################################################################
## instalation de timeshift
##------------------------------------------------------------------------------
install_timeshift_bookworm() {
  cat> /etc/apt/sources.list.d/timeshift.sources << 'EOF'
Types: deb
URIs: http://packages.linuxmint.com/
Suites: faye
Components: backport
Signed-By: /usr/share/keyrings/timeshift-archive-keyring.gpg
EOF
  displayandexec "Installation de timeshift                           " "\
  is_file_present_and_rmfile "/usr/share/keyrings/timeshift-archive-keyring.gpg" && \
  $WGET --output-document - 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xa6616109451bbbf2' | gpg --dearmor --output /usr/share/keyrings/timeshift-archive-keyring.gpg && \
  $AG update && \
  $AGI timeshift"
}
# to get the GPG Key version : https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=index&search=0x1B32B87ABAEE357218F6B48CB5B116B72D0F61F0
# https://launchpad.net/~teejee2008/+archive/ubuntu/timeshift

# ancienne install depuis Ubuntu :
# install_timeshift_bookworm() {
#   cat> /etc/apt/sources.list.d/timeshift.list << 'EOF'
# deb [arch=amd64 signed-by=/usr/share/keyrings/timeshift-archive-keyring.gpg] http://ppa.launchpad.net/teejee2008/timeshift/ubuntu kinetic main
# #deb-src http://ppa.launchpad.net/teejee2008/timeshift/ubuntu kinetic main
# EOF
#   displayandexec "Installation de timeshift                           " "\
#   is_file_present_and_rmfile "/usr/share/keyrings/timeshift-archive-keyring.gpg" && \
#   $WGET --output-document - 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x1B32B87ABAEE357218F6B48CB5B116B72D0F61F0' | gpg --dearmor --output /usr/share/keyrings/timeshift-archive-keyring.gpg && \
#   $AG update && \
#   $AGI timeshift"
# }

# depuis que timeshift a été repris par Mint, son dépot APT est ici : http://packages.linuxmint.com/pool/backport/t/timeshift/
# le soucis, c'est qu'on ne sait pas si on ne risque pas de casser APT en important un paquet de Mint
# si on se base sur LMDE (Linux Mint Debian Edition), il faudrait prendre le paquet du pool Faye pour correspondre à bookworm, cf https://en.wikipedia.org/wiki/Linux_Mint#Releases
# curl -sL 'http://packages.linuxmint.com/pool/backport/t/timeshift/' | tr -s '<' '\n' | grep 'timeshift_.*_amd64.deb$' | grep -i 'Faye'
# Pou récupérer la clé PGP : curl -sL 'http://packages.linuxmint.com/dists/faye/Release.gpg'
# Bon je ne comprend pas bien pourquoi, mais ça ne fonctionne pas en utilisant la clé http://packages.linuxmint.com/dists/faye/Release.gpg, par contre ça fonctionne quand on l'import en utilisant son short ID depuis keyserver.ubuntu.com
# Pour récupérer le key ID depuis la clé GPG d'origine : curl -sL 'http://packages.linuxmint.com/dists/faye/Release.gpg' | gpg --list-packets | grep 'keyid'
################################################################################

################################################################################
## instalation de Visual Studio Code
##------------------------------------------------------------------------------
install_vscode() {
  cat> /etc/apt/sources.list.d/vscode.list << 'EOF'
deb [arch=amd64 signed-by=/usr/share/keyrings/vscode-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main
EOF
  displayandexec "Installation de vscode                              " "\
  is_file_present_and_rmfile "/usr/share/keyrings/vscode-archive-keyring.gpg" && \
  $CURL 'https://packages.microsoft.com/keys/microsoft.asc' | gpg --dearmor --output /usr/share/keyrings/vscode-archive-keyring.gpg && \
  $AG update && \
  $AGI code"
}
################################################################################

################################################################################
## instalation de Brave
##------------------------------------------------------------------------------
install_brave() {
  cat> /etc/apt/sources.list.d/brave.sources << 'EOF'
Types: deb
URIs: https://brave-browser-apt-release.s3.brave.com/
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/brave-archive-keyring.gpg
EOF
  displayandexec "Installation de brave                               " "\
  is_file_present_and_rmfile "/usr/share/keyrings/brave-archive-keyring.gpg" && \
  $WGET --output-document - 'https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg' | gpg --dearmor --output /usr/share/keyrings/brave-archive-keyring.gpg && \
  $AG update && \
  $AGI brave-browser"
}
# La conf de Brave est dans /home/$USER/.config/BraveSoftware/Brave-Browser/Default
################################################################################

################################################################################
## instalation de Ventoy
##------------------------------------------------------------------------------
install_ventoy() {
  local tmp_dir="$(mktemp -d)"
  cat> "$my_bin_path"/ventoy << EOF
#!/bin/bash
sudo $manual_install_dir/ventoy/ventoy-$ventoy_version/VentoyGUI.x86_64
EOF
  displayandexec "Installation de ventoy                              " "\
  $WGET -P "$tmp_dir" https://github.com/ventoy/Ventoy/releases/download/v"$ventoy_version"/ventoy-"$ventoy_version"-linux.tar.gz && \
  reset_dir ""$manual_install_dir"/ventoy/" && \
  tar --directory "$manual_install_dir"/ventoy -xzf "$tmp_dir"/ventoy-"$ventoy_version"-linux.tar.gz && \
  chmod +x "$my_bin_path"/ventoy; \
  rm -rf "$tmp_dir""
}
################################################################################

################################################################################
## instalation de BindToInterface
##------------------------------------------------------------------------------
install_bindtointerface() {
  local tmp_dir="$(mktemp -d)" && \
  displayandexec "Installation de BindToInterface                     " "\
  $WGET -P "$tmp_dir" 'https://github.com/JsBergbau/BindToInterface/archive/main.zip' && \
  unzip -j "$tmp_dir"/main.zip -d "$manual_install_dir"/BindToInterface" && \
  cat> "$manual_install_dir"/BindToInterface/compil_BindToInterface.sh << EOF
#!/bin/bash
sudo gcc -nostartfiles -fpic -shared $manual_install_dir/BindToInterface/bindToInterface.c -o $manual_install_dir/BindToInterface/bindToInterface.so -ldl -D_GNU_SOURCE
EOF
  execandlog "chmod +x "$manual_install_dir"/BindToInterface/compil_BindToInterface.sh; \
  rm -rf "$tmp_dir""
}
# pour l'instant je préfère ne pas intégrer le fait de faire la compilation directemant dans le script post install tout en laissant la possibilité de le faire simplement via l'execution du script compil_BindToInterface.sh
# [GitHub - JsBergbau/BindToInterface: With this program you can bind applications to a specific network interface / network adapter. This is very useful if you have multiple (internet) connections and want your program to use a specific one.](https://github.com/JsBergbau/BindToInterface)
################################################################################

################################################################################
## instalation de Glow
install_glow() {
  cat> /etc/apt/sources.list.d/charm.sources << 'EOF'
Types: deb
URIs: https://repo.charm.sh/apt/
Suites: *
Components: *
Signed-By: /usr/share/keyrings/charm-archive-keyring.gpg
EOF
  displayandexec "Installation de Glow                                " "\
  is_file_present_and_rmfile "/usr/share/keyrings/charm-archive-keyring.gpg" && \
  $WGET --output-document - 'https://repo.charm.sh/apt/gpg.key' | gpg --dearmor --output /usr/share/keyrings/charm-archive-keyring.gpg && \
  $AG update && \
  $AGI glow"
}
################################################################################

################################################################################

################################################################################
## instalation de Flatpak
##------------------------------------------------------------------------------
install_flatpak() {
  displayandexec "Installation de Flatpak                             " "\
  $AGI flatpak && \
  $ExeAsUser flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
}

install_flatpak_software() {
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.onlyoffice.desktopeditors"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.remmina.Remmina"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.geeqie.Geeqie"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub fr.handbrake.ghb"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub com.jgraph.drawio.desktop"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.bunkus.mkvtoolnix-gui"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub io.github.flattool.Warehouse"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.virt_manager.virt-viewer"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.shotcut.Shotcut"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.kde.krita"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub com.spotify.Client"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub com.github.tchx84.Flatseal"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.filezillaproject.Filezilla"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub org.inkscape.Inkscape"
  execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub com.github.xournalpp.xournalpp"
  # execandlog "$ExeAsUser flatpak install --user --assumeyes --noninteractive flathub com.vscodium.codium"
}
# flatpak list --app
# flatpak history

# à noter que VirtualBox pourrait à terme être installé via flatpak grâce au fork utilisant KVM
# [johnny24x/VirtualBoxKVMFlatpak: 🔧 Package VirtualBox as a Flatpak, leveraging KVM support patches for efficient virtual machine management and easy installation on various systems.](https://github.com/johnny24x/VirtualBoxKVMFlatpak)
# [#21797 (add VirtualBox to flathub.org / flatpak Integration for easier installation Linux) – Oracle VirtualBox](https://www.virtualbox.org/ticket/21797)
# [Package VirtualBox - Requests - Flathub Discourse](https://discourse.flathub.org/t/package-virtualbox/4347/11)

install_flatpak
install_flatpak_software
################################################################################

# Pour facilier la gestion du passage d'une version de debian à une autre
get_available_distrib_version_repo_url() {
repo_url='
https://download.virtualbox.org/virtualbox/debian
http://ppa.launchpad.net/apt-fast/stable/ubuntu
https://updates.signal.org/desktop/apt
https://packagecloud.io/asbru-cm/asbru-cm/debian
http://ppa.launchpad.net/teejee2008/timeshift/ubuntu
https://brave-browser-apt-release.s3.brave.com
'
# https://packages.microsoft.com/repos/code
# http://repository.spotify.com

for url in $repo_url; do
  echo "$url"
  echo '----------------------------------------------------------------------------'
  curl --silent --location --header 'user-agent: Debian APT-HTTP/1.3 (2.2.4)' ""$url"/dists"
  printf '\n\n'
done
}
# get_available_distrib_version_repo_url

# apelle à la fonction qui permet de récupérer toutes les versions des logiciels qui s'installent manuellement
check_latest_version_manual_install_apps

install_all_manual_install_apps_bookworm() {
  # install_winscp
  install_veracrypt
  # install_spotify
  install_apt-fast
  # install_drawio
  install_typora
  install_virtualbox_bookworm
  install_keepassxc
  install_etcher
  # install_shotcut
  install_signal
  install_asbru
  # install_bat
  install_yt-dlp
  install_joplin
  # install_krita
  install_opensnitch
  install_ansible
  install_hashcat
  install_sshuttle
  install_weasyprint
  # install_geeqie
  install_timeshift_bookworm
  install_vscode
  install_brave
  install_ventoy
  install_bindtointerface
  install_flatpak
  install_glow
}

install_all_manual_install_apps_trixie() {
  # install_winscp
  install_veracrypt
  # install_spotify
  install_apt-fast
  # install_drawio
  install_typora
  # install_virtualbox_bookworm
  install_keepassxc
  install_etcher
  # install_shotcut
  install_signal
  install_asbru
  # install_bat
  install_yt-dlp
  install_joplin
  # install_krita
  install_opensnitch
  install_ansible
  install_hashcat
  install_sshuttle
  install_weasyprint
  # install_geeqie
  # install_timeshift_bookworm
  install_vscode
  install_brave
  install_ventoy
  install_bindtointerface
  install_flatpak
  install_glow
}

if [ -z "$fisrt_time_script_executed" ]; then
  if [ "$bookworm" == 1 ]; then
    install_all_manual_install_apps_bookworm
  fi
  if [ "$trixie" == 1 ]; then
    install_all_manual_install_apps_trixie
  fi
fi
# Pour l'instant on désactive l'installation des programmes avec une installation manuelle lorsque ce n'est pas la première fois que le script s'execute
################################################################################

################################################################################
## désinstalation des paquets non souhaités
##------------------------------------------------------------------------------
echo ''
echo '     ################################################################'
echo '     #           DESINSTALATION DES PAQUETS NON SOUHAITES           #'
echo '     ################################################################'
echo ''

#jeux Gnome sauf jeu d'échech (gnome-chess)
displayandexec "Désinstalation des jeux Gnome                       " "$AG remove -y five-or-more \
four-in-a-row \
gnome-klotski \
gnome-mahjongg \
gnome-mines \
gnome-nibbles \
gnome-robots \
gnome-sudoku \
gnome-taquin \
gnome-tetravex \
hitori \
iagno \
lightsoff \
quadrapassel \
swell-foop \
tali \
aisleriot"

# le résultat de la commande suivante n'est pas tout à fait juste car il y a notamment des paquets qui n'ont pas le tag "suite::gnome"
# grep-aptavail -sPackage \( --field Tag "suite::gnome" --and --field Tag "use::gameplaying" \) | grep -Po '(^Package: )\K.*' | sort -u | tr -s '\n' ' '
# on est donc obliger d'utiliser la commande qui listes les dépendances du meta-paquet gnome-games pour obtenir la liste des paquets correspondant au jeux Gnome
# apt-cache depends gnome-games | awk -F': ' '(NR>1){print $2}' | tr -s '\n' ' '
# Pour lister tous les jeux dans les dépots debian
# grep-aptavail -sPackage --field Section "game" | grep -Po '(^Package: )\K.*' | sort -u | tr -s '\n' ' '

#synaptic
displayandexec "Désinstalation de synaptic                          " "$AG remove -y synaptic"

#de l'outil Parental Control de Gnome
displayandexec "Désinstalation de Gnome Parental Control            " "$AG remove -y malcontent malcontent-gui"
################################################################################

################################################################################
## instalation des Gnome Shell Extension
##------------------------------------------------------------------------------
#Screenshot Tool
# the UUID is in the metadata.json
# GnomeShellExtensionUUID='gnome-shell-screenshot@ttll.de'
# the directory name must be the UUID of the gnome shell extension
# mkdir -p "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID"
#--------------------------------------------------------------------------------------------------------#
# with official gnome extension site
# $WGET 'https://extensions.gnome.org/extension-data/gnome-shell-screenshotttll.de.v40.shell-extension.zip'
# unzip -q gnome-shell-screenshotttll.de.v40.shell-extension.zip -d "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID"
#--------------------------------------------------------------------------------------------------------#
# # with github code source
# $WGET https://github.com/OttoAllmendinger/gnome-shell-screenshot/archive/v40.zip
# unzip v40.zip
# cd gnome-shell-screenshot-40
# make
# make install
# unzip -q gnome-shell-screenshot.zip -d $gnome_shell_extension_path/$GnomeShellExtensionUUID
#--------------------------------------------------------------------------------------------------------#
# enable the gnome shell extension
# $ExeAsUser gnome-shell-extension-tool -e "$GnomeShellExtensionUUID"
# il faudra remplacer gnome-shell-extension-tool -e par gnome-extensions enable pour les prochaines versions de Gnome
# gnome-extensions est disponnible a partir de Gnome 34
# should restart gdm with Alt+F2+r

install_GSE() {
  #Screenshot Tool
  install_GSE_screenshot_tool() {
    execandlog "$AGI gnome-screenshot"
    local tmp_dir="$(mktemp -d)"
    local GnomeShellExtensionUUID='gnome-shell-screenshot@ttll.de' && \
    local GnomeShellExtensionVersion="$1" && \
    execandlog "reset_dir_as_user "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
    $WGET -P "$tmp_dir" "https://extensions.gnome.org/extension-data/gnome-shell-screenshotttll.de.v"$GnomeShellExtensionVersion".shell-extension.zip" && \
    unzip -q "$tmp_dir"/gnome-shell-screenshotttll.de.v"$GnomeShellExtensionVersion".shell-extension.zip -d "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
    chown -R "$local_user":"$local_user" "$gnome_shell_extension_path"; \
    rm -rf "$tmp_dir""
  }
  # to check the latest version : https://extensions.gnome.org/extension/1112/screenshot-tool/
  # https://github.com/OttoAllmendinger/gnome-shell-screenshot/
  # gnome-screenshot est une dépendance de 'gnome-shell-screenshot@ttll.de', ref : [gnome-shell-screenshot/README.md at master · OttoAllmendinger/gnome-shell-screenshot](https://github.com/OttoAllmendinger/gnome-shell-screenshot/blob/master/README.md#errors-with-gnome-screenshot-backend)

  #system-monitor
  install_GSE_system_monitor() {
    execandlog "$AGI gnome-shell-extension-system-monitor"
    hte_dconf_system_monitor_memory_style="\"'digit'\""
    execandlog "$ExeAsUser $DCONF_write /org/gnome/shell/extensions/system-monitor/memory-style "$hte_dconf_system_monitor_memory_style""
    # on configure avec la commande ci-dessus l'affichage de la métrique de la RAM sous forme de pourcentage plustôt que de graph
    hte_dconf_system_monitor_gpu_show_menu='"true"'
    execandlog "$ExeAsUser $DCONF_write /org/gnome/shell/extensions/system-monitor/gpu-show-menu "$hte_dconf_system_monitor_gpu_show_menu""
    # on active la vue de l'utilisation du GPU dans le menu
    hte_dconf_system_monitor_disk_usage_style="\"'bar'\""
    execandlog "$ExeAsUser $DCONF_write /org/gnome/shell/extensions/system-monitor/disk-usage-style "$hte_dconf_system_monitor_disk_usage_style""
    # on chosie l'option de l'affichage de l'utilisation des disk par des barres horizontales à la place du graph en demi cercle
  }
  # à noter que si on ne voulait pas utiliser la variable hte_dconf_system_monitor_memory_style avec en plus les escapes des doubles quote à l'intérieur, il faudrait utiliser :
  # '"'\''digit'\''"'
  # de sorte à obternir "'digit'" dans l'execution du subshell de execandlog

  #Sound Input & Output Device Chooser
  install_GSE_sound_output_device_chooser() {
    local tmp_dir="$(mktemp -d)"
    local GnomeShellExtensionUUID='sound-output-device-chooser@kgshank.net' && \
    local GnomeShellExtensionVersion="$1" && \
    execandlog "reset_dir_as_user "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
    $WGET -P "$tmp_dir" "https://extensions.gnome.org/extension-data/sound-output-device-chooserkgshank.net.v"$GnomeShellExtensionVersion".shell-extension.zip" && \
    unzip -q "$tmp_dir"/sound-output-device-chooserkgshank.net.v"$GnomeShellExtensionVersion".shell-extension.zip -d "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
    chown -R "$local_user":"$local_user" "$gnome_shell_extension_path"
    rm -rf "$tmp_dir""
  }
  # to check the latest version : https://extensions.gnome.org/extension/906/sound-output-device-chooser/
  # https://github.com/kgshank/gse-sound-output-device-chooser

  enable_GSE() {
    # $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' &>/dev/null && \
    $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'gnome-shell-screenshot@ttll.de'
    $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'system-monitor@paradoxxx.zero.gmail.com'
    $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'sound-output-device-chooser@kgshank.net'
  }

  check_for_enable_GSE() {
    # if [ -z "$script_is_launch_with_gnome_terminal" ]; then
      # enable_GSE
    # else
      is_dir_present_or_mkdir_as_user "/home/"$local_user"/.tmp/"
      cat> /home/"$local_user"/.tmp/reload_GnomeShell.sh << 'EOF'
#!/bin/bash

local_user="$(awk -F':' '/:1000:/{print $1}' /etc/passwd)"
local_user_UID="$(id -u "$local_user")"
ExeAsUser="sudo -u "$local_user""

$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' &>/dev/null
EOF
      chmod +x /home/"$local_user"/.tmp/reload_GnomeShell.sh && \
      chown "$local_user":"$local_user" /home/"$local_user"/.tmp/reload_GnomeShell.sh
      cat> /home/"$local_user"/.tmp/enable_GSE.sh << 'EOF'
#!/bin/bash

local_user="$(awk -F':' '/:1000:/{print $1}' /etc/passwd)"
local_user_UID="$(id -u "$local_user")"
ExeAsUser="sudo -u "$local_user""

$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'gnome-shell-screenshot@ttll.de'
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'system-monitor@paradoxxx.zero.gmail.com'
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'sound-output-device-chooser@kgshank.net'
EOF
      chmod +x /home/"$local_user"/.tmp/enable_GSE.sh && \
      chown "$local_user":"$local_user" /home/"$local_user"/.tmp/enable_GSE.sh
    # fi
  }

  install_GSE_screenshot_tool "$GSE_screenshot_tool_version"
  install_GSE_system_monitor
  install_GSE_sound_output_device_chooser "$GSE_sound_output_device_chooser_version"
  # if [ "$bookworm" != 1 ]; then
    check_for_enable_GSE
  # fi

  displayandexec "Installation des Gnome Shell Extension              " "\
  stat "$gnome_shell_extension_path"/gnome-shell-screenshot@ttll.de/metadata.json && \
  stat "$gnome_shell_extension_path"/sound-output-device-chooser@kgshank.net/metadata.json && \
  stat /usr/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/metadata.json"
}
# il est nécessaire de recharger Gnome Shell avant de pouvoit faire un gnome-extensions enable
# la commande suivante permet de recharger Gnome Shell :
# $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
# Par contre elle coupe tout ce qui est executé au moment du lancement de la commande dans la session Gnome
# elle fait l'équivalent de la fermeture + réouverture de la session sans avoir à renseigner le mdp
# il n'est pas nécessaire de recharger Gnome Shell après avoir activé les extensions pour les voir apparaitre dans la barre supérieure

# Il est aussi possible d'installer les extensions à partir d'un appel dbus grâce à leurs UUID, avec cette méthode, l'extensions est télécharger depuis le site https://extensions.gnome.org/
# exemple :
# gdbus call --session \
           # --dest org.gnome.Shell.Extensions \
           # --object-path /org/gnome/Shell/Extensions \
           # --method org.gnome.Shell.Extensions.InstallRemoteExtension \
           # "gsconnect@andyholmes.github.io"
# ref: [Enable Gnome Extensions without session restart - Desktop - GNOME Discourse](https://discourse.gnome.org/t/enable-gnome-extensions-without-session-restart/7936/4)
# Peut aussi se faire avec busctl ou dbus-send :
# busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
# OU
# dbus-send --session --type=method_call --print-reply --dest=org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions.InstallRemoteExtension string:${EXTENSION_ID}
# ref : [How does gnome-browser-extension and chrome-gnome-shell load extension without reloading gnome session - Stack Overflow](https://stackoverflow.com/questions/72857634/how-does-gnome-browser-extension-and-chrome-gnome-shell-load-extension-without-r/73044893#73044893)

# à noter qu'il y a cette issue qui décrit exactement mon besoin : [allow installing GNOME extensions from the command line without user interaction (#7469) · Issues · GNOME / gnome-shell · GitLab](https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/7469)

# à noter ce tool qui semble très intéressant : [essembeh/gnome-extensions-cli: Command line tool to manage your Gnome Shell extensions](https://github.com/essembeh/gnome-extensions-cli)

if [ "$bookworm" == 1 ]; then
  GSE_screenshot_tool_version='73'
  GSE_sound_output_device_chooser_version='43'
  install_GSE
fi

# Pour obtenir la liste des extensions installés :
# dconf read /org/gnome/shell/enabled-extensions
# avec gnome-extensions, on peut faire gnome-extensions list
# on peut aussi lister uniquement les extensions activés avec gnome-extensions list --enabled

# System wide installed gnome-shell extensions are listed with the command
# ls /usr/share/gnome-shell/extensions/

# potentiellement installer l'extension 'show-ip@sgaraud.github.com'
# $AGI gnome-shell-extension-show-ip
# $ExeAsUser gnome-shell-extension-tool -e 'show-ip@sgaraud.github.com'

# Pour récupérer l'UUID de l'extension en ligne de commande :
# Il faut le binaire zutils (apt-get install -y zutils), car le zgrep de gzip ne fonctionne pas en récursif
# zgrep -a '"uuid":' /tmp/gnome-shell-screenshotttll.de.v56.shell-extension.zip | grep -Po '(?<="uuid": ")\K(.*)(?=",)'

# regarder si on peut faire du debug sur l'install des Gnome Shell Extension avec journalctl --user /usr/bin/gnome-shell --follow
################################################################################

################################################################################
## installation des dépendances manquantes et mise au propre de apt-get
##------------------------------------------------------------------------------
displayandexec "Installation des dépendances manquantes             " "$AG install -f -y"
displayandexec "Désinstalation des paquets qui ne sont plus utilisés" "$AG autoremove -y"
displayandexec "Mise à jour des paquets                             " "$AG update && $AG upgrade -y"
displayandexec "Suppression du cache de apt-get                     " "$AG clean"
################################################################################

#//////////////////////////////////////////////////////////////////////////////#
#                            INSTALL SCRIPT PERSO                              #
#//////////////////////////////////////////////////////////////////////////////#
echo ''
echo '     ################################################################'
echo '     #                INSTALLATION DES SCRIPTS PERSO                #'
echo '     ################################################################'
echo ''

# on utilise la patern "__my_script__" au début des scripts perso de sorte à pouvoir les retrouver facilement ultérieurement grâce à un grep sur ce patern

################################################################################
## install du script sysupdate
##------------------------------------------------------------------------------
install_sysupdate() {
  displayandexec "Installation du script sysupdate                    " "\
  is_file_present_and_rmfile ""$my_bin_path"/sysupdate" && \
  cp "$script_path"/sysupdate "$my_bin_path"/sysupdate && \
  chmod +x "$my_bin_path"/sysupdate"
}
################################################################################

################################################################################
## install du script check_backport_update
##------------------------------------------------------------------------------
install_check_backport_update() {
  # porbablement qu'il vaudrait lister les paquets qui peuvent être mis à jours avec sudo apt-get update && sudo apt list --upgradable
  # certainement avec quelque chose comme : awk '/~bpo/ && /.bpo/ {print $0}' <(sudo apt list --upgradable 2>/dev/null)
  # c'est beaucoup plus rapide
  cat> "$my_bin_path"/check_backport_update << 'EOF'
#!/bin/bash
# __my_script__

debian_release="$(lsb_release -sc)"
list_backport="$(dpkg-query -W | awk '/~bpo/{print $1}')"

while read package; do
  sudo apt-get upgrade -s -t "$debian_release"-backports "$package" | grep 'est déjà la version la plus récente'
done <<< "$list_backport"

exit 0
EOF
  displayandexec "Installation du script check_backport_update        " "\
  chmod +x "$my_bin_path"/check_backport_update"
}
################################################################################

################################################################################
## install du script wsudo
##------------------------------------------------------------------------------
install_wsudo() {
  cat> "$my_bin_path"/wsudo << 'EOF'
#!/bin/bash
# __my_script__

#small script to enable root access to x-windows system
xhost +SI:localuser:root
sudo $1
#disable root access after application terminates
xhost -SI:localuser:root
#print access status to allow verification that root access was removed
xhost
EOF
  displayandexec "Installation du script wsudo                        " "\
  chmod +x "$my_bin_path"/wsudo"
}
################################################################################

################################################################################
## install du script launch_url_file
##------------------------------------------------------------------------------
install_launch_url_file() {
  cat> "$my_bin_path"/launch_url_file << 'EOF'
#!/bin/bash
# __my_script__

chromium "$(tail -n 1 "$@" | cut -c 5-)"
EOF
  displayandexec "Installation du script launch_url_file              " "\
  chmod +x "$my_bin_path"/launch_url_file"
  cat> /usr/share/applications/launch_url_file.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=launch_url_file
Comment=script de lancement des fichiers URL depuis nautilus
Icon=chromium
Exec=$my_bin_path/launch_url_file
Categories=FileTools;
EOF
}
# création du fichier launch_url_file.desktop qui permet d'utiliser le script launch_url_file comme une application
################################################################################

################################################################################
## install du script scanmyhome
##------------------------------------------------------------------------------
install_scanmyhome() {
  cat> "$my_bin_path"/scanmyhome << 'EOF'
#!/bin/bash
# __my_script__

clamscan --recursive --infected /home/
EOF
  displayandexec "Installation du script scanmyhome                   " "\
  chmod +x "$my_bin_path"/scanmyhome"
}
################################################################################

################################################################################
## install du script rktscan
##------------------------------------------------------------------------------
install_rktscan() {
  cat> "$my_bin_path"/rktscan << 'EOF'
#!/bin/bash
# __my_script__

# echo "scan de rootkit avec rkhunter"
# sudo rkhunter --checkall --report-warnings-only
# echo "--------------------------------------------------------------------------------"
echo "scan de rootkit avec chkrootkit"
sudo chkrootkit -q
echo "--------------------------------------------------------------------------------"
EOF
  displayandexec "Installation du script rktscan                      " "\
  chmod +x "$my_bin_path"/rktscan"
}
################################################################################

################################################################################
## install du script spyme
##------------------------------------------------------------------------------
install_spyme() {
  cat> "$my_bin_path"/spyme << 'EOF'
# __my_script__

sudo bash -c "journalctl --no-hostname --all --no-pager --follow --lines=10000 _TRANSPORT=syslog + _TRANSPORT=kernel + _TRANSPORT=journal + _TRANSPORT=stdout | lnav"
EOF
  displayandexec "Installation du script spyme                        " "\
  chmod +x "$my_bin_path"/spyme"
}
################################################################################

################################################################################
## install du script check_domain_creation_date
##------------------------------------------------------------------------------
install_check_domain_creation_date() {
  cat> "$my_bin_path"/check_domain_creation_date << 'EOF'
#!/bin/bash
# __my_script__

check_if_domain_exist() {
  if $(whois "$1" | grep 'No entries found' >/dev/null); then
    echo "Le domaine "$1" n'existe pas."
    exit 1
  fi
}
check_if_domain_exist "$1"

domain_creation_date="$(whois "$1" | grep -Po -m 1 '(Creation Date:[[:space:]])\K([[:digit:]]+-[[:digit:]]+-[[:digit:]]+)')"

if [[ -z "$domain_creation_date" ]]; then
	domain_creation_date="$(whois "$1" | grep -Po -m 1 '(created:[[:space:]]+)\K([[:digit:]]+-[[:digit:]]+-[[:digit:]]+)')"
  if [[ -z "$domain_creation_date" ]]; then
  	exit 1
  fi
fi

domain_creation_date_at_timestamp="$(date -d "$domain_creation_date" +%s)"

two_months_in_timestamp='5184000'
# ref : [Timestamp list (recent dates, upcoming dates, months, years)](https://www.epochconverter.com/timestamp-list)

now_at_timestamp="$(date +%s)"
now_min_2_months=$(( $now_at_timestamp - $two_months_in_timestamp ))

if (( "$domain_creation_date_at_timestamp" > "$now_min_2_months" )); then
  echo "Ce domaine est suspect !"
  echo "Le domaine "$1" a été enregistré il y a moins de deux mois ("$domain_creation_date")."
else
  echo "Le domaine "$1" a été enregistré il y a plus de deux mois ("$domain_creation_date")."
fi

exit $?
EOF
  displayandexec "Installation du script check_domain_creation_date   " "\
  chmod +x "$my_bin_path"/check_domain_creation_date"
}
################################################################################

################################################################################
## install du script appairmebt
##------------------------------------------------------------------------------
install_appairmebt() {
  cat> "$my_bin_path"/appairmebt << 'EOF'
#!/bin/bash
# __my_script__

gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "<false>" >/dev/null
bluetoothctl select AA:AA:AA:AA:AA:AA >/dev/null
bluetoothctl power on >/dev/null
bluetoothctl trust BB:BB:BB:BB:BB:BB >/dev/null
bluetoothctl connect BB:BB:BB:BB:BB:BB >/dev/null
EOF
  displayandexec "Installation du script appairmebt                   " "\
  chmod +x "$my_bin_path"/appairmebt"
}
# script permettant de démarrer le bluetooth et d’appairer automatiquement avec le périphérique qu'on souhaite
#
# changer AA:AA:AA:AA:AA:AA par l'adress MAC du périphérique bluetooth du PC
# changer BB:BB:BB:BB:BB:BB par l'adress MAC du périphérique bluetooth de l'éléments qu'on veut connecter automatiquement
#
# Normalement nous devons utiliser rfkill pour ré-autoriser l'activation du bluetooth, mais celui-ci demande des permissions root. Cela donnerais alors la commande suivante :
# sudo rfkill unblock bluetooth && bluetoothctl select AA:AA:AA:AA:AA:AA && bluetoothctl power on && bluetoothctl trust BB:BB:BB:BB:BB:BB && bluetoothctl connect BB:BB:BB:BB:BB:BB
#
# Pour obtenir l'adresse MAC du périphérique bluetooth du PC :
# bluetoothctl show | awk '/Controller/ {print $2}'
#
# Pour éteindre le bluetooth de la même façon que lorsqu'on met le bouton à Off dans les Gnome Settings :
# gdbus call \
#     --session \
#     --dest org.gnome.SettingsDaemon.Rfkill \
#     --object-path /org/gnome/SettingsDaemon/Rfkill \
#     --method org.freedesktop.DBus.Properties.Set \
#     "org.gnome.SettingsDaemon.Rfkill" \
#     "BluetoothAirplaneMode" \
#     "<true>"
#
# Pour allumer le bluetooth de la même façon que lorsqu'on met le bouton à On dans les Gnome Settings :
# gdbus call \
#     --session \
#     --dest org.gnome.SettingsDaemon.Rfkill \
#     --object-path /org/gnome/SettingsDaemon/Rfkill \
#     --method org.freedesktop.DBus.Properties.Set \
#     "org.gnome.SettingsDaemon.Rfkill" \
#     "BluetoothAirplaneMode" \
#     "<false>"
#
# Pour obtenir les infos avec gdbus:
# gdbus introspect --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill
#
# ref : [plugins/rfkill/gsd-rfkill-manager.c · master · GNOME / gnome-settings-daemon · GitLab](https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/blob/master/plugins/rfkill/gsd-rfkill-manager.c)
#
#
# autre solution à considérer qui permet d'autoriser la commande rfkill pour les users:
# ref : https://gitlab.gnome.org/didrocks/gnome-settings-daemon/-/blob/75551e6b5f50aa9f0b7a0ce54fcc7a7ee204c93f/plugins/rfkill/61-gnome-settings-daemon-rfkill.rules
# ref : /usr/lib/udev/rules.d/61-gnome-settings-daemon-rfkill.rules
# cat> /etc/udev/rules.d/61-gnome-settings-daemon-rfkill.rules << 'EOF'
# Get access to /dev/rfkill for users
# See https://bugzilla.redhat.com/show_bug.cgi?id=514798
#
# Simplified by Kay Sievers
# https://bugzilla.redhat.com/show_bug.cgi?id=733326
# See also https://bugzilla.gnome.org/show_bug.cgi?id=711373
#
# KERNEL=="rfkill", SUBSYSTEM=="misc", TAG+="uaccess"
# EOF
# #and then reload the rules :
# udevadm control --reload-rules

# il semblerait qu'il faille d'abord faire une première commande qui scann les devices dispos avant de pouvoir appairer le device
# Il faudrait donc executer la commande : bluetoothctl scan on
# et ensuite seulement on peut executer appairmebt
################################################################################

################################################################################
## install du script desactivebt
##------------------------------------------------------------------------------
install_desactivebt() {
  cat> "$my_bin_path"/desactivebt << 'EOF'
#!/bin/bash
# __my_script__

gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "<true>" >/dev/null
EOF
  displayandexec "Installation du script desactivebt                  " "\
  chmod +x "$my_bin_path"/desactivebt"
}
################################################################################

################################################################################
## install du script play_pause_chromium
##------------------------------------------------------------------------------
install_play_pause_chromium() {
  cat> "$my_bin_path"/play_pause_chromium << 'EOF'
#!/bin/bash
# __my_script__

dbus_dest_org="$(dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | awk '/org.mpris.MediaPlayer2.chromium/{gsub(/\"/,"");print $2}')" && \
dbus-send --print-reply --dest="$dbus_dest_org" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause >/dev/null
EOF
  displayandexec "Installation du script play_pause_chromium          " "\
  chmod +x "$my_bin_path"/play_pause_chromium"
}
################################################################################

################################################################################
## install du script decomp
##------------------------------------------------------------------------------
install_decomp() {
  cat> "$my_bin_path"/decomp << 'EOF'
#!/bin/bash
# __my_script__

if [ -f $1 ]; then
  case $1 in
    *.tar.bz2)   tar xjf $1 ;;
    *.tar.gz)    tar xzf $1 ;;
    *.tar.xz)    tar xf $1 ;;
    *.bz2)       bunzip2 $1 ;;
    *.rar)       unrar x $1 ;;
    *.gz)        gunzip $1 ;;
    *.tar)       tar xf $1 ;;
    *.tbz2)      tar xjf $1 ;;
    *.tgz)       tar xzf $1 ;;
    *.xz)        xz --decompress $1 ;;
    *.zip)       unzip $1 ;;
    *.Z)         uncompress $1 ;;
    *.7z)        7z x $1 ;;
    *.msi)       msiextract $1 ;;
    *)           echo "'$1' can not be extracted by decomp()" ;;
  esac
else
  echo "'$1' invalid file"
fi
EOF
  displayandexec "Installation du script decomp                       " "\
  chmod +x "$my_bin_path"/decomp"
}
################################################################################

################################################################################
## install du script waitforssh
##------------------------------------------------------------------------------
install_waitforssh() {
  cat> "$my_bin_path"/waitforssh << 'EOF'
#!/bin/bash
# __my_script__

ssh_target="$1"
ssh_port="$2"
until ssh -o ConnectTimeout=2 -p "$ssh_port" "$ssh_target" 2>/dev/null; do
  echo -n '.'
  sleep 3
done
EOF
  displayandexec "Installation du script waitforssh                   " "\
  chmod +x "$my_bin_path"/waitforssh"
}
################################################################################

install_all_perso_script() {
  install_sysupdate
  install_check_backport_update
  install_wsudo
  install_launch_url_file
  install_scanmyhome
  install_rktscan
  install_spyme
  install_check_domain_creation_date
  install_appairmebt
  install_desactivebt
  install_play_pause_chromium
  install_decomp
  install_waitforssh
}
install_all_perso_script
################################################################################

#//////////////////////////////////////////////////////////////////////////////#
#                              CONFIGURATION                                   #
#//////////////////////////////////////////////////////////////////////////////#
echo ''
echo '     ################################################################'
echo '     #             CONFIGURATION DES DIFFERENTS ELEMENTS            #'
echo '     ################################################################'
echo ''

# exec_graphic_app_with_root_privileges "wireshark"
# exec_graphic_app_with_user_privileges "ghb"
# exec_graphic_app_with_user_privileges "/usr/share/code/code"
# exec_graphic_app_with_user_privileges "$(grep -Po '(^Exec=)\K.*' /usr/share/applications/geeqie.desktop)"

################################################################################
## configuration de SSH
##------------------------------------------------------------------------------
# si jamais le port SSH n'est pas défini préalablement, on en choisit un au hasard dans le range 4096-65000
if [ -z "$SSH_Port" ]; then
  SSH_Port="$(shuf -i 4096-65000 -n 1)"
fi

# on change le port par défaut
configure_ssh() {
  displayandexec "Configuration de ssh                                " "\
  sed -i -E 's/^(#)?Port [[:digit:]]+/Port '"$SSH_Port"'/' /etc/ssh/sshd_config && \
  sed -i -E 's/^(#)?PermitRootLogin (yes|no|without-password|prohibit-password)/PermitRootLogin no/' /etc/ssh/sshd_config"
  cat>> /etc/ssh/sshd_config << EOF

# "Disables all forwarding features, including X11, ssh-agent(1), TCP and StreamLocal. This option overrides all other forwarding-related options and may simplify restricted configurations."
# ref : https://manpages.debian.org/unstable/openssh-server/sshd_config.5.en.html#DisableForwarding
DisableForwarding yes

# only allow this user ($local_user) to connect to SSH
AllowUsers $local_user
EOF
}
configure_ssh
# sed -E -i '/(^#PermitRootLogin|^PermitRootLogin) (yes|no|without-password|prohibit-password)/{s/yes/no/;t;s/without-password/no/;t;s/prohibit-password/no/;}' /etc/ssh/sshd_config && \
# sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
# (^#PermitRootLogin|^PermitRootLogin) : permet d'identifier que le ligne commence par #PermitRootLogin ou qu'elle commence par PermitRootLogin, uniquement
# (yes|no|without-password|prohibit-password) : permet de donner les quatre possibilités différentes de valeur pour PermitRootLogin, à savoir yes, no, without-password, prohibit-password
# {s/yes/no/;t;s/without-password/no/;t;s/prohibit-password/no/;} : permet de remplacer yes par no , without-password par no ainsi que prohibit-password par no
# sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' : permet de décommenter la ligne si celle si l'était
# voici une autre commande moins complexe qui fait le job
# sed -E -i 's/(^#PermitRootLogin|^PermitRootLogin).*/PermitRootLogin no/' /etc/ssh/sshd_config
# Pour autoriser root sur Kali :
# sed -E -i '/(^#PermitRootLogin|^PermitRootLogin) (yes|no|without-password|prohibit-password)/{s/no/yes/;t;s/without-password/yes/;t;s/prohibit-password/yes/;}' /etc/ssh/sshd_config && sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
################################################################################

################################################################################
## configuration de SSHFS
##------------------------------------------------------------------------------
# création du répertoire qui servira de point de montage pour SSHFS
# on le créer dans /home/"$local_user"/.mnt/sshfs/ car cela permet de lire et écrire sans élévation de privilège lors de l'execution de la session SSHFS
configure_sshfs() {
  displayandexec "Configuration de sshfs                              " "\
  is_dir_present_or_mkdir_as_user "/home/"$local_user"/.mnt/sshfs/""
}
configure_sshfs
################################################################################

################################################################################
## configuration d'un répertoire pour monter des loop_device
##------------------------------------------------------------------------------
# création du répertoire qui servira de point de montage pour des loop device
# on le créer dans /home/"$local_user"/.mnt/loop_device/ car cela permet de lire et écrire sans élévation de privilège lors de l'execution du mount
configure_loop_device_mount_dir() {
  displayandexec "Configuration d'un répertoire pour mount loop_device" "\
  is_dir_present_or_mkdir_as_user "/home/"$local_user"/.mnt/loop_device/""
}
configure_loop_device_mount_dir
################################################################################

################################################################################
## configuration du logrotate pour le auth.log
##------------------------------------------------------------------------------
configure_logrotate_auth_log() {
  execandlog "sed -i '\/var\/log\/auth\.log/d' /etc/logrotate.d/rsyslog"
  cat>> /etc/logrotate.d/rsyslog << 'EOF'
/var/log/auth.log
{
  monthly
	rotate 12
	missingok
	notifempty
	compress
	delaycompress
	sharedscripts
	postrotate
		/usr/lib/rsyslog/rsyslog-rotate
	endscript
}
EOF
}
if [ "$bullseye" == 1 ]; then
  configure_logrotate_auth_log
fi
# cette conf permet de garder 12 mois de log de auth.log. Cela permet donc de garder pendant un an toutes les commandes utilisées (par root ou à travers sudo) ainsi que toutes les connexions d'utilisateur
################################################################################

################################################################################
## configuration du logrotate
##------------------------------------------------------------------------------
# on augmente la rétention des logs à 8 semaines
# par défaut elle est à 4 (debian bullseye)
configure_logrotate() {
  displayandexec "Configuration de logrotate                          " "\
  sed -E -i 's/^# keep [[:digit:]]+ weeks worth of backlogs/# keep 8 weeks worth of backlogs/' /etc/logrotate.conf && \
  sed -E -i 's/^rotate [[:digit:]]+/rotate 8/' /etc/logrotate.conf"
}
if [ "$bullseye" == 1 ]; then
  configure_logrotate
fi
################################################################################

################################################################################
## configuration des règles auditd
##------------------------------------------------------------------------------
configure_auditd_rules() {
  displayandexec "Configuration des règles auditd                     " "\
  is_file_present_and_rmfile "/etc/audit/rules.d/audit.rules" && \
  cp "$script_path"/audit.rules /etc/audit/rules.d/audit.rules && \
  augenrules --check && \
  systemctl restart auditd"
}
configure_auditd_rules
# rules mostly based on https://github.com/Neo23x0/auditd/blob/master/audit.rules
# les règles vont être générées (lors du restart) à l'aide de augenrules et seront ensuite dans le fichier /etc/audit/audit.rules
################################################################################

################################################################################
## configuration du service auditd
##------------------------------------------------------------------------------
configure_auditd() {
  displayandexec "Configuration de auditd                             " "\
  sed -E -i 's/^space_left = [[:digit:]]+/space_left = 20%/' /etc/audit/auditd.conf && \
  sed -E -i 's/^max_log_file = [[:digit:]]+/max_log_file = 10/' /etc/audit/auditd.conf && \
  sed -E -i 's/^num_logs = [[:digit:]]+/num_logs = 50/' /etc/audit/auditd.conf && \
  systemctl restart auditd"
}
configure_auditd
# ref : [7.3. Configuring the audit Service Red Hat Enterprise Linux 7 | Red Hat Customer Portal](https://access.redhat.com/documentation/fr-fr/red_hat_enterprise_linux/7/html/security_guide/sec-configuring_the_audit_service#:~:text=from%20being%20overwritten.-,space_left,-Specifies%20the%20amount)
################################################################################

################################################################################
## configuration de /etc/inputrc
##------------------------------------------------------------------------------
configure_etc_inputrc() {
  execandlog "sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc"
}
configure_etc_inputrc
# # do not bell on tab-completion
################################################################################

################################################################################
## configuration de wlfreerdp
##------------------------------------------------------------------------------
configure_wlfreerdp() {
  execandlog "ln -s /usr/bin/wlfreerdp3 /usr/bin/wlfreerdp"
}
configure_wlfreerdp
# suite au passage de debian du paquet freerdp2-wayland à freerdp3-wayland, ils se sont amuser à changer le nom du binaire de freerdp pour wayland, ça doit surement être parceque dans Bookworm, il existe en même temps les paquets freerdp2-wayland et freerdp3-wayland
# à prori c'est aussi lié à des breaking change dans la syntaxe des options de la commande wlfreerdp avec freerdp3-wayland
# pour éviter d'avoir à modifier mes scripts et mes commandes dans mon joplin, on créer le lien symbolique pour permettre d'utiliser l'ancien nom du binaire
# à noter qu'il semblerait que freerdp3-wayland soit déjà deprecated et qu'il faille utiliser sdl-freerdp3, mais dans le même temps le paquet sdl-freerdp3 est noté en experimental, donc pour le moment on va continuer d'utiliser freerdp3-wayland tout en installant sdl-freerdp3, quand on jugera que c'est le bon moment, on changera le symlink pour sdl-freerdp3
# ref : [[client] add deprecation/experimental warnings · FreeRDP/FreeRDP@8af35bd](https://github.com/FreeRDP/FreeRDP/commit/8af35bd42ab42acac542a5e290ffb779a0ed521a)
# [Deprecation warn by akallabeth · Pull Request #8732 · FreeRDP/FreeRDP](https://github.com/FreeRDP/FreeRDP/pull/8732)
################################################################################

################################################################################
## configuration de freshclam (clamav)
##------------------------------------------------------------------------------
configure_freshclam() {
  displayandexec "Configuration de freshclam                          " "\
  sed -E -i 's/^Checks [[:digit:]]+/Checks 1/' /etc/clamav/freshclam.conf"
}
configure_freshclam
# Check for new database 1 times a day (insteed of 24)
# les logs de freshclam sont dans /var/log/clamav/freshclam.log
# c'est le service clamav-freshclam qui fait tourner freshclam

# La config de freshclam pourrait aussi être gérée depuis la bdd de debconf car le script de postinstall de freshclam s'appuis sur cette bdd pour retrouver les valeurs s'il elles sont présentent pour mettre en place la configuration.
# Pour faire la même chose que mon sed dans le fichier de conf, il faudrait faire avant d'installer freshclam :
# echo 'clamav-freshclam	clamav-freshclam/update_interval	string	1' | debconf-set-selections

# ref : [File: clamav-freshclam.postinst.in | Debian Sources](https://sources.debian.org/src/clamav/1.0.3%2Bdfsg-1~deb12u1/debian/clamav-freshclam.postinst.in/) :
# ```bash
#   if [ "$runas" = "ifup.d" ] || [ "$runas" = "daemon" ] || [ "$runas" = "cron" ]; then
#     db_get clamav-freshclam/update_interval || true
#     if [ "$RET" != "" ]; then
#       if [ "$runas" != "cron" ]; then
#         checks="$RET"
# . . .
#   if [ "$runas" != "cron" ] || [ "$runas" != "manual" ]; then
#     if [ -n "$checks" ] && [ "$checks" != "true" ]; then
#       echo "# Check for new database $checks times a day" >> $DEBCONFFILE
#       echo "Checks $checks" >> $DEBCONFFILE
# ```
################################################################################

################################################################################
## configuration de wireshark
##------------------------------------------------------------------------------
configure_wireshark() {
  local conf_wireshark_tls_sni='	"TLS_SNI", "%Cus:tls.handshake.extensions_server_name:0:R"' && \
  is_file_present "/root/.config/wireshark/preferences" && \
  if ! sed -n '/^gui.column.format:/,/^$/p' /root/.config/wireshark/preferences | grep -q "$conf_wireshark_tls_sni" 2>/dev/null
    then sed -i '/^gui.column.format:/,/^$/{s/\"$/\",/;s/^$/'"$conf_wireshark_tls_sni"'\n/}' /root/.config/wireshark/preferences
  fi
  local conf_wireshark_dst_port='	"Destination Port", "%D"' && \
  is_file_present "/root/.config/wireshark/preferences" && \
  if ! sed -n '/^gui.column.format:/,/^$/p' /root/.config/wireshark/preferences | grep -q "$conf_wireshark_tls_sni" 2>/dev/null
    then sed -i '/^gui.column.format:/,/^$/{s/\"$/\",/;s/^$/'"$conf_wireshark_dst_port"'\n/}' /root/.config/wireshark/preferences
  fi
}
configure_wireshark
# on ajoute les colonnes "TLS_SNI" et "Destination Port" dans l'affichage principal de wireshark car elles sont très pratique lors de l'utilisation de wireshark.

# Le fichier n'existe pas avant d'avoir été dans  Edit → Preferences…​ (Wireshark → Preferences…) et d'avoir quitter la fenêtre avec OK.
# C'est à dire qu'il n'est pas créer simplement en lançant wireshark en graphique

# par défaut, il y a ce contenu dans la configuration de base de wireshark :
# gui.column.format:
# 	"No.", "%m",
# 	"Time", "%t",
# 	"Source", "%s",
# 	"Destination", "%d",
# 	"Protocol", "%p",
# 	"Length", "%L"
################################################################################

################################################################################
## configuration de Etcher
##------------------------------------------------------------------------------
configure_etcher() {
  displayandexec "Configuration de etcher                             " "\
  reset_dir_as_user "/home/"$local_user"/.config/balena-etcher-electron/""
  $ExeAsUser cat> /home/"$local_user"/.config/balena-etcher-electron/config.json << 'EOF'
{
  "errorReporting": false,
  "updatesEnabled": false,
  "desktopNotifications": true,
  "autoBlockmapping": true,
  "decompressFirst": true
}
EOF
}
configure_etcher
################################################################################

################################################################################
## configuration de rkhunter
##------------------------------------------------------------------------------
# suite aux infos de ce site : https://forum.cabane-libre.org/topic/239/invalid-web_cmd-configuration-option-relative-pathname-bin-false
configure_rkhunter() {
  displayandexec "Configuration de rkhunter                           " "\
  sed -i 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf && \
  sed -i 's/MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf && \
  sed -i 's%WEB_CMD=\"/bin/false\"%WEB_CMD=""%' /etc/rkhunter.conf"
}
# configure_rkhunter
################################################################################

################################################################################
## configuration des fichiers template
##------------------------------------------------------------------------------
# create_template_for_new_file() {
#   is_dir_present "/home/"$local_user"/Modèles" && template_dir="/home/"$local_user"/Modèles"
#   is_dir_present "/home/"$local_user"/Templates" && template_dir="/home/"$local_user"/Templates"
#   $ExeAsUser touch ""$template_dir"/Fichier Texte.txt" && \
#   $ExeAsUser touch ""$template_dir"/Document ODT.txt" && \
#   $ExeAsUser unoconv -f odt ""$template_dir"/Document ODT.txt" && \
#   rm -f ""$template_dir"/Document ODT.txt" && \
#   $ExeAsUser touch ""$template_dir"/Document ODS.txt" && \
#   $ExeAsUser unoconv -f ods ""$template_dir"/Document ODS.txt" && \
#   rm -f ""$template_dir"/Document ODS.txt"
# # ref : https://ask.libreoffice.org/en/question/153444/how-to-create-empty-libreoffice-file-in-a-current-directory-on-the-command-line/
# # Pour voir tous les formats supportés par unoconv : unoconv --show
# }
# # create_template_for_new_file
# if [ "$bullseye" == 1 ]; then
#   create_template_for_new_file
# fi
# unoconv is deprecated, ref : [#1076522 - unoconv: Broken with Python 3.12 because of usage of distutils - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1076522)

# create_template_for_new_file_new() {
# ref : https://ask.libreoffice.org/en/question/153444/how-to-create-empty-libreoffice-file-in-a-current-directory-on-the-command-line/
# Pour voir tous les formats supportés par unoconv : unoconv --show
# }
# if [ "$bookworm" == 1 ]; then
  # create_template_for_new_file_new
# fi

# le fait que la première execution fail à créer le fichier mais ne produise pas de code d'érreur pourrait venir du fait que le répertoire des config de librroffice n'existe pas encore avant la première execution de la commande, et que il quitte son execution mais en construisant le repertoire de config ce qui permet à la deuxième commande de s'executer correctement
# ref : [ms office - unoconv not working while trying to convert. throws Error: Unable to connect or start own listener. Aborting - Stack Overflow](https://stackoverflow.com/questions/9259975/unoconv-not-working-while-trying-to-convert-throws-error-unable-to-connect-or/28611685#28611685)
# si c'est bien le cas, on devrait voir la création du template s'inverser maintenant qu"on a changé l'ordre de création du template (avant = 1:ODT 2:ODS; maintenant = 1:ODS 2:ODT), donc à priori c'est le fichier .odt qui devrait être fait
# [linux - Libreoffice --headless refuses to convert unless root, won't work from PHP script - Stack Overflow](https://stackoverflow.com/questions/12101855/libreoffice-headless-refuses-to-convert-unless-root-wont-work-from-php-scrip)
# [Error in function createSettingsDocument (elements.cxx) when using a libreoffice command - Ask Ubuntu](https://askubuntu.com/questions/678125/error-in-function-createsettingsdocument-elements-cxx-when-using-a-libreoffice/1092715#1092715)

tmp_test_configure_libreoffice_template() {
  is_dir_present "/home/"$local_user"/Modèles" && template_dir="/home/"$local_user"/Modèles"
  is_dir_present "/home/"$local_user"/Templates" && template_dir="/home/"$local_user"/Templates"
  $ExeAsUser touch ""$template_dir"/Fichier Texte.txt"

  # $ExeAsUser touch ""$template_dir"/Document ODT.txt" && \
  # $ExeAsUser "$(realpath $(command -v libreoffice))".bin --nologo --nofirststartwizard --invisible --norestore --headless --convert-to odt ""$template_dir"/Document ODT.txt" --outdir "$template_dir" && \
  # rm -f ""$template_dir"/Document ODT.txt"

  # initialise /home/"$local_user"/.config/libreoffice/
  $ExeAsUser timeout \
  --signal=TERM \
  --kill-after=25s 20s \
  "$(realpath $(command -v libreoffice))".bin \
  --nologo \
  --nofirststartwizard \
  --invisible \
  --norestore \
  --headless

  $ExeAsUser touch ""$template_dir"/Document ODS.txt" && \
  $ExeAsUser timeout \
  --signal=TERM \
  --kill-after=25s 20s \
  "$(realpath $(command -v libreoffice))".bin \
  --calc \
  --nologo \
  --nofirststartwizard \
  --invisible \
  --norestore \
  --headless \
  --convert-to ods ""$template_dir"/Document ODS.txt" \
  --outdir "$template_dir" && \
  rm -f ""$template_dir"/Document ODS.txt"

  $ExeAsUser touch ""$template_dir"/Document ODT.txt" && \
  $ExeAsUser timeout \
  --signal=TERM \
  --kill-after=25s 20s \
  "$(realpath $(command -v libreoffice))".bin \
  --nologo \
  --nofirststartwizard \
  --invisible \
  --norestore \
  --headless \
  --convert-to odt ""$template_dir"/Document ODT.txt" \
  --outdir "$template_dir" && \
  rm -f ""$template_dir"/Document ODT.txt"
}
export -f tmp_test_configure_libreoffice_template

displayandexec "Configuration des templates libreoffice             " "\
  tmp_test_configure_libreoffice_template"

# On est obliger d'utiliser "$(realpath $(command -v libreoffice))".bin à la place de "libreoffice", c'est à dire le binaire soffice et non le script de lancement produit par Debian, car sinon on obtiens cette érreur lorsqu'on tente de lancer la commande via sudo -u "$local_user" :
# /usr/bin/libreoffice: 56: cd: can't cd to /root

# cette fonction permet d'obtenir dans le clique droit de nautilus l'accès à "Nouveau Document -> Ficher Texte"
################################################################################

################################################################################
## configuration de Libreoffice
##------------------------------------------------------------------------------
configure_libreoffice() {
  # conf de Libreoffice
  execandlog "sed -i --follow-symlinks '/^export LC_ALL/a export GTK_THEME=Adwaita' /usr/bin/libreoffice"
  #if you want to use this in a .desktop file, you have to prepend 'env' for setting the env variable. I.e. copy the libreoffice-*.desktop files from /usr/share/applications to ~.local/share/applications, then open them in a text editor and change the line saying 'Exec' so it looks like this:
  # Exec=env GTK_THEME=Adwaita:light libreoffice --writer

  # disable java settings in LibreOffice
  # $ExeAsUser sed -i 's%<enabled xsi:nil="false">true</enabled>%<enabled xsi:nil="false">false</enabled>%g' /home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml
  # il faut potentiellement le mettre comme ça :
  is_file_present "/home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml" && \
  $ExeAsUser sed -i 's%<enabled xsi:nil=".*>$%<enabled xsi:nil="false">false</enabled>%g' /home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml

  # ref : https://ask.libreoffice.org/en/question/167622/how-to-disable-java-in-configuration-files/
  # Pour aider à chercher les fichiers concernés par la modification de la configuration
  # find /home/$USER/.config/libreoffice/ -type f -mmin -5 -exec grep -l "java" {} \; && find /usr/lib/libreoffice/share/ -type f -mmin -5 -exec grep -l "java" {} \;
  # find /usr/lib/libreoffice/share/ -type f -mmin -5 -exec grep -i -l "autosave" {} \; && find /home/$USER/.config/libreoffice/ -type f -mmin -5 -exec grep -i -l "autosave" {} \;
  # find /usr/lib/libreoffice/share/ -type f -mmin -5 && find /home/$USER/.config/libreoffice/ -type f -mmin -5

  # Disable startup logo
  execandlog "sed -i 's/^Logo=1/Logo=0/' /etc/libreoffice/sofficerc"
  # ref : https://wiki.archlinux.org/title/LibreOffice#Disable_startup_logo

  # cette configuration n'existe pas dans le fichier après une install, il faut donc trouver le moyen de l'ajouter en insérant la ligne
  # Pour changer la valeur du niveau de sécurité des macros de Elevé à Très Elevé
  is_file_present "/home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu" && \
  $ExeAsUser sed -i 's%<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>2</value></prop></item>%<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>%g' /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu
  # rajouter || créer le contenu du fichier avec un cat EOF

  # Pour faire en sorte que l'autosave se fasse toute les 1 minute (à la place des 10 minutes par défaut)
  # grep -n -i autosave.*TimeIntervall /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu
  # il faudra changer la value de 10 à 1

  # Pour insérer la ligne lorsque le fichier existe :
  # sed -i '\%</oor:items>%i <item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>' /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu
}
configure_libreoffice
################################################################################

################################################################################
## configuration de nano
##------------------------------------------------------------------------------
# la configuration de nano s'effectue dans le fichier /etc/nanorc
configure_nano() {
  displayandexec "Configuration de nano                               " "\
  sed -i -E 's/^(#)?# set linenumbers/set linenumbers/' /etc/nanorc && \
  sed -i -E 's/^(#)?# set softwrap/set softwrap/' /etc/nanorc && \
  sed -i -E 's/^(#)?# set tabsize [[:digit:]]+/set tabsize 4/' /etc/nanorc"
}
configure_nano
################################################################################

################################################################################
## configuration de apt-fast
##------------------------------------------------------------------------------
configure_apt-fast() {
  cat>> /etc/apt-fast.conf << 'EOF'


# Verbose output
#
# Show aria2 download file instead of package listing before download confirmation.
# Unset to show package listing.
#
VERBOSE_OUTPUT=
EOF
}
configure_apt-fast
# On est obligé d'ajouter la conf pour désactiver le mode verbose de apt-fast car il semble qu'elle ne soit pas dispo dans la conf par défaut et qu'elle ne se configure pas non plus comme les autres éléments de config de apt-fast (avec debconf-set-selections)
# a vérifier si cette conf est ajouté dans les futurs release de apt-fast
################################################################################

################################################################################
## configuration de bat
##------------------------------------------------------------------------------
configure_bat() {
  displayandexec "Configuration de bat                                " "\
  is_file_present_and_rmfile "/home/"$local_user"/.config/bat/config" && \
  $ExeAsUser bat --generate-config-file"
  $ExeAsUser cat>> /home/"$local_user"/.config/bat/config << 'EOF'

--paging=never
--style=header-filename
EOF
}
configure_bat

configure_bat_root_user() {
  displayandexec "Configuration de bat pour l'utilisateur root        " "\
  is_file_present_and_rmfile "/root/.config/bat/config" && \
  bat --generate-config-file"
  cat>> /root/.config/bat/config << 'EOF'

--paging=never
--style=header-filename
EOF
}
configure_bat_root_user
# cette configuration permet de désactiver l'utilisation du pager ainsi que d'afficher le nom du fichier avant sa lecture
################################################################################

################################################################################
## configuration de cups-browsed
##------------------------------------------------------------------------------
configure_cups_browsed() {
  execandlog "systemctl mask --now cups-browsed"
}
configure_cups_browsed
# harden cups-browsed because of [Attacking UNIX Systems via CUPS, Part I](https://www.evilsocket.net/2024/09/26/Attacking-UNIX-systems-via-CUPS-Part-I/)
################################################################################

################################################################################
## configuration de Firefox
##------------------------------------------------------------------------------
# on ajoute la possibilité d'ouvrir directement la navigateur firefox dans une fenêtre de navigation privée
configure_firefox() {
  displayandexec "Configuration de Firefox                            " "\
  [ -f /usr/share/applications/firefox-esr-private.desktop ] || cp /usr/share/applications/firefox-esr.desktop /usr/share/applications/firefox-esr-private.desktop && \
  sed -i 's%^Exec=/usr/lib/firefox-esr/firefox-esr%& --private-window%' /usr/share/applications/firefox-esr-private.desktop && \
  sed -E -i '/(^Name=|^Name\[.*\]=)/s/Firefox .*/Firefox private/g' /usr/share/applications/firefox-esr-private.desktop && \
  sed -E -i '/(^X-GNOME-FullName=|^X-GNOME-FullName\[.*\]=)/s/Firefox ESR/Firefox private/g' /usr/share/applications/firefox-esr-private.desktop"
}
configure_firefox
################################################################################

################################################################################
## configuration de OpenSnitch
##------------------------------------------------------------------------------
configure_opensnitch() {
  execandlog "is_dir_present_or_mkdir_as_user "/home/"$local_user"/.config/opensnitch/""
  $ExeAsUser tee /home/"$local_user"/.config/opensnitch/settings.conf << 'EOF' >/dev/null
[General]
statsDialog=0

[database]
file=:memory:
max_days=1
purge_interval=5
purge_oldest=false
type=0

[global]
default_action=0
default_duration=6
default_ignore_rules=false
default_ignore_temporary_rules=0
default_popup_advanced=true
default_popup_advanced_dstip=true
default_popup_advanced_dstport=false
default_popup_advanced_uid=false
default_popup_position=0
default_target=0
default_timeout=15
disable_popups=false
hide_systray_warning=true
theme=dark_teal.xml

[notifications]
enabled=true
type=0

[promptDialog]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\r\xf2\0\0\x2O\0\0\xf\xf9\0\0\x3\xca\0\0\r\xf2\0\0\x2t\0\0\xf\xf9\0\0\x3\xca\0\0\0\0\0\0\0\0\xf\0\0\0\r\xf2\0\0\x2t\0\0\xf\xf9\0\0\x3\xca)

[statsDialog]
firewall_columns_state=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\f\x3\0\0\0\0\x2\0\0\0\x1\0\0\0\x64\0\0\0\0\0\0\0\x64\0\0\av\0\0\0\f\0\x1\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\f\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\
0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x1\xa4\0\0\0\x1\0\0\0\0\0\0\x1\x38\0\0\0\x1\0\0\0\0\0\0\x1\xde\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
general_columns_state=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\b\x82\0\0\0\x2\0\0\0\a\0\0\0\x64\0\0\0\x1\0\0\0\x64\0\0\b\x11\0\0\0\b\0\x1\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\b\0\0\0\xca\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x2\xb1\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x2\x65\0\0\0\x1\0\0\0\0\0\0\x1i\0\
0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\x1i)
general_filter_text=
general_limit_results=4
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\a\x7f\0\0\x4\x37\0\0\x16\xb4\0\0\x1\x66\0\0\x1dh\0\0\x4j\0\0\0\x3\x2\0\0\0\a\x80\0\0\0\0\0\0\0%\0\0\a\x7f\0\0\x4\x37)
last_tab=0
nodes_columns_state=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\av\0\0\0\n\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\n\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x88\0\0\0\x1\0\0\0\x3\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\
0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3\xce\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
rules_columns_state=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\aw\0\0\0\b\0\x1\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\b\0\0\0\xa4\0\0\0\x1\0\0\0\0\0\0\0\xc5\0\0\0\x1\0\0\0\0\0\0\x3%\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x1Y\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3
\xe8\0\0\0\x1Y)
rules_splitter_pos=@ByteArray(\0\0\0\xff\0\0\0\x1\0\0\0\x2\0\0\0\0\0\0\aR\x1\xff\xff\xff\xff\x1\0\0\0\x1\0)
rules_tree_0_expanded=false
rules_tree_1_expanded=false
show_columns=0, 2, 3, 4, 5, 6
view_columns_state2=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\xe\x93\0\0\0\a\0\x1\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\a\0\0\0\xa4\0\0\0\x1\0\0\0\0\0\0\0\xc5\0\0\0\x1\0\0\0\0\0\0\x3%\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\b\xd9\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\x1Y)
view_columns_state3=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\a!\0\0\0\x2\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\x2\0\0\0\xc0\0\0\0\x1\0\0\0\x3\0\0\x6\x61\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
view_columns_state4=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\xe\xb1\0\0\0\x2\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\x2\0\0\x1Y\0\0\0\x1\0\0\0\x3\0\0\rX\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
view_details_columns_state0=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\xc8\0\0\0\x2\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\x2\0\0\0\x64\0\0\0\x1\0\0\0\x3\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
view_details_columns_state2=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x10\xfd\0\0\0\n\0\x1\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\n\0\0\0\xa4\0\0\0\x1\0\0\0\0\0\0\0\xc5\0\0\0\x1\0\0\0\0\0\0\x3%\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x1Y\0\0\0\x1\0\0\0\0\0\0\x1\x31\0\0\0\x1\
0\0\0\0\0\0\bU\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\x1Q)
view_details_columns_state3=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\av\0\0\0\f\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\f\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0
\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3*\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
view_details_columns_state4=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x12\xd2\0\0\0\r\0\x1\x1\x1\0\0\0\0\0\0\0\0\x1\0\0\0\x64\xff\xff\xff\xff\0\0\0\x84\0\0\0\0\0\0\0\r\0\0\0\xb3\0\0\0\x1\0\0\0\x3\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0|\0\0\0\x1\0\0\0\0\0\0\x1\xef\0\0\0\
x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x1\xd3\0\0\0\x1\0\0\0\0\0\0\x6\xd8\0\0\0\x1\0\0\0\0\0\0\x4M\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64)
EOF
  execandlog "reset_dir "/opt/opensnitch/allow_list/vscode/domains/""
  cat> /opt/opensnitch/allow_list/vscode/domains/vscode.domains << 'EOF'
# ref : [Setup Visual Studio Code's Network Connection](https://code.visualstudio.com/docs/setup/network)
# Visual Studio Marketplace
0.0.0.0 marketplace.visualstudio.com
# Visual Studio Code download CDN
0.0.0.0 az764295.vo.msecnd.net
# GitHub repository raw file access
0.0.0.0 raw.githubusercontent.com
# Github repository
0.0.0.0 github.com
# Github API
0.0.0.0 api.github.com
# Used when logging in with GitHub or Microsoft for an extension or Settings Sync
0.0.0.0 vscode.dev
EOF
  execandlog "reset_dir "/opt/opensnitch/allow_list/vscode/regexp/""
  cat> /opt/opensnitch/allow_list/vscode/regexp/vscode.regexp << 'EOF'
# ref : [Setup Visual Studio Code's Network Connection](https://code.visualstudio.com/docs/setup/network)
# Visual Studio Marketplace
.*.gallery.vsassets.io
# Visual Studio Marketplace
.*.gallerycdn.vsassets.io
EOF
  execandlog "reset_dir "/opt/opensnitch/allow_list/joplin_plugin/domains/""
cat> /opt/opensnitch/allow_list/joplin_plugin/domains/joplin_plugin.domains << 'EOF'
# Github repository raw file access
0.0.0.0 raw.githubusercontent.com
# Github repository
0.0.0.0 github.com
# Github API
0.0.0.0 api.github.com
# Github release
0.0.0.0 release-assets.githubusercontent.com
# Github Gist
0.0.0.0 gist.github.com
EOF
  execandlog "reset_dir "/opt/opensnitch/allow_list/signal-desktop/domains/""
cat> /opt/opensnitch/allow_list/signal-desktop/domains/signal-desktop.domains << 'EOF'
0.0.0.0 sfu.voip.signal.org
0.0.0.0 turn2.voip.signal.org
0.0.0.0 turn3.voip.signal.org
0.0.0.0 chat.signal.org
0.0.0.0 textsecure-service.whispersystems.org
0.0.0.0 storage.signal.org
0.0.0.0 cdn.signal.org
0.0.0.0 cdn2.signal.org
0.0.0.0 cdn3.signal.org
0.0.0.0 updates2.signal.org
0.0.0.0 uptime.signal.org
EOF
}
configure_opensnitch
################################################################################

################################################################################
## configuration de VSCode
##------------------------------------------------------------------------------
configure_vscode() {
  execandlog "is_dir_present_or_mkdir_as_user "/home/"$local_user"/.config/Code/User/""
  execandlog "$ExeAsUser code --force --install-extension akamud.vscode-theme-onedark"
  execandlog "$ExeAsUser code --force --install-extension redhat.vscode-yaml"
  execandlog "$ExeAsUser code --force --install-extension Y-Ysss.cisco-config-highlight"
  execandlog "$ExeAsUser code --force --install-extension pustelto.bracketeer"
  execandlog "$ExeAsUser code --force --install-extension mohsen1.prettify-json"
  execandlog "$ExeAsUser code --force --install-extension mrmlnc.vscode-apache"
  execandlog "$ExeAsUser code --force --install-extension vscode-nginx"
  execandlog "$ExeAsUser code --force --install-extension speedproxies.squid-syntax"
  execandlog "$ExeAsUser code --force --install-extension wholroyd.jinja"
  execandlog "$ExeAsUser code --force --install-extension marduc812.nmap-peek"
  execandlog "$ExeAsUser code --force --install-extension william-voyek.vscode-nginx"
  execandlog "$ExeAsUser code --force --install-extension yzhang.markdown-all-in-one"
  execandlog "$ExeAsUser code --force --install-extension dgenzer.suricata-highlight-vscode"
  $ExeAsUser tee /home/"$local_user"/.config/Code/User/settings.json << 'EOF' >/dev/null
{
    "workbench.colorTheme": "Atom One Dark",
    "update.mode": "none",
    "telemetry.telemetryLevel": "off",
    "security.workspace.trust.untrustedFiles": "open",
    "files.autoSave": "afterDelay",
    "editor.wordWrap": "on",
    "diffEditor.renderSideBySide": false,
    "git.confirmSync": false,
    "explorer.sortOrder": "modified",
    "workbench.startupEditor": "none",
    "diffEditor.diffAlgorithm": "advanced",
    "extensions.ignoreRecommendations": true,
    "update.showReleaseNotes": false
}
EOF
}
configure_vscode
# Pour installer des extensions en ligne de commande : [Managing Extensions in Visual Studio Code](https://code.visualstudio.com/docs/editor/extension-marketplace#_command-line-extension-management)
# code --install-extension <extension-id>
# code --install-extension redhat.ansible
# code --install-extension donjayamanne.githistory
# [Nmap Peek - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=marduc812.nmap-peek)
# installer cette extension : [Marp for VS Code - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)
# Pour lister les extensions utilisées : code --list-extensions

# on utilise le --force pour pouvoir mettre à jour l'extension si elle est déjà installée (utile notamment dans le cas d'une relance du script ng_install.sh)

# le répertoire /home/"$local_user"/.config/Code/ se créer uniquement après un premier lancement en graphique

  # execandlog "$ExeAsUser code --force --install-extension ms-vscode.PowerShell"
  # à vérifier si cette extension est vraiment nécessaire, à priori elle permet surtout de gérer l'execution et le debugage des scripts powershell (en gros plus utile sur un windows que sur un linux)
################################################################################

################################################################################
## configuration de mpv
##------------------------------------------------------------------------------
configure_mpv() {
  displayandexec "Configuration de mpv                                " "\
  reset_dir_as_user "/home/"$local_user"/.config/mpv/"" && \
  $ExeAsUser cat> /home/"$local_user"/.config/mpv/input.conf << 'EOF'
# Add the capacity to rotate the video when pressing r key
r cycle_values video-rotate 90 180 270 0

# Add zoom control with Alt+= and Alt+-
# ref : [Add new default keys to pan, zoom and rotate · Issue #5458 · mpv-player/mpv · GitHub](https://github.com/mpv-player/mpv/issues/5458)
Alt+- add video-zoom -0.10
Alt+= add video-zoom 0.10

Alt+left  add video-pan-x  0.01         # move the video right
Alt+right add video-pan-x -0.01         # move the video left
Alt+up    add video-pan-y  0.01         # move the video down
Alt+down  add video-pan-y -0.01         # move the video up
EOF
  $ExeAsUser cat> /home/"$local_user"/.config/mpv/mpv.conf << 'EOF'
# Enable hardware decoding if available
hwdec=auto
EOF
}
configure_mpv
# ref : [command line - Rotate video by a keyboard shortcut in mpv - Ask Ubuntu](https://askubuntu.com/questions/1212733/rotate-video-by-a-keyboard-shortcut-in-mpv/1345092#1345092)
# [Configuration file for `mpv`](https://gist.github.com/doole/af4613629d223eb0e416)
# [mpv.io](https://mpv.io/manual/stable/#options-hwdec)
################################################################################

################################################################################
## configuration de typora
##------------------------------------------------------------------------------
configure_typora() {
  displayandexec "Configuration de typora                             " "\
  reset_dir_as_user "/home/"$local_user"/.config/Typora/"" && \
  $ExeAsUser cat> /home/"$local_user"/.config/Typora/profile.data << 'EOF'
7b22696e697469616c697a655f766572223a22302e392e3738222c226c696e655f656e64696e675f63726c66223a66616c73652c227072654c696e65627265616b4f6e4578706f7274223a747275652c2275756964223a2237346265383439362d343239372d343362382d616633632d336439343463646432376439222c227374726963745f6d6f6465223a747275652c22636f70795f6d61726b646f776e5f62795f64656661756c74223a747275652c226261636b67726f756e64436f6c6f72223a2223333633423430222c227468656d65223a226e696768742e637373222c22736964656261725f746162223a22222c2273656e645f75736167655f696e666f223a66616c73652c22656e61626c654175746f53617665223a747275652c226c617374436c6f736564426f756e6473223a7b2266756c6c73637265656e223a66616c73652c226d6178696d697a6564223a747275657d7d
EOF
}
# la configuration des préférences de Typora ne peut se faire que graphiquement le seul moyen de contourner ce problème est de configurer graphiquement les préférences et de récupérer le contenu du fichier /home/$local_user/.config/Typora/profile.data
configure_typora
################################################################################

################################################################################
## configuration de Joplin
##------------------------------------------------------------------------------
# début de réflexion pour faire des confs sur des apps qui utilise une base de donnée pour stocker la conf
# apt-get install -y sqlite3 && sqlite3 .config/joplin-desktop/database.sqlite "select * from settings"
configure_joplin() {
  displayandexec "Configuration de joplin                             " "\
  is_dir_present_or_mkdir_as_user "/home/"$local_user"/.config/Joplin/""
# $ExeAsUser cat> /home/"$local_user"/.config/Joplin/Preferences << 'EOF'
# {"spellcheck":{"dictionaries":["fr"],"dictionary":""}}
# EOF
}
configure_joplin
################################################################################

################################################################################
## configuration de Handbrake
##------------------------------------------------------------------------------
configure_handbrake() {
  displayandexec "Configuration de handbrake                          " "\
  reset_dir_as_user "/home/"$local_user"/.config/ghb/" && \
  { [ -f /home/"$local_user"/.config/ghb/preferences.json ] && $ExeAsUser sed -E -i '/("UseM4v":) (false|true)/{s/true/false/;}' /home/"$local_user"/.config/ghb/preferences.json; } || true"
}
configure_handbrake
# permet de décocher la case "Utiliser l'extension de fichier compatible iPod/iTunes (.m4v) pour MP4" (Fichier -> Préférences -> Général)
# le fichier de conf n'existe pas tant que handbrake n'a pas été lancé
# donc il faut soit trouver un moyen de lancer handbrake silencieusement soit copier coller la conf entière dans le fichier directement
# et donc qu'il faille faire le sed qu'une fois que le fichier de configuration ne soit présent
################################################################################

################################################################################
## configuration de geeqie
##------------------------------------------------------------------------------
# On est obliger de créer le fichier de conf (/home/"$local_user"/.config/geeqie/geeqierc.xml) en lancant geeqie graphiquement et ensuite en allant dans Edit -> Preference -> cliquer sur OK
# Il semblerait que le fichier de conf se créer aussi lorsqu'on lance Geeqie et qu'on le quitte proprement (en appuyant sur la croix en haut de la fenêtre)
configure_geeqie() {
  if is_file_present "/home/"$local_user"/.config/geeqie/geeqierc.xml"; then
    $ExeAsUser sed -i -E 's/image.alpha_color_1 = "#[[:digit:]]+"/image.alpha_color_1 = "#FFFFFFFFFFFF"/' /home/"$local_user"/.config/geeqie/geeqierc.xml
    $ExeAsUser sed -i -E 's/image.alpha_color_2 = "#[[:digit:]]+"/image.alpha_color_2 = "#FFFFFFFFFFFF"/' /home/"$local_user"/.config/geeqie/geeqierc.xml

  # on désactive la capacité de geekie d'ouvrir des .pdf
    $ExeAsUser sed -i -E 's%<file_type key = "pdf" enabled = "true" extensions = ".pdf" description = "Portable Document Format" file_class = "6" writable = "false" allow_sidecar = "false" />%<file_type key = "pdf" enabled = "false" extensions = ".pdf" description = "Portable Document Format" file_class = "6" writable = "false" allow_sidecar = "false" />%' /home/"$local_user"/.config/geeqie/geeqierc.xml

  # on désactive la capacité de geekie d'ouvrir des fichiers compréssés
    $ExeAsUser sed -i -E 's%<file_type key = "zip" enabled = "true" extensions = ".zip;.rar;.tar;.tar.gz;.tar.bz2;.tar.xz;.tgz;.tbz;.txz;.cbr;.cbz;.gz;.bz2;.xz;.lzh;.lza;.7z" description = "Archive files" file_class = "7" writable = "false" allow_sidecar = "false" />%<file_type key = "zip" enabled = "false" extensions = ".zip;.rar;.tar;.tar.gz;.tar.bz2;.tar.xz;.tgz;.tbz;.txz;.cbr;.cbz;.gz;.bz2;.xz;.lzh;.lza;.7z" description = "Archive files" file_class = "7" writable = "false" allow_sidecar = "false" />%' /home/"$local_user"/.config/geeqie/geeqierc.xml
  # Pour voir les différents formats supportés par Geeqie : sed -n '/<filter>/,/<\/filter>/p' ~/.config/geeqie/geeqierc.xml

    $ExeAsUser sed -i 's/image.zoom_to_fit_allow_expand = "false"/image.zoom_to_fit_allow_expand = "true"/' /home/"$local_user"/.config/geeqie/geeqierc.xml

    $ExeAsUser sed -i 's/image.zoom_quality = "[[:digit:]]+"/image.zoom_quality = "3"/' /home/"$local_user"/.config/geeqie/geeqierc.xml
  fi
}
configure_geeqie
################################################################################

# ajout du dossier partagé pour VirtualBox
execandlog "is_dir_present_or_mkdir_as_user "/home/"$local_user"/dossier_partage_VM/""

# ajout du dossier autostart pour les apps qui se lance au démarage
execandlog "reset_dir_as_user "/home/"$local_user"/.config/autostart/""

################################################################################
## configuration des applis qui doivent se lancer au démarage
##------------------------------------------------------------------------------
#signal
# $ExeAsUser cat> /home/"$local_user"/.config/autostart/signal.desktop << 'EOF'
# [Desktop Entry]
# Name=Signal
# Comment=Private messaging from your desktop
# Exec="/opt/Signal/signal-desktop" %U
# Terminal=false
# Type=Application
# Icon=signal-desktop
# StartupWMClass=Signal
# Categories=Network;InstantMessaging;Chat;
# EOF
ln -s /usr/share/applications/signal-desktop.desktop /home/"$local_user"/.config/autostart/signal-desktop.disable_for_now
# on n'active pas le démarage automatique de Signal pour être sur qu'il n'y a pas de risques de créer des problèmes pour le re-import des données depuis l'ancienne install debian

#terminal
$ExeAsUser cat> /home/"$local_user"/.config/autostart/terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=lancement du terminal au démarage
Exec=gnome-terminal --maximize
Type=Application
Terminal=false
Hidden=false
EOF

#keepassxc
# $ExeAsUser cat> /home/"$local_user"/.config/autostart/keepassxc.desktop << EOF
# [Desktop Entry]
# Name=KeePassXC
# Comment=Password Manager
# Exec=$manual_install_dir/KeePassXC/KeePassXC-$keepassxc_version-x86_64.AppImage
# Type=Application
# Terminal=false
# Hidden=false
# EOF
ln -s /usr/share/applications/keepassxc.desktop /home/"$local_user"/.config/autostart/keepassxc.desktop


#joplin
# $ExeAsUser cat> /home/"$local_user"/.config/autostart/joplin.desktop << EOF
# [Desktop Entry]
# Name=Joplin
# Comment=Markdown Editor
# Exec=$manual_install_dir/Joplin/Joplin-$joplin_version.AppImage
# Type=Application
# Terminal=false
# Hidden=false
# EOF
ln -s /usr/share/applications/joplin.desktop /home/"$local_user"/.config/autostart/joplin.desktop

# on pourra surement supprimer la configuration manuel des .desktop pour joplin, signal et keepassxc en les remplaçant par des liens symboliques pointant vers les .desktop correspondant dans /usr/share/applications
################################################################################

################################################################################
## configuration de KeePassXC
##------------------------------------------------------------------------------
configure_keepassxc() {
  displayandexec "Configuration de KeePassXC                          " "\
  reset_dir_as_user "/home/"$local_user"/.config/keepassxc/""
  $ExeAsUser tee /home/"$local_user"/.config/keepassxc/keepassxc.ini << 'EOF' >/dev/null
[General]
AutoReloadOnChange=true
AutoSaveAfterEveryChange=true
AutoSaveOnExit=true
BackupBeforeSave=true
ConfigVersion=2
OpenPreviousDatabasesOnStartup=true
RememberLastDatabases=true
RememberLastKeyFiles=true
SingleInstance=true
UpdateCheckMessageShown=true
UseAtomicSaves=false

[Browser]
AllowExpiredCredentials=false
AlwaysAllowAccess=false
AlwaysAllowUpdate=false
BestMatchOnly=false
CustomProxyLocation=
Enabled=true
HttpAuthPermission=false
MatchUrlScheme=true
NoMigrationPrompt=false
SearchInAllDatabases=true
ShowNotification=true
SortByUsername=false
SupportBrowserProxy=true
SupportKphFields=true
UnlockDatabase=true
UpdateBinaryPath=false
UseCustomProxy=false

[FdoSecrets]
Enabled=false
NoConfirmDeleteItem=false
ShowNotification=true

[GUI]
AdvancedSettings=true
ApplicationTheme=dark
CheckForUpdates=false
CheckForUpdatesIncludeBetas=false
HidePasswords=true
HidePreviewPanel=false
HideToolbar=false
HideUsernames=false
Language=system
MinimizeOnClose=false
MinimizeOnStartup=false
MinimizeToTray=false
MonospaceNotes=false
MovableToolbar=false
ShowTrayIcon=false
ToolButtonStyle=0
TrayIconAppearance=monochrome-light

[PasswordGenerator]
AdditionalChars=
ExcludedChars=
Length=46
Logograms=true

[Security]
LockDatabaseScreenLock=false
EOF
}
configure_keepassxc
# réfléchir au parametre DropToBackgroundOnCopy=false, voir si on ne le passe pas à True
################################################################################

################################################################################
## configuration de audacity
##------------------------------------------------------------------------------
configure_audacity() {
  if [ -f /home/"$local_user"/.audacity-data/audacity.cfg ]; then
    sed -i '/^Enabled=1/a [GUI]' /home/"$local_user"/.audacity-data/audacity.cfg && \
    sed -i '/^[GUI]/a ShowSplashScreen=0' /home/"$local_user"/.audacity-data/audacity.cfg
  fi
}
configure_audacity
# on est obligé de lancer audacity pour que le repertoire /home/$local_user/.audacity-data/ soit créé ainsi que les fichiers qu'il contient
# une solution pourrait être d'utiliser la commande suivante :
# timeout 10 bash -c "audacity"
# normallement 10 secondes, c'est suffisant pour que audacity se lance complétement
# en tout cas les deux commandes sed fonctionent très bien
################################################################################

#conf de Gnome
#wget https://dllb2.pling.com/api/files/download/id/1570213192/s/1ce49616d6456cc86478b2ea799264e07aeed57d2d16bbaed7ac7ec648969bb96d729e78cc4cc3c1dd564632310af3ee3efb13f8dc5f7c6b021fb3587d0d96bc/t/1570291872/c/1ce49616d6456cc86478b2ea799264e07aeed57d2d16bbaed7ac7ec648969bb96d729e78cc4cc3c1dd564632310af3ee3efb13f8dc5f7c6b021fb3587d0d96bc/lt/download/Bubble-Dark-Blue.tar.xz
#tar xvf Bubble-Dark-Blue.tar.xz
#mv Bubble-Dark-Blue /usr/share/themes/
#rm Bubble-Dark-Blue.tar.xz

################################################################################
## configuration de Gnome
##------------------------------------------------------------------------------
configure_gnome_dconf() {
  cat << 'EOF' | $ExeAsUser $DCONF_load /org/
[gnome/documents]
window-maximized=true

[gnome/settings-daemon/peripherals/keyboard]
numlock-state='on'

[org/gnome/GWeather]
temperature-unit='centigrade'

[org/gnome/desktop/thumbnail-cache]
maximum-age=365
maximum-size=-1

[gnome/gedit/preferences/editor]
highlight-current-line=false
scheme='classic'
use-default-font=false
wrap-last-split-mode='word'

[gnome/nautilus/preferences]
search-view='list-view'
default-folder-viewer='icon-view'
search-filter-time-type='last_modified'
show-create-link=true
show-delete-permanently=true

[gnome/desktop/calendar]
show-weekdate=true

[gnome/desktop/interface]
clock-show-date=true
show-battery-percentage=true
gtk-im-module='gtk-im-context-simple'
clock-show-seconds=false
clock-show-weekday=true
gtk-theme='Adwaita-dark'
color-scheme='prefer-dark'

[gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'

[gnome/shell]
app-picker-view=uint32 1
favorite-apps=['brave-browser.desktop', 'chromium.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'signal-desktop.desktop', 'joplin.desktop', 'firefox-esr.desktop', 'firefox-esr-private.desktop', 'code.desktop', 'org.gnome.Todo.desktop', 'veracrypt.desktop', 'spotify.desktop', 'libreoffice-writer.desktop', 'asbru-cm.desktop']
had-bluetooth-devices-setup=false

[gtk/settings/file-chooser]
sort-directories-first=true
show-hidden=true

[gnome/evince]
allow-links-change-zoom=false
fullscreen=true
page-cache-size=400

[gnome/evince/default]
dual-page=false
dual-page-odd-left=false
fullscreen=true
show-sidebar=true
sizing-mode='fit-page'
EOF
}
configure_gnome_dconf
# ref : https://superuser.com/questions/726550/use-dconf-or-comparable-to-set-configs-for-another-user/1265786#1265786

# Il pourrait être intéressant de rajouter un reset avant de load la nouvelle conf
# $ExeAsUser DCONF_reset -f /
# il faut quand même faire attention car les paramètres pour la conf des extensions Gnome s'éffectue avant la conf dconf et du coup les paramètres en question seraient reset

# le fait de positionner le theme Adwaita-dark en graphique (avec gnome-tweaks) a créer les fichiers /home/"$local_user"/.config/gtk-4.0/settings.ini  et /home/"$local_user"/.config/gtk-3.0/settings.ini avec le contenu suivant
# [Settings]
# gtk-application-prefer-dark-theme=0

# à voir donc s'il est nécessaire de le créer manuellement en positionnement uniquement la valeur à travers le dconf ou s'il est généré automatiquement avec le dconf

# à voir si c'est utile ou pas de faire la commande dconf update
# ref : https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/customizing_the_gnome_desktop_environment/enabling-and-enforcing-gnome-shell-extensions_customizing-the-gnome-desktop-environment#enabling-and-enforcing-gnome-shell-extensions_customizing-the-gnome-desktop-environment

CustomGnomeShortcut() {
	local name="$1"
	local command="$2"
	local shortcut="$3"
	local value="$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"
	local test="$(sed "s/\['//;s/', '/,/g;s/'\]//" <<< "$value" | tr ',' '\n' | grep -oP ".*/custom\K[0-9]*(?=/$)")"

	if [ "$(echo "$value" | grep -o "@as")" = "@as" ]; then
		local num=0
		local value_new="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${num}/']"
	else
		local i=1
		until [ "$num" != "" ]; do
			if [ "$(echo $test | grep -o $i)" != "$i" ]; then
				local num=$i
			fi
			i=$(echo 1+$i | bc);
		done
		local value_new="$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | sed "s#']\$#', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${num}/']#" -)"
	fi

	$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$value_new"
	$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${num}/ name "$name"
	$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${num}/ command "$command"
	$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${num}/ binding "$shortcut"
}

CustomGnomeShortcut "Ouvrir le terminal" "gnome-terminal" "<Super>r"
CustomGnomeShortcut "Ouvrir l explorateur de fichier" "nautilus -w /home/$local_user/" "<Super>e"
CustomGnomeShortcut "Appairer automatiquement avec le peripherique bluetooth" ""$my_bin_path"/appairmebt" "<Super><Alt>b"
CustomGnomeShortcut "désactiver le bluetooth" ""$my_bin_path"/desactivebt" "<Primary><Alt>b"

# $1       name of the shortcut
# $2       command to execute
# $3       keyboard shortcut

# TODO
# - before shortcut creation, check if:
#   - the shortcut is not used already in custom shortcuts;
#   - the command is not used already in custom shortcuts;
# - sometimes is uses the very same $num multiple times

ConfigureGnomeTerminal() {
  # configuration du profil du Gnome Terminal (palette de couleur identique de celle de Atom)
  # Il ne faut pas que dconf soit executé dans un subshell avec bash -c par exemple, car sinon les caractères simple quote vont être interprété et il faudra backslash tous les cactères simple quote (ps même en escapant les simple quote ça ne fonctionnait toujours pas pour la valeur palette)

  dconf_set() {
    local key="$1"
    local value="$2"
    $ExeAsUser $DCONF_write ""$new_profile_id_key"/"$key"" "$value"
  }

  # because dconf still doesn't have "append"
  dconf_list_append() {
    local key="$1"
    local value="$2"
    local entries="$(
      {
        $ExeAsUser $DCONF_read "$key" | tr -d '[]' | tr ',' '\n' | grep -F -v "$value"
        echo "'$value'"
      } | head -c-1 | tr '\n' ','
    )"

    $ExeAsUser $DCONF_write "$key" "[$entries]"
  }

  base_key_path='/org/gnome/terminal/legacy/profiles:'

  if [[ -n "$($ExeAsUser $DCONF_list "$base_key_path"/)" ]]; then
    # check if there are somes profile already configured
    # there is no output after a fresh install (from the dconf command)(we can get the default with gsettings with this commande : gsettings get org.gnome.Terminal.ProfilesList default)
    # we create an ID with uuidgen to create a new profile
    new_profile_id="$(uuidgen)"

    profile_name='One Dark'

    # récupère l'uuid de la conf par défaut du terminal
    if [[ -n "$($ExeAsUser $DCONF_read "$base_key_path"/default)" ]]; then
      default_profile_id=$($ExeAsUser $DCONF_read "$base_key_path"/default | tr -d \')
    else
      default_profile_id=$($ExeAsUser $DCONF_list "$base_key_path"/ | grep -m1 '^:' | tr -d :/)
      # on récupère le premier id du profil disponnible dans la list des profiles
      # default_profile_id=$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus gsettings get org.gnome.Terminal.ProfilesList default)"
      # attention, à priori la commande gsettings ne donne pas le même résultat pour le profil par défaut quand il y en a un d'accessible avec dconf
      # peut aussi se faire uniquement avec awk 'NR==1,/^:/{gsub(/:/,"");gsub(/\//,""); print}'
    fi

    default_profile_id_key=""$base_key_path"/:$default_profile_id"
    new_profile_id_key=""$base_key_path"/:"$new_profile_id""

    # copy existing settings from default profile
    $ExeAsUser $DCONF_dump "$default_profile_id_key"/ | $ExeAsUser $DCONF_load "$new_profile_id_key"/

    # add new copy to list of profiles
    dconf_list_append "$base_key_path"/list "$new_profile_id"

    # update profile valueues with theme options
    dconf_set visible-name "'$profile_name'"
    dconf_set palette "['#000000', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#abb2bf', '#5c6370', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#ffffff']"
    dconf_set background-color "'#282c34'"
    dconf_set foreground-color "'#abb2bf'"
    dconf_set bold-color "'#ABB2BF'"
    dconf_set bold-color-same-as-fg "true"
    dconf_set use-theme-colors "false"
    dconf_set use-theme-background "false"

    # autre version qui fonctionne aussi et permet d'éviter avoir à faire des dconf write
    # cat << 'EOF' | $ExeAsUser $DCONF_load "$new_profile_id_key"/
    # [/]
    # foreground-color='#abb2bf'
    # visible-name='One Dark'
    # palette=['#000000', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#abb2bf', '#5c6370', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#ffffff']
    # use-theme-colors=false
    # use-theme-background=false
    # bold-color-same-as-fg=true
    # bold-color='#ABB2BF'
    # background-color='#282c34'
    # EOF

  elif [[ -n "$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings get org.gnome.Terminal.ProfilesList default)" ]]; then
    new_profile_id="$(uuidgen)"
    default_profile_id=$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')

    profile_name='One Dark'

    default_profile_id_key=""$base_key_path"/:$default_profile_id"
    new_profile_id_key=""$base_key_path"/:"$new_profile_id""

    # copy existing settings from default profile
    $ExeAsUser $DCONF_dump "$default_profile_id_key"/ | $ExeAsUser $DCONF_load "$new_profile_id_key"/

    # add new copy to list of profiles
    dconf_list_append "$base_key_path"/list "$new_profile_id"

    # update profile valueues with theme options
    dconf_set visible-name "'$profile_name'"
    dconf_set palette "['#000000', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#abb2bf', '#5c6370', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#ffffff']"
    dconf_set background-color "'#282c34'"
    dconf_set foreground-color "'#abb2bf'"
    dconf_set bold-color "'#ABB2BF'"
    dconf_set bold-color-same-as-fg "true"
    dconf_set use-theme-colors "false"
    dconf_set use-theme-background "false"
  fi
}
# script mostly based from https://github.com/denysdovhan/one-gnome-terminal
ConfigureGnomeTerminal

# tmp_multiline_grep="$(cat << 'EOF'
# background-color='#282c34'
# bold-color='#ABB2BF'
# bold-color-same-as-fg=true
# foreground-color='#abb2bf'
# palette=['#000000', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#abb2bf', '#5c6370', '#e06c75', '#98c379', '#d19a66', '#61afef', '#c678dd', '#56b6c2', '#ffffff']
# use-theme-background=false
# use-theme-colors=false
# EOF
# )" && \
# $ExeAsUser $DCONF_dump /org/gnome/terminal/ | sed -E 's/[[:blank:]]+/ /g' | tr '\n' ' ' | grep -o "$(sed -E 's/[[:blank:]]+/ /g' <<< "$tmp_multiline_grep" | tr '\n' ' ')"
# $ExeAsUser $DCONF_dump /org/gnome/terminal/
################################################################################

# Pour obtenir le lien de l'image utilisé commend fond d'écran
# dconf read /org/gnome/desktop/background/picture-uri

################################################################################
## configuration des MIME types
##------------------------------------------------------------------------------
configure_mime_types() {
  $ExeAsUser cat> /home/"$local_user"/.config/mimeapps.list << 'EOF'
[Added Associations]
application/octet-stream=code.desktop;
application/vnd.jgraph.mxfile=com.jgraph.drawio.desktop;
application/x-php=code.desktop;
application/x-mswinurl=launch_url_file.desktop;
application/x-shellscript=code.desktop;
application/x-gettext-translation=org.gnome.gedit.desktop;
application/x-raw-disk-image=gnome-disk-image-mounter.desktop;
application/x-shellscript=code.desktop;
application/x-keepass2=keepassxc.desktop;
application/x-kdbx=keepassxc.desktop;
text/markdown=typora.desktop;org.gnome.gedit.desktop;
text/csv=libreoffice-calc.desktop;org.gnome.gedit.desktop;
text/html=chromium.desktop;code.desktop;
text/x-patch=code.desktop;
text/x-diff=code.desktop;
text/x-python=code.desktop;
video/x-matroska=mpv.desktop;
video/webm=mpv.desktop;
video/x-flv=mpv.desktop;org.gnome.Totem.desktop;vlc.desktop;
video/mp4=mpv.desktop;org.gnome.Totem.desktop;vlc.desktop;
video/quicktime=mpv.desktop;
image/webp=org.geeqie.Geeqie.desktop;

[Default Applications]
application/x-mswinurl=launch_url_file.desktop;
application/x-shellscript=code.desktop
application/x-keepass2=keepassxc.desktop
application/x-kdbx=keepassxc.desktop
text/html=chromium.desktop
text/plain=code.desktop
text/x-diff=code.desktop
text/markdown=typora.desktop
video/mp4=mpv.desktop
video/x-matroska=mpv.desktop
video/webm=mpv.desktop
video/x-flv=mpv.desktop
video/quicktime=mpv.desktop
x-scheme-handler/http=chromium.desktop
x-scheme-handler/https=chromium.desktop
x-scheme-handler/about=chromium.desktop
x-scheme-handler/unknown=chromium.desktop
image/webp=org.geeqie.Geeqie.desktop
image/heif=org.geeqie.Geeqie.desktop
EOF
}
configure_mime_types
# bien faire attention au point virgule, présent dans "Added Associations" mais pas dans "Default Applications"

configure_mime_types_association_drawio() {
  execandlog "is_dir_present_or_mkdir_as_user "/home/"$local_user"/.local/share/mime/packages/"" && \
  $ExeAsUser cat> /home/"$local_user"/.local/share/mime/packages/drawio.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
<mime-type type="application/vnd.jgraph.mxfile">
  <glob pattern="*.drawio"/>
    <comment>draw.io Diagram</comment>
  <icon name="x-office-document" />
</mime-type>
<mime-type type="application/vnd.visio">
  <glob pattern="*.vsdx"/>
    <comment>VSDX Document</comment>
  <icon name="x-office-document" />
</mime-type>
</mime-info>
EOF
  execandlog "$ExeAsUser update-mime-database /home/"$local_user"/.local/share/mime"
}
configure_mime_types_association_drawio
# ref : [Give *.drawio files MIME type to make application association work](https://gist.github.com/giner/0eb272c11085036c4438413f6de0e454)
################################################################################

################################################################################
## configuration de nautilus
##------------------------------------------------------------------------------
# a priori, il n'est pas possible de modifier ou de supprimer les options du click droit de nautilus, il est simplement possible d'en ajouter de nouveaux
# une manière de contourner les problème est de supprimer l'extension rajouter lors de l'installation d'un paquet dans le répertoire /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/
# ref : [gnome - Edit/Remove existing File Manager (right-click/context menu) actions - Ask Ubuntu](https://askubuntu.com/questions/1300049/edit-remove-existing-file-manager-right-click-context-menu-actions/1300079#1300079)
# par exemple le paquet nautilus-wipe rajoute des entrés dans le clic droit assez dangereuses comme "Ecraser" et "Ecraser l'espace disque disponnible"
# pour supprimer ces entrées des options de clic droit de nautilus, il faut soit désinstaller le paquet nautilus-wipe, soit supprimer le .so correspondant dans le répertoire des extensions de nautilus
if [ "$bullseye" == 1 ]; then
  execandlog "[ -f /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/libnautilus-wipe.so ] && \
  mv /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/libnautilus-wipe.so /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/libnautilus-wipe.so.backup"
fi

# pour supprimer des options internes à nautilus, il faudrait modifier son code source et le recompiler
# ref : [Comment supprimer Change Desktop Background du clic droit?](https://qastack.fr/ubuntu/34803/how-to-remove-change-desktop-background-from-right-click)

# à noter qu'on fait le check avec bullseye parce que nautilus-wipe a été supprimé de bookworm car Nautilus utilise GTK4 dans bookworm
# ref : [#1017619 - nautilus-wipe: Fails to build with nautilus 43 - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1017619)
################################################################################

################################################################################
## configuration de l'audio
##------------------------------------------------------------------------------
configure_audio() {
  pulse_env="PULSE_RUNTIME_PATH="/run/user/"$local_user_UID"/pulse" XDG_RUNTIME_DIR="/run/user/"$local_user_UID"/""
  displayandexec "Désactivation du microphone                         " "$ExeAsUser "$pulse_env" amixer set Capture nocap"
  displayandexec "Réglage du volume audio à 10%                       " "$ExeAsUser "$pulse_env" amixer set Master 10%"
}
configure_audio

# commandes utiles pour débugger :
# $ExeAsUser apaly -l
# $ExeAsUser apaly -L
# $ExeAsUser amixer -c 0 controls
# $ExeAsUser alsamixer -c 0

# pacmd list-sinks
# pacmd list-sinks | sed -n "/^.*name:/s/.*<\(.*\)>.*/\1/p"
# la commande ci-dessous (qui fonctionne très bien sans le sudo) ne fonctionne pas lorsqu'elle est faite dans un sudo et nous renvois l'ereur suivante :
# No PulseAudio daemon running, or not running as session daemon.
# $ExeAsUser pacmd list-sinks
# alors que cette même commande fonctionne lorsqu'elle est appelé par su (su "$local_user" -c "pacmd list-sinks")
# pactl info -vvv
# la commande ci-dessous (qui fonctionne très bien sans le sudo) ne fonctionne pas lorsqu'elle est faite dans un sudo et nous renvois l'ereur suivante :
# cette commande fonctionne sur une buster
# pa_context_connect() failed: Connection refused
# Connection failure: Connection refused
# $ExeAsUser pactl info -vvv

# sans sudo :
# pulseaudio --check -v
# I: [pulseaudio] main.c: Daemon running as PID 14118

# avec sudo :
# $ExeAsUser pulseaudio --check -v
# I: [pulseaudio] main.c: Daemon not running

# Si on fait
# $ExeAsUser pulseaudio --start -D
# $ExeAsUser pulseaudio --check -v
# I: [pulseaudio] main.c: Daemon running as PID 16983
# $ExeAsUser amixer set Master 10%
# $ExeAsUser pacmd list-sinks | grep '^[[:blank:]]volume:'
# volume: front-left: 39322 /  60% / -13.31 dB,   front-right: 39322 /  60% / -13.31 dB
# pacmd list-sinks | grep '^[[:blank:]]volume:'
# volume: front-left: 6554 /  10% / -60.00 dB,   front-right: 6554 /  10% / -60.00 dB

# et la, la commande fonctionne correctement, mais la modification ne s'applique pas au pulseaudio démaré par le système, mais s'applique au uniquement au pulseaudio démaré dans le sudo

# $ExeAsUser pulseaudio -k && pulseaudio -vvvv

# sudo fuser -v /dev/snd/*

# systemctl --user status pulseaudio

# cette dommande la a fonctionné dans le sudo : $ExeAsUser rm -rf /home/"$local_user"/.config/pulse/* &&  amixer set Master 20%

# regarder aussi cette solution la : https://bbs.archlinux.org/viewtopic.php?id=155649

# la solution a été d'ajouter les variables d'environnement nécessaires à pulseaudio avec la commande suivante :
# pulse_env="PULSE_RUNTIME_PATH="/run/user/"$local_user_UID"/pulse" XDG_RUNTIME_DIR="/run/user/"$local_user_UID"/""
# ref : [Managin a user-local pulseaudio daemon with runit in voidlinux](https://gist.github.com/yyny/c60b02dd629fc6ed9856c66595688f15#file-pulse-common-sh-L10)
################################################################################

# apparement obligatoire pour executer Signal depuis la CLI
execandlog "chmod 4755 /opt/Signal/chrome-sandbox"
# à noter que la recommandation officiel de la part de Signal est plutôt d'utiliser l'option --no-sandbox pour le lancement de l'appli Signal
# ref : [/opt/Signal/chrome-sandbox gets installed with 0755 instead of 4755 on Debian. · Issue #3627 · signalapp/Signal-Desktop](https://github.com/signalapp/Signal-Desktop/issues/3627#issuecomment-542383195)
# [Fail to start on debian testing · Issue #6382 · signalapp/Signal-Desktop](https://github.com/signalapp/Signal-Desktop/issues/6382#issuecomment-1520624248)
# d'ailleurs, il y a l'option "--no-sandbox" dans le .desktop qui provient du .deb officiel de Signal

################################################################################
## configuration du programme par défaut pour execter les commandes apt-*
##------------------------------------------------------------------------------
execandlog "ln -s "$(command -v apt-fast)" /usr/bin/ag"
# on ne le définie pas en tant qu'un alias pour qu'il puisse être utilisé dans un subshell
################################################################################

################################################################################
## configuration spéficique pour le pc pro
##------------------------------------------------------------------------------
configure_for_pro() {
  echo ''
  echo '     ################################################################'
  echo '     #             CONFIGURATION SPECIFIQUE POUR PC PRO             #'
  echo '     ################################################################'
  echo ''
  source /home/"$local_user"/postinstall_pro.sh
  exec 19>>/tmp/ng_install_set-x_logfile
  BASH_XTRACEFD='19'
}
if [ "$conf_pro" == 1 ]; then
  configure_for_pro
fi
################################################################################

################################################################################
## configuration spéficique pour le pc perso
##------------------------------------------------------------------------------
configure_for_perso() {
  echo ''
  echo '     ################################################################'
  echo '     #            CONFIGURATION SPECIFIQUE POUR PC PERSO            #'
  echo '     ################################################################'
  echo ''
  source /home/"$local_user"/postinstall_perso.sh
  exec 19>>/tmp/ng_install_set-x_logfile
  BASH_XTRACEFD='19'
}
if [ "$conf_perso" == 1 ]; then
  configure_for_perso
fi
################################################################################

################################################################################
## configuration du bashrc et du zshrc
##------------------------------------------------------------------------------
configure_bashrc_user() {
  # alias for the user
  execandlog "is_file_present_and_rmfile "/home/"$local_user"/.bashrc" && \
  cp "$script_path"/.bashrc /home/"$local_user"/.bashrc && \
  chown "$local_user":"$local_user" /home/"$local_user"/.bashrc"
  $ExeAsUser cat "$script_path"/my_user.bashrc >> /home/"$local_user"/.bashrc
# $my_bin_path
# $local_user
}

configure_bashrc_root() {
  # alias for root
  execandlog "is_file_present_and_rmfile "/root/.bashrc" && \
  cp "$script_path"/.bashrc /root/.bashrc"
  cat "$script_path"/my_root.bashrc >> /root/.bashrc
}

configure_zshrc_user() {
  execandlog "is_file_present_and_rmfile "/home/"$local_user"/.zshrc" && \
  cp "$script_path"/.zshrc /home/"$local_user"/.zshrc && \
  chown "$local_user":"$local_user" /home/"$local_user"/.zshrc"
  $ExeAsUser cat "$script_path"/my_user.zshrc >> /home/"$local_user"/.zshrc
}

configure_zshrc_root() {
  execandlog "is_file_present_and_rmfile "/root/.zshrc" && \
  cp "$script_path"/.zshrc /root/.zshrc"
  cat "$script_path"/my_root.zshrc >> /root/.zshrc
}

configure_bashrc() {
  configure_bashrc_user
  configure_bashrc_root
  displayandexec "Configuration du bashrc                             " "\
  stat /home/"$local_user"/.bashrc && \
  stat /root/.bashrc"
}
configure_bashrc

configure_zshrc() {
  configure_zshrc_user
  configure_zshrc_root
  displayandexec "Configuration du zshrc                              " "\
  stat /home/"$local_user"/.zshrc && \
  stat /root/.zshrc"
}
configure_zshrc

if [ "$conf_perso" == 1 ]; then
  configure_bashrc_perso
  configure_zshrc_perso
fi
if [ "$conf_pro" == 1 ]; then
  configure_bashrc_pro
  configure_zshrc_pro
fi

# à noter que cette ligne "export PATH="\$PATH:/home/$local_user/.local/bin" dans les .zshrc et .bashrc n'est probablement plus nécessaire depuis la version "4.4.18-1" de bash dans Debian, car le PATH est censé être intégré dans ~/.profile
# ref :
# [Import Debian changes 4.4.18-1 (d8797dfc) · Commits · Debian / bash · GitLab](https://salsa.debian.org/debian/bash/-/commit/d8797dfccb5a299d2e5af988c0d95554d762b7b6)
# [debian/skel.profile · debian/master · Debian / bash · GitLab](https://salsa.debian.org/debian/bash/-/blob/debian/master/debian/skel.profile?ref_type=heads#L24)

configure_default_shell() {
  displayandexec "Configuration de zsh en tant que shell par défaut   " "\
  sed -i 's/auth       required   pam_shells.so/auth       sufficient   pam_shells.so/' /etc/pam.d/chsh && \
  $ExeAsUser chsh --shell "$(command -v zsh)" && \
  chsh --shell "$(command -v zsh)" && \
  sed -i 's/auth       sufficient   pam_shells.so/auth       required   pam_shells.so/' /etc/pam.d/chsh"
}
configure_default_shell
# l'excution de cette commande demande un logoff/login du user pour prendre éffet
# on est obliger de changer la valeur de /etc/pam.d/chsh car sinon la commande nous demande de rentrer le mdp de l'utilisateur et donc l'execution de la commande devient intéractif.
# ref : [command line - chsh always asking a password , and get `PAM: Authentication failure` - Ask Ubuntu](https://askubuntu.com/questions/812420/chsh-always-asking-a-password-and-get-pam-authentication-failure/812426#812426)
# on change donc la valeur dans /etc/pam.d/chsh avant et après l'execution de la commande chsh

# Pour zsh, on ne configure pas l'affichage des dates devant les commandes avec la variable HISTTIMEFORMAT mais on le fait avec l'utilisation de la commande fc -li 1
# ref : [How to view datetime stamp for history command in Zsh shell - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/103398/how-to-view-datetime-stamp-for-history-command-in-zsh-shell/436221#436221)
################################################################################

# Commande temporaire pour éviter que des fichiers de /home/user/.config n'appartienent à root lors de l'install, sans qu'on comprenne bien pourquoi (executé par ExeAsUser)
execandlog "find /home/"$local_user"/ -user 'root' -not -type l"
execandlog "chown -R "$local_user":"$local_user" /home/"$local_user"/"
# problement que la commande va rester dans le script car elle permet de corriger les appartenances des fichiers/dossiers s'il y en a besoin (par exemple, les déplacement de .zshrc et .bashrc du dossier du script)

################################################################################
## Mise à jour de la base de donnée de rkhunter
##------------------------------------------------------------------------------
update_rkhunter() {
  displayandexec "Mise à jour de la base de donnée de rkhunter        " "\
  rkhunter --versioncheck ;\
  rkhunter --update ;\
  rkhunter --propupd"
}
# update_rkhunter
################################################################################

################################################################################
## Execution d'un scan pour détecter la présence de rootkits
##------------------------------------------------------------------------------
# execution de rktscan
# displayandexec "Execution de rktscan                                " ""$my_bin_path"/rktscan"
# on désactive le scan des rootkits lors de l'execution du script car il met énormément de temps à se terminer
################################################################################

################################################################################
## création d'un fichier de backup du header LUKS
##------------------------------------------------------------------------------
backup_LUKS_header() {
  export LVM_SUPPRESS_FD_WARNINGS=1
  root_pv_name="$(pvdisplay --columns --options lv_name,pv_name | awk -F'/' '{if ($1 ~ /^[[:blank:]]+root/) {print $4}}')"
  root_lvm_parent_partition="$(lsblk -o PKNAME,FSTYPE,NAME | awk '/'"$root_pv_name"'/{print $1}')"
  luks_partition="$(lsblk -o NAME,FSTYPE /dev/"$root_lvm_parent_partition" | awk '/crypto_LUKS/{print $1}')"
  displayandexec "Création d'un backup de l'entête LUKS               " "\
  is_dir_present_or_mkdir_as_user "/home/"$local_user"/.backup/LUKS/" && \
  cryptsetup isLuks /dev/"$luks_partition" && \
  cryptsetup luksHeaderBackup /dev/"$luks_partition" --header-backup-file /home/"$local_user"/.backup/LUKS/"$luks_partition"_LUKS_header_backup-"$now".img"
}
backup_LUKS_header
# on s'assure dans un premier temps de récupérer uniquement le path de la partition qui contient le lvm du système (lv root) pour être sur de ne faire que la sauvegarde du LUKS du système
# au final, il est préférable de ne pas utiliser root_lvm_parent_partition="$(lsblk -o PKNAME,FSTYPE,NAME --json | grep "$root_pv_name" | grep -Po '("pkname":")\K([A-Za-z0-9\-]+)(?=")')"
# car ils ont changer le format d'affichage du output json entre les versions lsblk from util-linux 2.36.1 (bullseye) et lsblk de util-linux 2.38.1 (bookworm)

# on est obligé de faire export LVM_SUPPRESS_FD_WARNINGS=1 pour éviter d'avoir un message d'érreur lors de l'execution de la commande pvdisplay
# from lvm man page :
# On  invocation,  lvm  requires  that only the standard file descriptorsstdin, stdout and stderr are available.  If others are found, they  getclosed  and  messages  are issued warning about the leak.  This warning can  be  suppressed  by  setting  the  environment  variable   LVM_SUPPRESS_FD_WARNINGS.
# ref : [#466138 - lvm2: File descriptor 3 left open - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=466138)
################################################################################

################################################################################
## désactivation du bluetooth
##------------------------------------------------------------------------------
disable_bluetooth() {
  hte_gdbus_call_disable_bluetooth="'<true>'"
  displayandexec "Désactivation du bluetooth                          " "\
  $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "$hte_gdbus_call_disable_bluetooth" >/dev/null"
}
disable_bluetooth
# Pour vérifier les valeures actuellements positionnées : gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.GetAll org.gnome.SettingsDaemon.Rfkill | tr -s ',' '\n'
################################################################################

################################################################################
## Mise à jour de la base de donnée des fichiers
##------------------------------------------------------------------------------
update_file_name_db() {
  displayandexec "Mise à jour de la base de donnée des fichiers       " "updatedb"
}
update_file_name_db
################################################################################

################################################################################
## redémarage ou arrêt des services
##------------------------------------------------------------------------------
# systemctl stop knockd
# systemctl stop fail2ban
restart_ssh() {
  displayandexec "Redémarage du service SSH                           " "systemctl restart ssh"
}
restart_ssh
################################################################################

################################################################################
## désactivation des services par défaut qui ne nous sont pas nécessaires
##------------------------------------------------------------------------------
disable_unneeded_services() {
  execandlog "systemctl status .service"
  displayandexec "Désactivation des services non nécessaires          " "\
  systemctl mask --now .service"
}
# disable_unneeded_services
################################################################################

################################################################################
## configuration des règles de firewall
##------------------------------------------------------------------------------
configure_firewall() {
  displayandexec "Configuration du firewall                           " "\
  ufw --force reset && \
  ufw default deny incoming && \
  ufw default allow outgoing && \
  ufw allow "$SSH_Port"/tcp && \
  ufw limit "$SSH_Port"/tcp && \
  ufw logging high && \
  ufw --force enable"
}
configure_firewall
################################################################################

#réapplication de la cond par défaut pour la mise en veille automatique
# $ExeAsUser $DCONF_write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'suspend'"
# $ExeAsUser $DCONF_write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'"

# remise au propre du fichier de configuration DNS
execandlog "rm -f /etc/resolv.conf && mv /etc/resolv.conf.old /etc/resolv.conf"

################################################################################
## activation de systemd-resolved comme resolver DNS
##------------------------------------------------------------------------------
change_dns_resolver_to_systemd_resolved() {
  displayandexec "Activation de systemd-resolved comme resolver DNS   " "\
  $AGI systemd-resolved && \
  $AGI openvpn-systemd-resolved && \
  systemctl status systemd-resolved && \
  resolvectl status"
}
change_dns_resolver_to_systemd_resolved
################################################################################

################################################################################
## Redirection du current directory dans /home
##------------------------------------------------------------------------------
cd
################################################################################

################################################################################
## Création d'un snapshot avec Timeshift
##------------------------------------------------------------------------------
create_root_part_snapshot_with_timeshift_rsync() {
  displayandexec "Création d'un snapshot de / avec Timeshift          " "\
  umount -l /run/timeshift/backup; \
  timeshift --scripted --create --rsync --comments 'first snapshot, after postinstall script' --snapshot-device /dev/"$root_part_kname""
  # cette étape est très longue lorsqu'il faut faire un premier snapshot (car timeshift doit faire en fait un miroir du système existant)
  # sur un HDD pas très rapide, il y en a pour à peu près une heure
}

create_root_part_snapshot_with_btrfs() {
  displayandexec "Création d'un snapshot BTRFS de /                   " "\
  is_dir_present_or_mkdir /.snapshot/ && \
  btrfs subvolume list / && \
  mkdir /.snapshot && \
  btrfs subvolume snapshot / /.snapshot/@"$now" && \
  btrfs subvolume list /"
}

check_if_root_part_is_btrfs() {
  if findmnt / --raw --noheadings --output=FSTYPE | grep -qw 'btrfs' &>/dev/null; then
    create_root_part_snapshot_with_btrfs
  else
    create_root_part_snapshot_with_timeshift_rsync
    execandlog "timeshift --list"
    # On fait le timeshift --list qu'on redirige dans le fichier de log juste pour avoir les infos de la création du snapshot.
    # Après l'execution du script ng_install et du snapshot avec timeshift, il y a environ 26 Go d'utilisé sur / pour un système basé sur bullseye
    execandlog "umount -l /run/timeshift/backup"
    # on démonte le point de montage de timeshift car il n'est plus nécessaire
    # peut être qu'à terme il serait intéressant de voir pour ajouer une partition dédié pour les backups
  fi
}

if [ -z "$fisrt_time_script_executed" ]; then
  root_part_kname="$(lsblk -o KNAME,MOUNTPOINT | awk '{{if ($2 == "/") print $1}}')"
  check_if_root_part_is_btrfs 
fi
# on éffectue uniquement un snapshot de la partition root qu'à la première excution du script (c'est à dire, juste après une install au propre du script suite à l'installation de la debian)
# à noter que timeshift est maitenus par Mint désormais

# create_root_part_snapshot_with_timeshift_btrfs() {
#   displayandexec "Création d'un snapshot avec Timeshift               " "\
#   umount -l /run/timeshift/backup; \
#   timeshift --scripted --create --btrfs --comments 'first snapshot, after postinstall script' --snapshot-device /dev/"$root_part_kname""
# }
# on ne peut pas utiliser timeshift pour faire un snapshot BTRFS à cause de cette érreur :
# [Timeshift does not recognize BTRFS subvolume structure · Issue #241 · teejee2008/timeshift · GitHub](https://github.com/teejee2008/timeshift/issues/241)
# [linuxmint/timeshift: System restore tool for Linux. Creates filesystem snapshots using rsync+hardlinks, or BTRFS snapshots. Supports scheduled snapshots, multiple backup levels, and exclude filters. Snapshots can be restored while system is running or from Live CD/USB.](https://github.com/linuxmint/timeshift?tab=readme-ov-file#btrfs-volumes)
# [#1042538 - timeshift: Debian installer makes BTRFS root subvolume named "@rootfs" and timeshift requires "@" - Debian Bug report logs](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1042538)
################################################################################

# tmp avant l'import du répertoire de Signal
execandlog "chmod -x /opt/Signal/signal-desktop"

print_end_of_script_in_log_file() {
  cat>> "$log_file" << 'EOF'
--------------------------------------------------------------------

####################################################################
#                           Fin du script                          #
####################################################################
EOF
}
print_end_of_script_in_log_file

echo ''
echo '     ################################################################'
echo "     #                  L'INSTALLATION EST TERMINEE                 #"
echo '     ################################################################'
echo ''

################################################################################
## calcul du temps d'execution du script
##------------------------------------------------------------------------------
finish_time="$(date +%s)"
finish_time_in_seconde=$(( $finish_time - start_time ))
time_secondes=$(( $finish_time_in_seconde % 60 ))
time_minutes=$(( ($finish_time_in_seconde / 60) % 60 ))
time_heures=$(( ($finish_time_in_seconde / (60 * 60)) ))
echo -e "Temps d'execution du script : "$time_heures"h" $time_minutes"m" $time_secondes"s"
################################################################################

cp /tmp/ng_install_set-x_logfile "$log_dir"/ng_install_set-x_logfile-"$now"

################################################################################
## after install options
##------------------------------------------------------------------------------
if [ "$show_log" == 1 ]; then
  more "$log_file"
fi

if [ "$show_only_error" == 1 ]; then
  grep -i 'error' "$stdout_file"
fi

if [ "$reboot_after_install" == 1 ]; then
  reboot
fi

if [ "$shutdown_after_install" == 1 ]; then
  poweroff
fi
################################################################################

exit 0