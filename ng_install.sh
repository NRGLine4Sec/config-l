#!/bin/bash
##
## Made by NRGLine4Sec
##

## Les .desktop créés par alacarte sont dans .local/share/applications

## Pour retrouver la date d'installation d'un paquet avec apt-get : sudo zgrep "linux-image" /var/log/dpkg.log* | grep " install\| installed "
## c'est un exemple qui permet d'obtenir la date d'install de tous les paquets linux-image.

## les règles udev sont situés dans /etc/udev/rules.d/ mais aussi dans /usr/lib/udev/rules.d/

## Pour installer un paquet depuis les dépots buster-backport : apt-get -t buster-backports install <package>

## Pour ajouter des modules au démarrage du système, il faut les ajouter dans ce fichier /etc/initramfs-tools/modules
## ensuite lancer la commande suivante : update-initramfs -u

## utiliser l'option -l de grep ou bien zgrep pour n'obtenir que le chemin du fichier qui contient le patern que'on recherche

## Pour obtenir toutes les commandes utilisés sur un système : sudo grep -o "COMMAND.*" /var/log/auth.log

## Pour escape tous les caractère spéciaux automatiquement avec sed et pouvoir réutiliser le résultat dans une autre commande sed par exemple : sed -e 's/[]\/$*.^[]/\\&/g'
## exemple pour le patern /var/log/auth.log : echo '/var/log/auth.log' | sed -e 's/[]\/$*.^[]/\\&/g'
## on obtient alors : \/var\/log\/auth\.log

## Pour désactiver le bip système : xset b off

## # tous les .desktop d'appli se trouvent dans /usr/share/applications/

## Pour extraire une version d'un logiciel avec grep (un exemple avec keepassxc) : grep -Po '^Exec.*-\K\d+.\d+.\d+' /usr/share/applications/keepassxc.desktop
## -P : interpréter le patern comme une regexp perl
## -o : permet de ne matcher que la partie de la ligne
## ^Exec.*- : uniquement les lignes qui commencent par Exec et qui contiennent dans la suite de la ligne un -
## \K : permet de supprimer tout le patern matcher précédement du résulat
## \d+ : permet d'inttifer un patern de type digit (donc un chiffre). Le + permet d'indiquer qu'il peut y en avoir plusieurs à la suite

## grep -m 1 permet de ne matcher que la première occurence

## Pour redémarer le daemon alsa : sudo systemctl restart alsa-state.service

## Pour faire un tcpdump sur toutes les interfaces : sudo tcpdump -i any

## pour obtenir les systèmes de fichier utilisés : mount | column -t

## garder dans un coin la commande suivante : sudo cat /proc/net/nf_conntrack

## les paramètres du lancement de chromium sont stocker danc ce fichier bat /etc/chromium.d/default-flags



# exemple de contenu du .zshrc (provient d'une Kali)



##
## à garder de côté et à regarder pour l'utilité : https://github.com/lunaryorn/mdcat
##
## passer de iptables à nftables, notamment pour la partie ufw/gufw
##

# Regarder comment ils font avec le script shell de remediation : http://static.open-scap.org/ssg-guides/ssg-debian8-guide-anssi_np_nt28_high.html#xccdf_org.ssgproject.content_rule_sshd_disable_root_login
# Regarder aussi pour ajouter cette conf la : http://static.open-scap.org/ssg-guides/ssg-debian8-guide-anssi_np_nt28_high.html#xccdf_org.ssgproject.content_rule_sshd_disable_empty_passwords
##
#
##
## à retenir que le /g dans sed "Replaces all matches, not just the first match"
##
# sed -i 's/SEARCH_REGEX/REPLACEMENT/g' INPUTFILE
# -i - By default sed writes its output to the standard output. This option tells sed to edit files in place. If an extension is supplied (ex -i.bak) a backup of the original file will be created.
# s - The substitute command, probably the most used command in sed.
# / / / - Delimiter character. It can be any character but usually the slash (/) character is used.
# SEARCH_REGEX - Normal string or a regular expression to search for.
# REPLACEMENT - The replacement string.
# g - Global replacement flag. By default, sed reads the file line by line and changes only the first occurrence of the SEARCH_REGEX on a line. When the replacement flag is provided, all occurrences will be replaced.
# INPUTFILE - The name of the file on which you want to run the command.
##
## regarder pour la partie auditd
# auditctl -w /etc/ssh/sshd_config -p warx -k sshd_config
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/security_hardening/index#understanding-audit-log-files_auditing-the-system
##
## On peut aussi utiliser "if !" pour indiquer la négation de la condition d'un if par exempe if ! wget www.google.Fr; then echo "pas d'accès à Internet";fi
##
## Regarder de près cet outil la : https://github.com/gustavo-iniguez-goya/arpsentinel-applet
##
## Regarder pour voir si on intègre cet extension : https://extensions.gnome.org/extension/687/birthdays_notify/
##
## Regarder pour voir si on install gnome-boxes
##
## Rajouter dans la version PRO l'install de VMWare Workstation
##
##
## Regarder pour voir si on install zulucrypt
##
## Regarder pour voir si on install firejail (l'installer manuellement depuis https://github.com/netblue30/firejail/releases car la release depuis les dépots de Debian est trop vielle)
##
## Une extension Gnome permet de faire en sorte de désactivé le black screen après avoir vérouiller la session (Win + L) : https://extensions.gnome.org/extension/1414/unblank/
##
## Pour faire l'install du script avec apt-fast à place de apt-get
## On vérifie que aria1 est installé, si il ne l'ait pas, on l'install
# if ! dpkg-query --show aria2 > /dev/null 2>&1; then
#     apt-get update
#     apt-get install -y aria2
#   fi
## Ensuite faire l'install de apt-fast
##
##
##
## ajouter l'outil suivant https://github.com/orhun/kmon
##
## regarder pour savoir s'il y a besoin d'ajouter : https://github.com/imsnif/bandwhich
##
## regarder si on a besoin de ça : https://github.com/denisidoro/navi
## ça fonctionne vriament bien et c'est simple d'utilisation, il faudrait simplement créer les cheatsheats en fonction des besoins
##
## regarder de très près cet outil : https://github.com/chmln/sd
##
## a garder dans un coin en cas d'upgrade de Gnome ( pour installer des gnom-extension) : https://github.com/gustavo-iniguez-goya/opensnitch/issues/44#issuecomment-654373737
##
## Firejail et asbru-cm (firejail --noprofile asbru-cm)
##
## Pour executer les programmes qui disposent de profile firejail automatiquement faire sudo firecfg
##
## Tester l'outil ultracopier (apt-get install ultracopier) et notamment son intégration avec nautilus
##
## Regarder pour installer tumbler-plugins-extra
##
##
#

#
#
# ----
# apparement ce fichier de conf est renseigner par libreoffice en faisant le delta entre la conf par défaut et les modifs de conf, il faudrait donc voir ce que contient le fichier après une install, faire les modifs nécessaire et faire un diff pour obtenir les paramètres qui sont ajouter dans le fichier
# /.config/libreoffice/*/user/registrymodifications.xcu
# https://forum.openoffice.org/en/forum/viewtopic.php?f=16&t=64520
# https://askubuntu.com/questions/83605/how-do-i-export-customized-libreoffice-config-files
# ----
#
## regarder pour voir si on configure par défaut lnav avec un retour à la ligne
## https://lnav.readthedocs.io/en/latest/commands.html#enable-word-wrap
## notamment voir si on l'utilise manuellement (avec un Ctrl + Maj + v :enable-word-wrap)
#
#
## les applications qui se lance aux démarage se font à l'aide de fichiers créés dans .config/autostart/ avec un contenu tel que celui-ci
# bat .config/autostart/boostnote.desktop
# [Desktop Entry]
# Name=Boostnote
# Comment=lancement de Boostnote au démarage
# Exec=boostnote
# Type=Application
# Terminal=false
# Hidden=true
#
## Pour supprimer l'execution au démarage d'un programme, il suffit de supprimer le fichier défini dans .config/autostart/
## Il est à noter que la version du programme peut être référencé dans le fichier, donc il faut les modifier lors d'upgrade de programme en AppImage par exemple


## theme gnome a regarder : Adapta-gtk-theme-colorpack (https://www.gnome-look.org/p/1190851/)

## regarder pour installer solaar (pour les gestions des périphériques logytech) : https://pwr-solaar.github.io/Solaar/installation    https://github.com/pwr-Solaar/Solaar    (normalement il suffit juste de faire un pip3 install solaar) et si il ne se lance pas, utiliser la commande : python3 ./.local/lib/python3.7/site-packages/solaar/gtk.py
# bat ~/.config/solaar/config.json
# solaar show
# pour voir uniquement les infos concernant la souris : solaar show mouse
# solaar -dd show
# cat /proc/bus/input/devices
# xinput | grep "Logitech MX Vertical"
# xinput list-props 11
# xinput query-state 11
# Do you get raw output from the input device? ("sudo cat /dev/input/event<n>"
# use xinput list-props 11 | grep "Device Node" to get event id
# Pour obtenir le numéro du bouton : xev | grep -A3 ButtonPress

# cat> /home/$local_user/.xbindkeysrc << 'EOF'
# # backward button => volume down
# "xte 'key XF86AudioLowerVolume'"
#    b:8
#
# # forward button => volume up
# "xte 'key XF86AudioRaiseVolume'"
#    b:9
# EOF
# apt-get install -y xbindkeys xautomation
# xbindkeys

# ref : [Configurer sa souris Logitech MX Master sous Linux (Ubuntu) – Miximum](https://www.miximum.fr/blog/configurer-sa-souris-logitech-mx-master-sous-linux-ubuntu/)
# ref : [Linux: xbindkeys Tutorial](http://xahlee.info/linux/linux_xbindkeys_tutorial.html)
# ref : [How to start a service automatically when Arch Linux boots? - Super User](https://superuser.com/questions/755937/how-to-start-a-service-automatically-when-arch-linux-boots)

# si jamais il y a besoin :
# cat> /home/$local_user/.config/autostart/xbindkeys.desktop << 'EOF'
# [Desktop Entry]
# Name=xbindkeys
# Comment=xbindkeys
# Exec=xbindkeys
# Type=Application
# Terminal=false
# Hidden=false
# EOF


## regarder aussi .local/share/solaar/udev-rules.d/42-logitech-unify-permissions.rules


## pour désinstaller le driver de realtek du dongle bluetooth
# ll /lib/modules/$(uname -r)/kernel/drivers/bluetooth/ | grep "hci_uart.ko\|rtk_btusb.ko"
# ll /lib/firmware/rtlbt/
# udevadm info -a -p /sys/class/bluetooth/hci0
# [Disabling the built in bluetooth and use a USB adaptor instead (on Linux) | DAVID RICHARD BELL](https://blog.evad.io/2018/01/11/disabling-the-built-in-bluetooth-and-use-a-usb-adaptor-instead-on-linux/)
# inxi -xxx --usb | grep -A 4 "Bluetooth"
# gnome-control-center -v bluetooth
# sudo hciconfig hci0 up
# [gsd-rfkill can't cope with hotplugged rfkill devices (#52) · Issues · GNOME / gnome-settings-daemon · GitLab](https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/issues/52)


# sudo cat /var/lib/gdm3/.local/share/xorg/Xorg.0.log

# problématique de pouvoir désactiver ou activer le bluetooth depuis l'interface graphique sans avoir de permission root alors qu'il semble qu'il y ait besoin des permissions root pour puvoir le faire en ligne de commande, notamment à l'aide de la commande rfkill
# [rfkill permissions · Issue #75 · linuxmint/blueberry](https://github.com/linuxmint/blueberry/issues/75)



# PRESEED
# [DebianInstaller/Preseed - Debian Wiki](https://wiki.debian.org/DebianInstaller/Preseed)
# [Mike Renfro Blog : The New File Server: Preseeding and LVM](https://web.archive.org/web/20170911182730/http://blogs.cae.tntech.edu/mwr/2007/08/02/the-new-file-server-preseeding-and-lvm/)
# [Mike Renfro Blog : Unattended Debian Installations (or How I Learned to Stop Worrying and Love the preseed.cfg)](https://web.archive.org/web/20170911185428/http://blogs.cae.tntech.edu/mwr/2007/04/17/unattended-debian-installations-or-how-i-learned-to-stop-worrying-and-love-the-preseedcfg/)
# [Automating new Debian installations with preseeding](https://web.archive.org/web/20200809164102/https://debian-administration.org/article/394/Automating_new_Debian_installations_with_preseeding)
# [paulgorman.org/technical](https://paulgorman.org/technical/ubuntu-preseed-kickstart.txt.html)
# [debian-installer/partman-auto-recipe.txt at master · xobs/debian-installer](https://github.com/xobs/debian-installer/blob/master/doc/devel/partman-auto-recipe.txt)
# [server - How do I preseed a disk to 50% / and /tmp? - Ask Ubuntu](https://askubuntu.com/questions/94280/how-do-i-preseed-a-disk-to-50-and-tmp)
# [Debian Preseed and Docker](https://www.frakkingsweet.com/debian-preseed-and-docker/)
# [Enterprise/WorkstationAutoinstallPreseed - Ubuntu Wiki](https://wiki.ubuntu.com/Enterprise/WorkstationAutoinstallPreseed)
# [p50-preseed · master · Preseed / p50 preseed · GitLab](https://gitlab.com/preseed/preseed-p50/-/blob/master/p50-preseed)
# [gaming-preseed · master · Preseed / desktop preseed · GitLab](https://gitlab.com/preseed/preseed-desktop/-/blob/master/gaming-preseed)
# [Debian 10 Preseed [Chuck Nemeth]](https://www.chucknemeth.com/linux/distribution/debian/debian-10-preseed)
# [Preseed Debian 9 – UEFI with Encrypted LVM [Chuck Nemeth]](https://www.chucknemeth.com/linux/distribution/debian/debian-9-preseed-uefi-encrypted-lvm)
# [installation - Ubuntu preseed install. 50% of / and /tmp - Stack Overflow](https://stackoverflow.com/questions/8800256/ubuntu-preseed-install-50-of-and-tmp)
# [Understanding partman-auto/expert_recipe | Tim Bishop](https://www.bishnet.net/tim/blog/2015/01/29/understanding-partman-autoexpert_recipe/)
# [PartMan/Auto - Wikitech](https://wikitech.wikimedia.org/wiki/PartMan/Auto)
# [Preseed LVM+Crypto 18.04 - Ask Ubuntu](https://askubuntu.com/questions/1132060/preseed-lvmcrypto-18-04)
# [Preseeding Full Disk Encryption | Linux Journal](https://www.linuxjournal.com/content/preseeding-full-disk-encryption)
# [Debian Preseed with Encrypted LVM](https://gist.github.com/chuckn246/ca24d26c048b3cc4ffa8188708f5dccf)
# [Ubuntu 14.04 preseed - Full Disk Encryption](https://gist.github.com/cedricvidal/eab1578c30b30802eaca403a2dd596d5)
# [Disk encryption in debian-installer recipe - Support - TheForeman](https://community.theforeman.org/t/disk-encryption-in-debian-installer-recipe/20184/4)
# [Quelques astuces sur la méthode preseed pour installer Debian - Where is it?](https://medspx.fr/blog/Debian/preseed_snippets/)
# [preseed debian / Wiki / Debian-facile](https://debian-facile.org/doc:install:preseed)
# [DebianInstaller/Preseed/EditIso - Debian Wiki](https://wiki.debian.org/DebianInstaller/Preseed/EditIso)
# [fr/DebianInstaller/Preseed - Debian Wiki](https://wiki.debian.org/fr/DebianInstaller/Preseed)
# [B.3. Creating a preconfiguration file](https://www.debian.org/releases/buster/amd64/apbs03.en.html)
# [server - How do I preseed a disk to 50% / and /tmp? - Ask Ubuntu](https://askubuntu.com/questions/94280/how-do-i-preseed-a-disk-to-50-and-tmp)
# [debian-installer/partman-auto-recipe.txt at master · xobs/debian-installer](https://github.com/xobs/debian-installer/blob/master/doc/devel/partman-auto-recipe.txt)
# https://github.com/elreydetoda/packer-kali_linux/blob/master/install/http/kali-linux-rolling-preseed.cfg
# [Debian 10 Preseed [Chuck Nemeth]](https://www.chucknemeth.com/linux/distribution/debian/debian-10-preseed)


## copier leur système d'affiche pour l'usage : [Remove Elasticsearch indices that older than a given date.](https://gist.github.com/yumminhuang/ec03bcacbbc6434412b82ca0c34e7a18)

## a regarder pour installer setools-gui

## commande à garder dans un coin : sudo lshw -class memory

## regarder de plus près cette outil : https://github.com/jwyllie83/tcpping (ou au moins trouver la commande équivalente pour faire du ping TCP avec nmap)
## https://hub.packtpub.com/discovering-network-hosts-with-tcp-syn-and-tcp-ack-ping-scans-in-nmaptutorial/

## Download only the 1080p video/audio stream from a video.
## youtube-dl -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" {URL}

## utiliser dbus-monitor pour monitorer les appels dbus

## regarder nsntrace (apt-get install -y nsntrace)
## sudo nsntrace -d enp -o result.pcap -u $USER signal-desktop

# pour avoir des infos lspci via udevadm
# while read item; do echo -e "${item} valeur=$(strings $item 2> /dev/null)"; udevadm info -q all -p "$item" 2> /dev/null ; done  < <(find /sys/devices -regex "/sys/devices/.*01:00\.0\/.*")
# où par exemple lspci -s 01:00.0   (...)
# lspci -nn | awk 'BEGIN {FPAT="[[:xdigit:]]{4}"}; {print "Contrôleur Type",$1,":",$0}'

#  vérifier aussi le paramètre msi de la carte mère
# for item in /sys/module/*/parameters/**; do if [ -f "$item" ]; then echo -e "$(cut -f4 -d"/" <<<"$item") $(basename $item)=$(cat $item 2> /dev/null)"; fi;  done | egrep -i 'pcie|aspm|msi|aer|8723be'


# sudo lspci -nnkv | grep -iB13 pcieport

# faire un diff avant et après avoir modifier la conf de l'interface de Wireshark (ajout de la colonne Port et SNI et date)
# cp ./.config/wireshark/preferences tmp_diff1.txt
# cp ./.config/wireshark/preferences tmp_diff2.txt
# diff tmp_diff1.txt tmp_diff2.txt

# Le fichier n'existe pas avant d'avoir été dans  Edit → Preferences…​ (Wireshark → Preferences…) et d'avoir quitter la fenêtre avec OK.
#
# Ce qui semble faire la conf :
# ####### User Interface ########
# # The max. number of items in the open recent files list
# # A decimal number
# /ssl.handshake.extensions
# … escamotage
# 	"Protocol", "%p",
# 	"Length", "%L",
# 	"SNI", "%Cus:ssl.handshake.extensions_server_name:0:R",
# 	"SMBv2 Filename", "%Cus:smb2.filename:0:R"
#
# regarder https://osqa-ask.wireshark.org/answer_link/50481/



# script à regarder de plus près pour voir comment intégrer un affichage des tirets et des hashtags en fonction de la longueur du terminal et du message a afficher
# declare -ag COL_LEN=($(wget -qO- http://bit.ly/cpu_flags | awk -F\| 'BEGIN { NR==1;getline; H1=$1; H2=$2; H3=$3 } { for (i=1; i<=NF; i++) { max[i] = length($i) > max[i] ? length($i) : max[i] ;ncols = i > ncols ? i : ncols }} END { {print H2":"max[2]"\n"H3":"max[3]"\n"H1":"max[1]"\n"}}'))
# export LS='─'
# (printf "%s\n" ${COL_LEN[@]%%:*} | paste -sd\| && printf "%s\n" ${COL_LEN[@]##*:} | xargs -n1 bash -c 'eval printf "%.3s" ${LS}{1..${0}};echo' | paste -sd"|"
# wget -qO- http://bit.ly/cpu_flags | awk -F\| '!/^CLASS/{print $2"|"$3"|"$1}') | column -nexts '|' | sed '1,2s/.*$/'$(printf "\e[1m")'&'$(printf "\e[0m")'/'



# gestioin des mots de passe stockés
# gnome-key - seahorse
# [What are Linux keyring, gnome-keyring, Secret Service, D-Bus](https://rtfm.co.ua/en/what-is-linux-keyring-gnome-keyring-secret-service-and-d-bus/)
# [How to store a new record in gnome keyring via secret-tool in an ansible task or how to pipe stdin in an ansible shell task? - Stack Overflow](https://stackoverflow.com/questions/58894523/how-to-store-a-new-record-in-gnome-keyring-via-secret-tool-in-an-ansible-task-or)
# [https://raw.githubusercontent.com/isamert/dotfiles/master/.scripts/getpassword](https://raw.githubusercontent.com/isamert/dotfiles/master/.scripts/getpassword)
# [KeepassXC Question about CLI : KeePass](https://www.reddit.com/r/KeePass/comments/a5tjx2/keepassxc_question_about_cli/)
# [Automatize your logins with gnome-keyring (and optionally with KeePassXC) | isamert](https://isamert.net/jekyll/update/2018/10/05/automatize-your-logins-with-gnome-keyring-and-keepassxc.html)
# [Keyring alternative: Access KeePassXC entries of an unlocked database from the command line : linux](https://www.reddit.com/r/linux/comments/ehfhud/keyring_alternative_access_keepassxc_entries_of/)
# [Question #209138 : Questions : gkeyring](https://answers.launchpad.net/gkeyring/+question/209138)
# [Using KeePassXC as your system-keyring and ssh-agent - Cogitri's blog](https://www.cogitri.dev/posts/03-keepassxc-freedesktop-secret/)
# [KeepassXC as the System Keyring [Chuck Nemeth]](https://www.chucknemeth.com/linux/security/keyring/keepassxc-keyring)
# [keyring · PyPI](https://pypi.org/project/keyring/)
# [keyring [Chuck Nemeth]](https://www.chucknemeth.com/linux/security/keyring/keyring)
# [secret-tool [Chuck Nemeth]](https://www.chucknemeth.com/linux/security/keyring/secret-tool)

# les mdp sont sotckés dans ~/.local/share/keyrings/


## regarder pour voir si on ajoute le paquet harden-doc
## chromium /usr/share/doc/harden-doc/html/fr-FR/index.html

################################################################################
## ROADMAP
##------------------------------------------------------------------------------
# - tester dans une VM après l'execution du script postinstall de modifier (réduire et augmenter) les partitions d'un LVM crypté pour voir comment cel se comporte
# - tester de faire l'instllation des apps avec apt-fast à la place de apt-get et mesurer la différence de temps d'excution du script
# - mpv a besoin de la dépendance youtube-dl sauf que la version depuis les dépots est trop vielle et donc je l'install manuellement, le problème c'est que la version dans les dépots s'installa avant la version manuel, lors de l'install de mpv. Il faudrait donc trouver un moyen de ne pas installer cette dépendance.
# regarder par exemple : [ubuntu - How do I get apt-get to ignore some dependencies? - Server Fault](https://serverfault.com/questions/250224/how-do-i-get-apt-get-to-ignore-some-dependencies#:~:text=You%20can%20try%20the%20%2D%2D,the%20option%20%2D%2Dignore%2Ddepends%20.&text=You%20can%20download%20the%20package,would%20like%20to%20be%20ignored.)
# Une autre façon de faire serrait de le laisser s'installer normallement et de faire un apt-get remove youtube-dl après l'install de mpv, normalment, ça ne casse pas les dépendances de apt.
# apt-cache depends mpv
# - essayer de comprendre pouquoi il y a parfois un certain nombre de fichier qui devrait appartenir à l'utilisaeur et qui appartiennet pourtant à l'utilisateur root, parfois, c'est des rerpertoire entier qui appartiennent à root dans .config/
# Peut être un problème dans l'utilisation de ExeAsUser ?, essayer de monitorer avec des tests.
# Si vraiment on arrive pas à comprendre pourquoi ni comment résoudre le problème simplement, alors peut être faire un chown -R $USER:$USER /home/$USER/.config/ à la fin du script
# - regarder de près concernant l'intéret de d'installer le librairie du wivedine de google dans le chromium de debian
# - ajouter le theme du gnome-terminal (https://github.com/denysdovhan/one-gnome-terminal) pour obtenir la même palette de couleur que atom
# - rajouter une variable qui contient l'usage du script pour afficher de quel manière l'utiliser lorsque d'un des arguments n'est pas correct (l'équivalent d'un --help)
# - ils ont changer l'install de FreeFileSync avec maintenant un binaire pour l'install (indice : bat -A /opt/manual_install/FreeFileSync_11.6_Install.run | more)
# - regarder pour installer timeshift (sauvegarde incrémentale de l'OS) (l'installer depuis les releases https://github.com/teejee2008/Timeshift/releases car trop vieux depuis les dépos de debian) (c'est un .deb)
# - potentiellement intégrer l'installation de l'outil xdotool
# - potentiellement instaler le paquet sysstat
# - potentiellement installer le paquet iozone3
################################################################################

################################################################################
## Log de debug (on redirige set -x dans /tmp/ng_install_set-x_logfile)
##------------------------------------------------------------------------------
exec 19>/tmp/ng_install_set-x_logfile
BASH_XTRACEFD='19'
set -x
################################################################################

#juste pour vérifier que la fonction de calcul du temps d'execution fonctionne correctement, essayer ensuite de trouver une meilleur solution et de supprimer cette ligne
systemctl restart systemd-timesyncd > /dev/null
# utilisé à des fin de stats pour l'éxecution du script
start_time="$(date +%s)"
# pose problème lorsque la date et l'heure ne sont pas à jour, il faudrait récuperer le start_time une fois la resyncro éffectué, sinon la valeur du temps d'éexecution du script est abérante

################################################################################
## Test que le script est executé en tant que root
##------------------------------------------------------------------------------
if [ $EUID != 0 ]; then
    echo "Le script doit être executer en tant que root: # sudo $0" 1>&2
    exit 1
fi
################################################################################

usage_guide() {
  cat << EOF
Usage: sudo bash $SCRIPT_NAME [OPTIONS]
Options:
  -l or --log 			Print the log file when the script terminated.
  -s or --shutdown 			Shutdown the PC when the script terminated.
  -r or --reboot 		Reboot the PC when the script terminated.
  -h or --help 			Print this message.
  -v or --version 			Print the script version.
  -pr or --pro 			Configure the PC with the PRO configuration.
  -pe or --perso 			Configure the PC with the PERSO configuration.
  Usage examples:
  $SCRIPT_NAME -e			# Execute the script and print errors in stdout.
EOF
}

################################################################################
## options d'execution du script
##------------------------------------------------------------------------------
for param in "$@"; do
    case $param in
        '-h'|'--help')
            print_usage ;;
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
        *)
            # echo 'Invalid option' ;;
            # usage_guide; exit 1 ;;
    esac
done

# [Multiple arguments using "case" : bash](https://www.reddit.com/r/bash/comments/brfsf8/multiple_arguments_using_case/)
################################################################################

# Définition des varibles de couleur
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
NOIR='\e[0;30m'

################################################################################
## création d'un fichier de log
##------------------------------------------------------------------------------
now="$(date +"%d-%m-%Y")"
log_dir='/var/log/postinstall'
[ -d "$log_dir" ] || mkdir "$log_dir"
log_file="/var/log/postinstall/log_script_install-"$now".log"
touch "$log_file"
install_file="/var/log/postinstall/install_file-"$now".log"
touch "$install_file"

echo '####################################################################' > "$log_file"
echo '#                          Debut du script                         #' >> "$log_file"
echo '####################################################################' >> "$log_file"
echo '' >> "$log_file"
echo '--------------------------------------------------------------------' >> "$log_file"
################################################################################

################################################################################
## copie du script ng_install dans /var/log
##------------------------------------------------------------------------------
cp "$(readlink -f "${BASH_SOURCE[0]}")" "$log_dir"/"$(basename "$0")"
chmod 600 "$log_dir"/"$(basename "$0")"
# on copie le contenu du script dans le répertoire $log_dir pour pouvoir savoir plus tard ce qu'il y avait dans le script au moment de son execution
# le chmod permet de s'assurer qu'il ne sera pas executer par mégarde et qu'il n'est accessible qu'en lecture pour root
# si le cp ne marche pas, tenter de faire cat "${FSLIST_TMP}" > "${FSLIST}"
################################################################################

################################################################################
## création du dossier temporaire pour l'execution du script
##------------------------------------------------------------------------------
cd
tmp_dir='/tmp/install_tmp'
[ -d "$tmp_dir" ] || mkdir "$tmp_dir"
cd "$tmp_dir"
################################################################################

################################################################################
## copie du script ng_install dans /var/log
##------------------------------------------------------------------------------
# importation des varaibles d'environnement
#source ./env.sh
SSH_Port=''
################################################################################

################################################################################
## fonction d'éxecution et d'affichage displayandexec
##------------------------------------------------------------------------------
# Premier parametre: MESSAGE
# Autres parametres: COMMAND
displayandexec() {
    local message=$1
    echo -n "[En cours] $message" && echo -n "[En cours] $message" >> "$install_file"
    shift
    echo ">>> $*" >> "$log_file" 2>&1
    bash -c "$*" >> "$log_file" 2>&1
    local ret=$?
    if [ $ret != 0 ]; then
        echo -e "\r $message                ${RED}[ERROR]${RESET} " && echo -e "\r $message                ${RED}[ERROR]${RESET} " >> "$install_file"
    else
        echo -e "\r $message                ${GREEN}[OK]${RESET} " && echo -e "\r $message                ${GREEN}[OK]${RESET} " >> "$install_file"
    fi
    # if [ $ret != 0 ]; then
    #     echo -e "\r\e[0;30m $message                ${RED}[ERROR]${RESET} " && echo -e "\r\e[0;30m $message                ${RED}[ERROR]${RESET} " >> $install_file
    # else
    #     echo -e "\r\e[0;30m $message                ${GREEN}[OK]${RESET} " && echo -e "\r\e[0;30m $message                ${GREEN}[OK]${RESET} " >> $install_file
    # fi
    # on test pour voir la différence lorsqu'on ne force pas la couleur de la police en noir pour voir ce que ça donne lorsque la couleur de fond du terminal est sombre
    return $ret
}
# la variable message récupère la valeur du premier argument passé à la fonction "le message", c'est à dire ce que l'on veut afficher à l'écran lors de l'execution du script (to stdout)
# le premier echo permet de reproduire tout ce qu'on voit dans le stdout dans le fichier $install_file
# les >>> dans le deuxième echo ne servent qu'à la présentation dans le fichier de log
# local ret=$? on défini la variable ret qui contiendra la valeur de retour de l'execution de la commande

# regarder ce que fait l'option echo -e "\r $message"
# car lorsque j'ai executer le script sans cette option, il mettait deux fois sur la même ligne le contenu de $message et ensuite le [OK]
################################################################################

################################################################################
## fonction d'éxecution et de redirection dans le fichier de log onlyexec
##------------------------------------------------------------------------------
# Premier parametre: MESSAGE
# Autres parametres: COMMAND
# regarder pour ajouter une nouvelle fonction pour ne faire que les executions et envoyer les commandes ainsi que leur résultat dans le fichier de log
# debut du commencement de réflexion :
onlyexec() {
    echo ">>> $*" >> "$log_file" 2>&1
    bash -c "$*" >> "$log_file" 2>&1
    local ret=$?
    if [ $ret != 0 ]; then
        echo -e "\r $message                ${RED}[ERROR]${RESET} " >> $install_file
    else
        echo -e "\r $message                ${GREEN}[OK]${RESET} " >> $install_file
    fi
    return $ret
}
################################################################################

# rajouter un pré-check de la taille du terminal
#exemple pour faire du strlen en BASH myvar='Généralités' && strlen=${#myvar} && echo $strlen

################################################################################
## vérification de l'espace disponnible minimum sur /
##------------------------------------------------------------------------------
check_available_space_in_root() {
  available_space="$(df --block-size=G / | awk '(NR>1){print $4}' | sed 's/.$//')"
  # peut aussi se faire en utilisant une seule redirection : "$(df --block-size=G / | awk '(NR>1){gsub(/.$/,"",$4); print $4}')"
  if [ "$available_space" -lt 10 ]; then
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      echo -e "${RED}#${RESET}  Il faut au minimum 10 Go d'espace libre pour executer le script.  ${RED}#${RESET}" | tee -a "$log_file"
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      exit 1
  fi
}
check_available_space_in_root
# On vérifie qu'il y a au minimum 10 Go de disponnible sur /
################################################################################

################################################################################
## vérification de l'espace disponnible minimum sur /var
##------------------------------------------------------------------------------
check_available_space_in_var() {
  available_space="$(df --block-size=G /var | awk '(NR>1){print $4}' | sed 's/.$//')"
  # peut aussi se faire en utilisant une seule redirection : "$(df --block-size=G /var | awk '(NR>1){gsub(/.$/,"",$4); print $4}')"
  if [ "$available_space" -lt 5 ]; then
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      echo -e "${RED}#${RESET}  Il faut au minimum 5 Go d'espace libre pour executer le script.   ${RED}#${RESET}" | tee -a "$log_file"
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      exit 1
  fi
}
check_available_space_in_var
# On vérifie qu'il y a au minimum 10 Go de disponnible sur /var
################################################################################

################################################################################
## utilisation du DNS de Cloudflare durant l'execution du script
##------------------------------------------------------------------------------
force_dns_for_install() {
cp /etc/resolv.conf /etc/resolv.conf.old && \
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
## vérification de l'accès à Internet (test avec ICMP)
##------------------------------------------------------------------------------
check_internet_access() {
  displayandexec "Vérification de la connection internet              " "ping -c 1 www.google.com"
  if [ $? != 0 ]; then
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      echo -e "${RED}#${RESET} Pour executer ce script, il faut disposer d'une connexion Internet ${RED}#${RESET}" | tee -a "$log_file"
      echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
      exit 1
  fi
}
check_internet_access
################################################################################

################################################################################
## synchronisation de l'heure et de la time zone
##------------------------------------------------------------------------------
displayandexec "Synchronisation de l'heure et de la time zone       " "systemctl restart systemd-timesyncd.service"
# voir comment faire lorsque la machine n'est pas à la bonne date et qu'elle a créer le fichier de log en se basant sur la date à laquelle elle était. regarder concernant le bon moment pour executer la commande car elle a besoin de displayandexec qui utilise notamment le fait qu'un fichier de log soit créé
################################################################################

# variable globale
uname -a | grep 'debian\|Debian' &> /dev/null
# autre version
# grep "^NAME=" /etc/os-release | grep "debian\|Debian" &> /dev/null
if [ $? == 0 ]; then
    version_linux='Debian'
else
    echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
    echo -e "${RED}#${RESET}             Ce script s'execute seulement sur Debian !             ${RED}#${RESET}" | tee -a "$log_file"
    echo -e "${RED}######################################################################${RESET}" | tee -a "$log_file"
    exit 1
fi
script_version='2.0'
system_version="$(cat /etc/debian_version)"
CURL='curl --silent --show-error'

# https://github.com/shiftkey/desktop/releases

################################################################################
## fonction qui permet de checker automatiquement les versions des logiciels qui s'installent manuellement, de façon automatique
##------------------------------------------------------------------------------
check_latest_version_manual_install_apps() {
    veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.+[[:digit:]]+)(?=-setup)')"
    # permet de récupérer la version lorsque la release est du type 'veracrypt-1.24-setup.tar.bz2'
    if [ $? != 0 ] || [ -z "$veracrypt_version" ]; then
      veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.+[[:digit:]]+-[[:alnum:]]+)(?=-setup)')"
      # permet de récupérer la version lorsque la release est du type 'veracrypt-1.24-Update7-setup.tar.bz2'
      if [ $? != 0 ] || [ -z "$veracrypt_version" ]; then
          veracrypt_version='1.24-Update7'
      fi
    fi
    # check version : https://www.veracrypt.fr/en/Downloads.html

    drawio_version="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$drawio_version" ]; then
        drawio_version='15.2.7'
    fi
    # check version : https://github.com/jgraph/drawio-desktop/releases

    # openoffice_version=$($CURL 'https://www.openoffice.org/fr/Telecharger/' | awk '/Linux/ && /deb/ && /x86-64/' | grep -Po '(?<=OpenOffice_)(\d+\.+)+\d+')
    # if [ $? != 0 ] || [ -z $openoffice_version ]; then
    #     openoffice_version='4.1.10'
    # fi
    # check version : https://www.openoffice.org/fr/Telecharger/

    freefilesync_version="$($CURL 'https://freefilesync.org/download.php' | grep 'Linux.tar.gz' | grep -Po '(?<=FreeFileSync_)(\d+\.+\d+)')"
    if [ $? != 0 ] || [ -z "$freefilesync_version" ]; then
        freefilesync_version='11.14'
    fi
    # check version : https://freefilesync.org/download.php"

    boostnote_version="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$boostnote_version" ]; then
        boostnote_version='0.16.1'
    fi
    # check version : https://github.com/BoostIO/boost-releases/releases/

    etcher_version="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$etcher_version" ]; then
        etcher_version='1.5.112'
    fi
    # check version : https://github.com/balena-io/etcher/releases/

    shotcut_version="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$shotcut_version" ]; then
        shotcut_version='21.09.20'
    fi
    shotcut_appimage="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"name": "\K.*?(?=")' | grep 'AppImage')"
    if [ $? != 0 ] || [ -z "$shotcut_appimage" ]; then
        shotcut_appimage='shotcut-linux-x86_64-210920.AppImage'
    fi
    # check version : https://github.com/mltframework/shotcut/releases/

    stacer_version="$($CURL 'https://api.github.com/repos/oguzhaninan/Stacer/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$stacer_version" ]; then
        stacer_version='1.1.0'
    fi
    # check version : https://github.com/oguzhaninan/Stacer/releases/

    keepassxc_version="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
    if [ $? != 0 ] || [ -z "$keepassxc_version" ]; then
        keepassxc_version='2.6.6'
    fi
    # check version : https://github.com/keepassxreboot/keepassxc/releases/

    bat_version="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$bat_version" ]; then
        bat_version='0.18.3'
    fi
    # check version : https://github.com/sharkdp/bat/releases/

    youtubedl_version="$($CURL 'https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
    if [ $? != 0 ] || [ -z "$youtubedl_version" ]; then
        youtubedl_version='2021.06.06'
    fi
    # check version : https://github.com/ytdl-org/youtube-dl/releases/

    joplin_version="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$joplin_version" ]; then
        joplin_version='2.3.5'
    fi
    # check version : https://github.com/laurent22/joplin/releases/

    krita_version="$($CURL 'https://krita.org/fr/telechargement/krita-desktop/' | grep 'stable' | grep 'appimage>' | grep -Po '(?<=/stable/krita/)(\d+\.+\d\.\d+)')"
    if [ $? != 0 ] || [ -z "$krita_version" ]; then
        krita_version='4.4.8'
    fi
    # check version : https://krita.org/fr/telechargement/krita-desktop/

    opensnitch_stable_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$opensnitch_stable_version" ]; then
        opensnitch_stable_version='1.4.0'
    fi
    # check version : https://github.com/evilsocket/opensnitch/releases/

    opensnitch_latest_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases' | grep -m 1 -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$opensnitch_latest_version" ]; then
        opensnitch_latest_version='1.4.0-rc.2'
    fi
    # check version : https://github.com/evilsocket/opensnitch/releases/

    hashcat_version="$($CURL 'https://api.github.com/repos/hashcat/hashcat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
    if [ $? != 0 ] || [ -z "$hashcat_version" ]; then
        hashcat_version='6.2.4'
    fi
    # check version : https://github.com/hashcat/hashcat/releases/

    winscp_version="$($CURL 'https://winscp.net/eng/downloads.php' | grep 'Portable.zip' | grep -Po '(?<=WinSCP-)([[:digit:]]+\.+[[:digit:]]+\.[[:digit:]]+)(?=-Portable.zip")')"
    if [ $? != 0 ] || [ -z "$winscp_version" ]; then
        winscp_version='5.19.2'
    fi
    # check version : https://winscp.net/eng/downloads.php
}

# tester la commande ci-dessous pour aller chercher les dernière versions directement depuis Github
# apt-get install -y jq
# $CURL https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | jq .name -r
# OU
# $CURL https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | grep -Po '"tag_name": "\K.*?(?=")'
# OU pour enlever le v :
# $CURL https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-
# parfois le .name n'est pas la variable qui contient la version et des fois c'est dans tag_name, il faut alors mettre jq .tag_name -r
# OU alors on récupère le lien directement du .deb avec la commande suivante
# $CURL https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | jq -r '.assets[2].browser_download_url'
# il faut changer la valeur dans assets[2] pour alterner entre les différents liens dispos (.deb, .rpm, .AppImage, ...)
# OU
# curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
    # | grep "browser_download_url.*deb" \
    # | cut -d '"' -f 4 \
    # | wget -qi -
################################################################################

################################################################################
## Pour obtenir un listing des logiciels avec les dernières versions disponnibles
##------------------------------------------------------------------------------
CURL='curl --silent --show-error'
manual_check_latest_version() {
  veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.+[[:digit:]]+)(?=-setup)')"
  # permet de récupérer la version lorsque la release est du type 'veracrypt-1.24-setup.tar.bz2'
  if [ $? != 0 ] || [ -z "$veracrypt_version" ]; then
    veracrypt_version="$($CURL 'https://www.veracrypt.fr/en/Downloads.html' | grep 'tar.bz2' | grep -v '.sig\|x86\|Source\|freebsd' | grep -Po '(?<=veracrypt-)([[:digit:]]+\.+[[:digit:]]+-[[:alnum:]]+)(?=-setup)')"
  fi
  echo 'VeraCrypt '"$veracrypt_version"
  drawio_version="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'drawio '"$drawio_version"
  openoffice_version="$($CURL 'https://www.openoffice.org/fr/Telecharger/' | awk '/Linux/ && /deb/ && /x86-64/' | grep -Po '(?<=OpenOffice_)(\d+\.+)+\d+')"
  echo 'OpenOffice '"$openoffice_version"
  freefilesync_version="$($CURL 'https://freefilesync.org/download.php' | grep 'Linux.tar.gz' | grep -Po '(?<=FreeFileSync_)(\d+\.+\d)+\d')"
  echo 'FreeFileSync '"$freefilesync_version"
  boostnote_version="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'Boosnote '"$boostnote_version"
  etcher_version="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'Etcher '"$etcher_version"
  shotcut_version="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'Shotcut '"$shotcut_version"
  stacer_version="$($CURL 'https://api.github.com/repos/oguzhaninan/Stacer/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'Stacer '"$stacer_version"
  keepassxc_version="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  echo 'KeePassXC '"$keepassxc_version"
  youtubedl_version="$($CURL 'https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  echo 'youtube-dl '"$youtubedl_version"
  bat_version="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'bat '"$bat_version"
  joplin_version="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'Joplin '"$joplin_version"
  krita_version="$($CURL 'https://krita.org/fr/telechargement/krita-desktop/' | grep 'stable' | grep 'appimage>' | grep -Po '(?<=/stable/krita/)(\d+\.+\d\.\d+)')"
  echo 'Krita '"$krita_version"
  opensnitch_stable_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'OpenSnitch stable '"$opensnitch_stable_version"
  opensnitch_latest_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases' | grep -m 1 -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'OpenSnitch latest (dev) '"$opensnitch_latest_version"
  hashcat_version="$($CURL 'https://api.github.com/repos/hashcat/hashcat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  echo 'hashcat '"$hashcat_version"
  winscp_version="$($CURL 'https://winscp.net/eng/downloads.php' | grep 'Portable.zip' | grep -Po '(?<=WinSCP-)([[:digit:]]+\.+[[:digit:]]+\.[[:digit:]]+)(?=-Portable.zip")')"
  echo 'WinSCP '"$winscp_version"
}
# manual_check_latest_version
################################################################################

local_user="$(awk -F':' '/1000/{print $1}' /etc/passwd)"
# peut aussi se faire avec "$(grep '1000' /etc/passwd | cut -d: -f 1)"
# autre méthode pour obtenir le user, lorsqu'il est à l'origine de la session en cour : "$(who | awk 'FNR == 1 {print $1}')"
# on peut potentiellemnt remplacer la valeur 1000 par le retour de la commande "$(cat /proc/self/loginuid)"
local_user_UID="$(id -u "$local_user")"
gnome_shell_extension_path="/home/"$local_user"/.local/share/gnome-shell/extensions"
ExeAsUser="sudo -u "$local_user""
AGI='apt-get install -y'
AG='apt-get'
WGET='wget -q'
computer_proc_architecture="$(uname -r | grep -Po '.*-\K.*')" # peut aussi se faire avec : "$(uname -r | /usr/bin/cut -d '-' -f 3)"
network_int_name="$(awk 'NR==1,/default/ {print $5}' <(ip route))"
# on remplace l'ancienne commande par celle qui prend le retour de ip route car celle ci permet d'éviter les cas ou il y a plusieurs interfaces qui commencent par en et de prendre en priorité celle qui est utilisé pour se connecter à la default gateway, en admettant donc que ce sois l'interface principale. Cela permet aussi de récupérer le nom de l'interface lorsque c'est une interface wifi
# ancienne commande qui faisait le travail : $(ip addr | grep 'UP' | cut -d " " -f 2 | cut -d ":" -f 1 | grep 'en')
# peut potentillement se faire aussi avec ip addr | awk -F':' '/UP/ && / en/ {sub(/[[:blank:]]/,""); print $2}'
# une autre commande qui permet de se passer de la commande ip en utilisant uniquement les infos lspci et depuis /sys
# pci=`lspci  | awk '/Ethernet/{print $1}'`; find /sys/class/net ! -type d | xargs --max-args=1 realpath  | awk -v pciid=$pci -F\/ '{if($0 ~ pciid){print $NF}}'
IPv4_local_address="$(ip -o -4 addr list "$network_int_name" | awk '{print $4}' | cut -d/ -f1)"
IPv4_external_address="$(GET http://ipinfo.io/ip)"
#autres méthodes :
#IPv4_external_address=$($AG install -y curl > /dev/null && curl -s http://ipinfo.io/ip)
#wget -q http://ipinfo.io/ip && IPv4_external_address=$(cat ip)
IPv6_local_address="$(ip -o -6 addr list "$network_int_name" | grep 'fe80' | awk '{print $4}' | cut -d/ -f1)"
IPv6_external_address="$(ip -o -6 addr list "$network_int_name" | grep -v 'noprefixroute' | awk '{print $4}' | cut -d/ -f1)"
computer_RAM="$(awk '/MemTotal/{printf("%.0f", $2/1024/1024+1);}' /proc/meminfo)"
# grep "MemTotal" /proc/meminfo | awk '{print $2}' | sed -r 's/.{3}$//'
# potentiellement à remplacer avec free -g | awk '/^Mem:/{print $2}'
computer_proc="$(grep -c '^processor' /proc/cpuinfo)"
computer_proc_model_name="$(grep -Po -m 1 '^model name.*: \K.*' /proc/cpuinfo)"
computer_proc_vendor_ID="$(grep -Po -m 1 '(^vendor_id\s: )\K(.*)' /proc/cpuinfo)"
debian_release="$(lsb_release -sc)"
# peut aussi se faire avec la commande : awk -F'=' '/VERSION_CODENAME=/{print $2}' /etc/os-release

# on active le mode case insensitive de bash
shopt -s nocasematch
if [[ "$debian_release" =~ buster ]]; then
    buster=1
fi
if [[ "$debian_release" =~ bullseye ]]; then
    bullseye=1
fi
# on déscactive le mode case insensitive de bash
shopt -u nocasematch


################################################################################
## désactivation de la mise en veille automatique pendant l'installation
##------------------------------------------------------------------------------
# désactivation de l'écran noir
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write /org/gnome/desktop/session/idle-delay "'uint32 0'"
# désactivation de la mise en veille automatique sur batterie
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'nothing'"
# désactivation de la mise en veille automatique sur cable
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"
################################################################################

clear
echo ''
echo ''
echo '       ################################################################'
echo '       #            LANCEMENT DU SCRIPT DEBIAN_POSTINSTALL            #'
echo '       ################################################################'
echo ''
echo ''
echo '       ================================================================'
echo ''
echo '                   nom du script       : DEBIAN_POSTINSTALL            '
echo '                   auteur              : NRGLine4Sec                   '
echo '                   version             : '"$script_version"
echo '                   lancement du script : sudo bash ng_install.sh       '
echo '                   version du système  : '"$version_linux" "$system_version"
echo '                   architecture CPU    : '"$computer_proc_architecture"
echo '                   nombre de coeur CPU : '"$computer_proc"
echo '                   adresse IPv4 local  : '"$IPv4_local_address"
echo '                   adresse IPv4 extern : '"$IPv4_external_address"
if [ "$IPv6_local_address" ]; then
    echo '                   adresse IPv6 local  : '"$IPv6_local_address"
fi
if [ "$IPv6_external_address" ]; then
    echo '                   adresse IPv6 extern : '"$IPv6_external_address"
fi
echo ''
echo '       ================================================================'
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
# /etc/init.d/unattended-upgrades status
# /etc/init.d/unattended-upgrades stop

# remise au propre de /etc/apt/sources.list
make_apt_source_list_clean_buster() {
cat> /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ $debian_release main contrib non-free
deb-src http://deb.debian.org/debian/ $debian_release main contrib non-free

deb http://security.debian.org/debian-security $debian_release/updates main contrib
deb-src http://security.debian.org/debian-security $debian_release/updates main contrib

# $debian_release-updates, previously known as 'volatile'
deb http://deb.debian.org/debian/ $debian_release-updates main contrib
deb-src http://deb.debian.org/debian/ $debian_release-updates main contrib

#backport
#deb http://deb.debian.org/debian $debian_release-backports main contrib non-free
EOF
}
# ne pas mettre les variable entre guillemet

make_apt_source_list_clean_bullseye() {
cat> /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ $debian_release main contrib non-free
deb-src http://deb.debian.org/debian/ $debian_release main contrib non-free

deb http://security.debian.org/debian-security $debian_release-security main contrib
deb-src http://security.debian.org/debian-security $debian_release-security main contrib

# $debian_release-updates, previously known as 'volatile'
deb http://deb.debian.org/debian/ $debian_release-updates main contrib non-free
deb-src http://deb.debian.org/debian/ $debian_release-updates main contrib non-free

#backport
#deb http://deb.debian.org/debian $debian_release-backports main contrib non-free
EOF
}
# ne pas mettre les variable entre guillemet

if [ "$buster" == 1 ]; then
 make_apt_source_list_clean_buster
fi
if [ "$bullseye" == 1 ]; then
  make_apt_source_list_clean_bullseye
fi

echo ''
echo '       ################################################################'
echo '       #                      MISE A JOUR DU SYSTEM                   #'
echo '       ################################################################'
echo ''

displayandexec "Mise à jour des certificats racine                  " "update-ca-certificates"

# make debian non-interactive
export DEBIAN_FRONTEND='noninteractive'

displayandexec "Mise à jour du system                               " "$AG update && $AG upgrade -y"
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

  # Solution : installer les paquets manuellement avec les bonnes config. Ensuite installer debconf-utils et faire
  # debconf-get-selections | grep nom_du_paquet
  # récupérer les infos obtenus et les injecter dans debconf-set-selections comme suit echo 'INFO' | debconf-set-selections
}
configure_debconf
################################################################################

################################################################################
## installation des logiciels
##------------------------------------------------------------------------------
echo ''
echo '       ################################################################'
echo '       #                   INSTALLATION DES LOGICIELS                 #'
echo '       ################################################################'
echo ''

# si besoin de iwlwifi
if grep '0x8086' /sys/devices/pci0000:00/*/*/ieee80211/phy0/device/vendor &> /dev/null; then
	displayandexec "Installation de firmware-iwlwifi                    " "$AGI firmware-iwlwifi"
fi

# Les commandes utiles qui m'ont aider à trouver la bonne commande pour détecter si la carte wifi est de chez Intel ou pas :
# find '/sys/devices/pci0000:00/' -type d -name 'ieee80211'
#
# grep '0x8086' /sys/devices/pci0000:00/*/*/ieee80211/phy0/device/vendor
#
# awk '!/^[[:blank:]]/ && /^8086/' /usr/share/misc/pci.ids
#
# # Pour obtenir tous les ID en fonction du fabricant
# grep -E "^[[:xdigit:]]{4}[[:blank:]]" /usr/share/misc/pci.ids

# ancienne commande utilisée (avec lspci) :
# lspci -nn | grep 'Network' | grep 'Intel' &> /dev/null
# if [ $? == 0 ]; then
#    displayandexec "Installation de firmware-iwlwifi                    " "$AGI firmware-iwlwifi"
# fi

# on active le mode case insensitive de bash
shopt -s nocasematch
if [[ "$computer_proc_vendor_ID" =~ amd ]]; then
    displayandexec "Installation de amd64-microcode                     " "$AGI amd64-microcode"
fi
if [[ "$computer_proc_vendor_ID" =~ intel ]]; then
    displayandexec "Installation de intel-microcode                     " "$AGI intel-microcode"
fi
# on déscactive le mode case insensitive de bash
shopt -u nocasematch

displayandexec "Installation de ascii                               " "$AGI ascii"
displayandexec "Installation de aria2                               " "$AGI aria2"
displayandexec "Installation de arping                              " "$AGI arping"
displayandexec "Installation de auditd                              " "$AGI auditd"
displayandexec "Installation de audacity                            " "$AGI audacity"
displayandexec "Installation de apparmor-profiles                   " "$AGI apparmor-profiles"
displayandexec "Installation de apparmor-profiles-extra             " "$AGI apparmor-profiles-extra"
displayandexec "Installation de binwalk                             " "$AGI binwalk"
displayandexec "Installation de bwm-ng                              " "$AGI bwm-ng"
displayandexec "Installation de cadaver                             " "$AGI cadaver"
displayandexec "Installation de calibre                             " "$AGI calibre"
displayandexec "Installation de chkrootkit                          " "$AGI chkrootkit"
displayandexec "Installation de chromium                            " "$AGI chromium-l10n"
displayandexec "Installation de clamav                              " "$AGI clamav clamtk clamtk-gnome libclamunrar"
displayandexec "Installation de colordiff                           " "$AGI colordiff"
displayandexec "Installation de cups                                " "$AGI cups"
displayandexec "Installation de curl                                " "$AGI curl"
displayandexec "Installation de debconf-utils                       " "$AGI debconf-utils"
displayandexec "Installation de dmidecode                           " "$AGI dmidecode"
displayandexec "Installation de dmitry                              " "$AGI dmitry"
displayandexec "Installation de dnsutils                            " "$AGI dnsutils"
displayandexec "Installation de dos2unix                            " "$AGI dos2unix"
displayandexec "Installation de ethtool                             " "$AGI ethtool"
displayandexec "Installation de ettercap-graphical                  " "$AGI ettercap-graphical"
displayandexec "Installation de evince                              " "$AGI evince"
displayandexec "Installation de filezilla                           " "$AGI filezilla"
displayandexec "Installation de firefox-esr-l10n-fr                 " "$AGI firefox-esr-l10n-fr"
displayandexec "Installation de firejail                            " "$AGI firejail"
displayandexec "Installation de flameshot                           " "$AGI flameshot"
displayandexec "Installation de freerdp2-wayland                    " "$AGI freerdp2-wayland"
displayandexec "Installation de gcc                                 " "$AGI gcc"
# displayandexec "Installation de geeqie                              " "$AGI geeqie" # installer geekie depuis le script d'install du github car la version dans les dépots de débian est beaucoup trop vielle
displayandexec "Installation de gimp                                " "$AGI gimp"
displayandexec "Installation de git                                 " "$AGI git"
displayandexec "Installation de gitk                                " "$AGI gitk"
displayandexec "Installation de gparted                             " "$AGI gparted"
displayandexec "Installation de gsmartcontrol                       " "$AGI gsmartcontrol"
displayandexec "Installation de handbrake                           " "$AGI handbrake"
displayandexec "Installation de hardinfo                            " "$AGI hardinfo"
displayandexec "Installation de htop                                " "$AGI htop"
displayandexec "Installation de hugo                                " "$AGI hugo"
displayandexec "Installation de hydra-gtk                           " "$AGI hydra-gtk"
displayandexec "Installation de icdiff                              " "$AGI icdiff"
displayandexec "Installation de iftop                               " "$AGI iftop"
displayandexec "Installation de inxi                                " "$AGI inxi"
displayandexec "Installation de inkscape                            " "$AGI inkscape"
displayandexec "Installation de iotop                               " "$AGI iotop"
displayandexec "Installation de ipcalc                              " "$AGI ipcalc"
# displayandexec "Installation de keepass2                            " "$AGI keepass2" # il est amener à ne plus être installé au fur et à mesure qu'on utilise et qu'on valide KeepassXC
displayandexec "Installation de jq                                  " "$AGI jq"
displayandexec "Installation de lnav                                " "$AGI lnav"
displayandexec "Installation de lshw                                " "$AGI lshw"
displayandexec "Installation de lynx                                " "$AGI lynx"
displayandexec "Installation de macchanger                          " "$AGI macchanger"
displayandexec "Installation de make                                " "$AGI make"
displayandexec "Installation de mediainfo-gui                       " "$AGI mediainfo-gui"
displayandexec "Installation de mpv                                 " "$AGI mpv"
displayandexec "Installation de nautilus-gtkhash                    " "$AGI nautilus-gtkhash"
displayandexec "Installation de nautilus-wipe                       " "$AGI nautilus-wipe"
displayandexec "Installation de netdiscover                         " "$AGI netdiscover"
displayandexec "Installation de network-manager-openvpn-gnome       " "$AGI network-manager-openvpn-gnome"
displayandexec "Installation de network-manager-vpnc-gnome          " "$AGI network-manager-vpnc-gnome"
displayandexec "Installation de nextcloud-desktop                   " "$AGI nextcloud-desktop"
displayandexec "Installation de ngrep                               " "$AGI ngrep"
displayandexec "Installation de nikto                               " "$AGI nikto"
displayandexec "Installation de nmap                                " "$AGI nmap"
displayandexec "Installation de nvme-cli                            " "$AGI nvme-cli"
displayandexec "Installation de oathtool                            " "$AGI oathtool"
displayandexec "Installation de openvpn                             " "$AGI openvpn"
displayandexec "Installation de p7zip-full                          " "$AGI p7zip-full"
displayandexec "Installation de p7zip-rar                           " "$AGI p7zip-rar"
displayandexec "Installation de printer-driver-all                  " "$AGI printer-driver-all"
displayandexec "Installation de python3-pip                         " "$AGI python3-pip"
displayandexec "Installation de python3-scapy                       " "$AGI python3-scapy"
displayandexec "Installation de rdesktop                            " "$AGI rdesktop"
displayandexec "Installation de rkhunter                            " "$AGI rkhunter"
displayandexec "Installation de rsync                               " "$AGI rsync"
displayandexec "Installation de secure-delete                       " "$AGI secure-delete"
displayandexec "Installation de shotwell                            " "$AGI shotwell"
displayandexec "Installation de sqlitebrowser                       " "$AGI sqlitebrowser"
displayandexec "Installation de ssh                                 " "$AGI ssh"
displayandexec "Installation de sshfs                               " "$AGI sshfs"
displayandexec "Installation de strace                              " "$AGI strace"
displayandexec "Installation de sudo                                " "$AGI sudo"
displayandexec "Installation de tcpdump                             " "$AGI tcpdump"
displayandexec "Installation de telnet                              " "$AGI telnet"
displayandexec "Installation de testdisk                            " "$AGI testdisk"
displayandexec "Installation de testssl.sh                          " "$AGI testssl.sh"
displayandexec "Installation de tree                                " "$AGI tree"
displayandexec "Installation de ufw                                 " "$AGI ufw"
displayandexec "Installation de unoconv                             " "$AGI unoconv"
displayandexec "Installation de unrar                               " "$AGI unrar"
displayandexec "Installation de vlc                                 " "$AGI vlc"
displayandexec "Installation de vpnc                                " "$AGI vpnc"
displayandexec "Installation de wget                                " "$AGI wget"
displayandexec "Installation de wine                                " "$AGI wine"
displayandexec "Installation de wine32                              " "dpkg --add-architecture i386 && $AG update ; $AGI wine32"
displayandexec "Installation de wipe                                " "$AGI wipe"
displayandexec "Installation de wireshark                           " "$AGI wireshark"
displayandexec "Installation de xinput                              " "$AGI xinput"
displayandexec "Installation de xorriso                             " "$AGI xorriso"
displayandexec "Installation de yersinia                            " "$AGI yersinia"
# displayandexec "Installation de zenmap                              " "$AGI zenmap"
# zenmap n'est pas dispo dans debian bullseye car python2 est EOL, pour traquer l'avencement du portage du code vers python3 : https://github.com/nmap/nmap/issues/1176
displayandexec "Installation de zip                                 " "$AGI zip"
displayandexec "Installation de zutils                              " "$AGI zutils"
displayandexec "Installation de zsh                                 " "$AGI zsh"
displayandexec "Installation de zstd                                " "$AGI zstd"
displayandexec "Installation de whois                               " "$AGI whois"
install_zfs_buster() {
  sed -i "s%^#deb http://deb.debian.org/debian "$debian_release"-backports%deb http://deb.debian.org/debian "$debian_release"-backports%" /etc/apt/sources.list
  displayandexec "Installation de ZFS                                 " "\
  $AG update && \
  echo 'zfs-dkms	zfs-dkms/stop-build-for-32bit-kernel	boolean	true' | debconf-set-selections && \
  echo 'zfs-dkms	zfs-dkms/note-incompatible-licenses	note' | debconf-set-selections && \
  echo 'zfs-dkms	zfs-dkms/stop-build-for-unknown-kernel	boolean	true'| debconf-set-selections && \
  $AG -t "$debian_release"-backports install -y zfsutils-linux zfs-dkms zfs-zed && \
  modprobe zfs"
  sed -i "s%^deb http://deb.debian.org/debian "$debian_release"-backports%#deb http://deb.debian.org/debian "$debian_release"-backports%" /etc/apt/sources.list && \
  $AG update
}

install_zfs_bullseye() {
  displayandexec "Installation de ZFS                                 " "\
  echo 'zfs-dkms	zfs-dkms/stop-build-for-32bit-kernel	boolean	true' | debconf-set-selections && \
  echo 'zfs-dkms	zfs-dkms/note-incompatible-licenses	note' | debconf-set-selections && \
  echo 'zfs-dkms	zfs-dkms/stop-build-for-unknown-kernel	boolean	true'| debconf-set-selections && \
  $AGI zfsutils-linux zfs-dkms zfs-zed && \
  modprobe zfs"
}

if [ "$buster" == 1 ]; then
 install_zfs_buster
fi
if [ "$bullseye" == 1 ]; then
  install_zfs_bullseye
fi


# regarder si on peut intégrer l'appel à la fonction install_zfs dans la fonction displayandexec

# la version de mkvtoolnix dans les dépots officiel est trop vielle -> install manuel
# la version de krita dans les dépots officiel est trop vielle -> install manuel
################################################################################


displayandexec "Installation des dépendances manquantes             " "$AG install -f -y"
displayandexec "Désinstalation des paquets qui ne sont plus utilisés" "$AG autoremove -y"

#//////////////////////////////////////////////////////////////////////////////#
#                       INSTALL MANUAL INSTALL APPS                            #
#//////////////////////////////////////////////////////////////////////////////#

echo '###### instalation des logiciels avec une instalation special ######'

# création du répertoire qui contiendra les logiciels avec une installation spéciale
manual_install_dir='/opt/manual_install'
mkdir "$manual_install_dir"

################################################################################
## instalation de atom
##------------------------------------------------------------------------------
install_atom_buster() {
  displayandexec "Installation des dépendances de atom                " "$AGI libgconf-2-4 gvfs-bin gconf2-common"
  displayandexec "Installation de atom                                " "\
$WGET --output-document - 'https://packagecloud.io/AtomEditor/atom/gpgkey' | apt-key add - && \
echo 'deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main' > /etc/apt/sources.list.d/atom.list && \
$AG update && \
$AGI atom"
}
install_atom_bullseye() {
  displayandexec "Installation des dépendances de atom                " "$AGI libgconf-2-4 gvfs-bin gconf2-common"
  displayandexec "Installation de atom                                " "\
$WGET --output-document - 'https://packagecloud.io/AtomEditor/atom/gpgkey' | gpg --dearmor --output /usr/share/keyrings/atom-archive-keyring.gpg && \
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/atom-archive-keyring.gpg] https://packagecloud.io/AtomEditor/atom/any/ any main' > /etc/apt/sources.list.d/atom.list && \
$AG update && \
$AGI atom"
}
################################################################################

################################################################################
## instalation de WinSCP
##------------------------------------------------------------------------------
# install_winscp() {
#   local tmp_dir="$(mktemp -d)"
#   displayandexec "Installation de WinSCP                              " "\
# mkdir "$manual_install_dir"/winscp/ && \
# $WGET -P "$tmp_dir" 'https://winscp.net/download/files/2018112321450c4c95c4f6a1a05e87651a955f47e31f/WinSCP-5.13.5-Portable.zip' && \
# unzip "$tmp_dir"/WinSCP-5.13.5-Portable.zip -d "$manual_install_dir"/winscp/ && \
# echo "wine "$manual_install_dir"/winscp/WinSCP.exe" > /usr/bin/winscp && \
# chmod +x /usr/bin/winscp
# rm -rf "$tmp_dir""
# }
# WinSCP utilise wine32 pour s'executer
# vérifier si la dernière version de WinSCP a besoin spécifiquement de wine32
################################################################################

################################################################################
## instalation de WinSCP
##------------------------------------------------------------------------------
install_winscp() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de WinSCP                              " "\
mkdir "$manual_install_dir"/winscp/ && \
$WGET -P "$tmp_dir" https://winscp.net/download/WinSCP-"$winscp_version"-Portable.zip && \
unzip "$tmp_dir"/WinSCP-"$winscp_version"-Portable.zip -d "$manual_install_dir"/winscp/ && \
echo "wine "$manual_install_dir"/winscp/WinSCP.exe" > /usr/bin/winscp && \
chmod +x /usr/bin/winscp
rm -rf "$tmp_dir""
}
# WinSCP utilise wine32 pour s'executer
# vérifier si la dernière version de WinSCP a besoin spécifiquement de wine32
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
tar -C / --no-overwrite-dir -xpzvf "$tmp_dir"/veracrypt_installer.tar
rm -rf "$tmp_dir""
# on backslash le retour de la command sed car elle est executer dans un bash -c
# https://stackoverflow.com/questions/1711970/i-cant-seem-to-use-the-bash-c-option-with-arguments-after-the-c-option-st

# ancienne version de l'URL (fonctione très bien quand la version est sous la forme 1.24)
# $WGET -P "$tmp_dir" https://launchpad.net/veracrypt/trunk/"$veracrypt_version"/+download/veracrypt-"$veracrypt_version"-setup.tar.bz2 && \
# "$(tr '[:upper:]' '[:lower:]' <<< "$veracrypt_version")" permet de corriger l'URL lorsque la version est sous la forme 1.24-Update7 car l'URL de téléchargement est comme ceci (u en lower) :
# https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-setup.tar.bz2
}
################################################################################

################################################################################
## instalation de Spotify
##------------------------------------------------------------------------------
install_spotify_buster(){
  displayandexec "Installation de spotify                             " "\
$CURL 'https://download.spotify.com/debian/pubkey_0D811D58.gpg' | apt-key add - && \
echo 'deb http://repository.spotify.com stable non-free' > /etc/apt/sources.list.d/spotify.list && \
$AG update && \
$AGI spotify-client"
}
install_spotify_bullseye() {
  displayandexec "Installation de spotify                             " "\
$CURL 'https://download.spotify.com/debian/pubkey_0D811D58.gpg' | gpg --dearmor --output /usr/share/keyrings/spotify-archive-keyring.gpg && \
echo 'deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free' > /etc/apt/sources.list.d/spotify.list && \
$AG update && \
$AGI spotify-client"
}
################################################################################

################################################################################
## instalation de apt-fast
##------------------------------------------------------------------------------
install_apt-fast() {
  displayandexec "Installation de apt-fast                            " "\
cat> /etc/apt/sources.list.d/apt-fast.list << 'EOF'
deb [arch=amd64] http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main
#deb-src http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B
$AG update
$AGI apt-fast"
}
################################################################################

################################################################################
## instalation de drawio
##------------------------------------------------------------------------------
install_drawio() {
  displayandexec "Installation de drawio                              " "\
mkdir "$manual_install_dir"/drawio/ && \
$WGET -P "$manual_install_dir"/drawio/ https://github.com/jgraph/drawio-desktop/releases/download/v"$drawio_version"/drawio-x86_64-"$drawio_version".AppImage && \
chmod +x "$manual_install_dir"/drawio/drawio-x86_64-"$drawio_version".AppImage && \
$WGET -P "$manual_install_dir"/drawio/ 'https://raw.githubusercontent.com/jgraph/drawio/master/src/main/webapp/images/drawlogo256.png'"
cat> /usr/share/applications/drawio.desktop << EOF
[Desktop Entry]
Name=draw.io
Exec=$manual_install_dir/drawio/drawio-x86_64-"$drawio_version".AppImage
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
## instalation de FreeFileSync
##------------------------------------------------------------------------------
install_freefilesync() {
  displayandexec "Installation de FreeFileSync                        " "\
$WGET -P "$tmp_dir" https://freefilesync.org/download/FreeFileSync_"$freefilesync_version"_Linux.tar.gz -O FreeFileSync_"$freefilesync_version"_Linux.tar.gz && \
tar xvf "$tmp_dir"/FreeFileSync_"$freefilesync_version"_Linux.tar.gz --directory "$manual_install_dir" && \
echo ""$manual_install_dir"/FreeFileSync/FreeFileSync" > /usr/bin/FreeFileSync && \
chmod +x /usr/bin/FreeFileSync"
cat> /usr/share/applications/freefilesync.desktop << EOF
[Desktop Entry]
Type=Application
Name=FreeFileSync
GenericName=Folder Comparison and Synchronization
Exec=$manual_install_dir/FreeFileSync/FreeFileSync %F
Icon=$manual_install_dir/FreeFileSync/Resources/FreeFileSync.png
NoDisplay=false
Terminal=false
Categories=Utility;FileTools;
StartupNotify=true
EOF
}
# Pour faire les nouvelles install avec freefilesynx :
# tar xvf "$tmp_dir"/FreeFileSync_"$freefilesync_version"_Linux.tar.gz --directory "$tmp_dir" && \
# Pour l'instant on est obligé de faire un chown -R $local_user:$local_user "$manual_install_dir"/FreeFileSync sinon le bianire ne s'installe pas
# $ExeAsUser "$tmp_dir"/FreeFileSync_11.10_Install.run --accept-license --skip-overview --for-all-users false --directory "$manual_install_dir"/FreeFileSync
# il faudra potentiellemnt supprimer /home/$local_user/.profile qui est créé lors de l'install de FreeFileSync et qui permet  priori de renseigner le path pour l'execution des commande qui lancent les binaires de FreeFileSync (/home/$local_user/.local/bin)
################################################################################

################################################################################
## instalation de Boostnote
##------------------------------------------------------------------------------
install_boostnote() {
  displayandexec "Installation des dépendances de Boostnote           " "$AGI gconf2 gconf-service"
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Boostnote                           " "\
$WGET -P "$tmp_dir" https://github.com/BoostIO/boost-releases/releases/download/v"$boostnote_version"/boostnote_"$boostnote_version"_amd64.deb && \
dpkg -i "$tmp_dir"/boostnote_"$boostnote_version"_amd64.deb
rm -rf "$tmp_dir""
}
################################################################################

################################################################################
## instalation de Typora
##------------------------------------------------------------------------------
install_typora_buster() {
  displayandexec "Installation des dépendances de Typora              " "\
cat> /etc/apt/sources.list.d/typora.list << 'EOF'
deb https://typora.io/linux ./
# deb-src https://typora.io/linux ./
EOF
$WGET --output-document - 'https://typora.io/linux/public-key.asc' | apt-key add - && \
$AG update && \
$AGI typora"
}
install_typora_bullseye() {
  displayandexec "Installation de Typora                              " "\
cat> /etc/apt/sources.list.d/typora.list << 'EOF'
deb [signed-by=/usr/share/keyrings/typora-archive-keyring.gpg] https://typora.io/linux ./
# deb-src https://typora.io/linux ./
EOF
$WGET --output-document - 'https://typora.io/linux/public-key.asc' | gpg --dearmor --output /usr/share/keyrings/typora-archive-keyring.gpg && \
$AG update && \
$AGI typora"
}
################################################################################

################################################################################
## instalation de VirtualBox
##------------------------------------------------------------------------------
install_virtualbox_buster() {
  displayandexec "Installation des dépendances de VirtualBox          " "$AGI dkms"
  displayandexec "Installation de VirtualBox                          " "\
echo 'deb https://download.virtualbox.org/virtualbox/debian buster contrib' > /etc/apt/sources.list.d/virtualbox.list && \
$WGET --output-document - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | apt-key add - && \
$WGET --output-document - 'https://www.virtualbox.org/download/oracle_vbox.asc' | apt-key add - && \
$AG update && \
$AGI virtualbox-6.1"
  # virtualbox_version=$(virtualbox --help | grep v[0-9] | cut -c 35-) # ancienne version
  virtualbox_version="$(virtualbox --help | grep -Po ' v\K\d+.\d+.\d+')"
  displayandexec "Installation de VM VirtualBox Extension Pack        " "\
$WGET -P "$tmp_dir" https://download.virtualbox.org/virtualbox/"$virtualbox_version"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack && \
echo y | /usr/bin/VBoxManage extpack install --replace "$tmp_dir"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack"
  # Une solution qui devrait marché mais il faut avoir le hachage de la licence pour pouvoir l'executer et on obtient le hachage qu'en lançant une première fois la commande
  # VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-$virtualbox_version.vbox-extpack --accept-license --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb
  # https://www.virtualbox.org/ticket/16674
  # Pour lister les extensions virutlabox une fois l'installation terminé : VBoxManage list extpacks
  # VBoxManage list extpacks

  configure_SecureBoot_params() {
      # création du dossier qui contiendra les signatures pour le SecureBoot
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
openssl req -new -x509 -newkey rsa:2048 -keyout vboxdrv.priv -outform DER -out vboxdrv.der -nodes -days 36500 -subj "/CN=vboxdrv/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxdrv.priv ./vboxdrv.der /lib/modules/$UNAMER/misc/vboxdrv.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetflt.priv -outform DER -out vboxnetflt.der -nodes -days 36500 -subj "/CN=vboxnetflt/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxnetflt.priv ./vboxnetflt.der /lib/modules/$UNAMER/misc/vboxnetflt.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetadp.priv -outform DER -out vboxnetadp.der -nodes -days 36500 -subj "/CN=vboxnetadp/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxnetadp.priv ./vboxnetadp.der /lib/modules/$UNAMER/misc/vboxnetadp.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxpci.priv -outform DER -out vboxpci.der -nodes -days 36500 -subj "/CN=vboxpci/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxpci.priv ./vboxpci.der /lib/modules/$UNAMER/misc/vboxpci.ko
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

  # test qui vérifie l'activation du SecureBoot
  if command -v mokutil > /dev/null; then
      test_secure_boot="$(mokutil --sb-state 2> /dev/null | grep 'SecureBoot')"
      if [ "$test_secure_boot" == 'SecureBoot enabled' ]; then
          configure_SecureBoot_params
          # displayandexec "Install du script pour signer module (SecureBoot)   " "$AGI dkms"
      fi
  fi
}

install_virtualbox_bullseye() {
  displayandexec "Installation des dépendances de VirtualBox          " "$AGI dkms"
  displayandexec "Installation de VirtualBox                          " "\
echo 'deb [signed-by=/usr/share/keyrings/virtualbox-archive-keyring.gpg] https://download.virtualbox.org/virtualbox/debian bullseye contrib' > /etc/apt/sources.list.d/virtualbox.list && \
$WGET --output-document - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | gpg --dearmor --output /usr/share/keyrings/virtualbox-archive-keyring.gpg && \
$AG update && \
$AGI virtualbox-6.1"
  # virtualbox_version=$(virtualbox --help | grep v[0-9] | cut -c 35-) # ancienne version
  virtualbox_version="$(virtualbox --help | grep -Po ' v\K\d+.\d+.\d+')"
  displayandexec "Installation de VM VirtualBox Extension Pack        " "\
$WGET -P "$tmp_dir" https://download.virtualbox.org/virtualbox/"$virtualbox_version"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack && \
echo y | /usr/bin/VBoxManage extpack install --replace "$tmp_dir"/Oracle_VM_VirtualBox_Extension_Pack-"$virtualbox_version".vbox-extpack"
  # Une solution qui devrait marché mais il faut avoir le hachage de la licence pour pouvoir l'executer et on obtient le hachage qu'en lançant une première fois la commande
  # VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-$virtualbox_version.vbox-extpack --accept-license --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb
  # https://www.virtualbox.org/ticket/16674
  # Pour lister les extensions virutlabox une fois l'installation terminé : VBoxManage list extpacks
  # VBoxManage list extpacks

  configure_SecureBoot_params() {
      # création du dossier qui contiendra les signatures pour le SecureBoot
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
openssl req -new -x509 -newkey rsa:2048 -keyout vboxdrv.priv -outform DER -out vboxdrv.der -nodes -days 36500 -subj "/CN=vboxdrv/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxdrv.priv ./vboxdrv.der /lib/modules/$UNAMER/misc/vboxdrv.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetflt.priv -outform DER -out vboxnetflt.der -nodes -days 36500 -subj "/CN=vboxnetflt/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxnetflt.priv ./vboxnetflt.der /lib/modules/$UNAMER/misc/vboxnetflt.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxnetadp.priv -outform DER -out vboxnetadp.der -nodes -days 36500 -subj "/CN=vboxnetadp/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxnetadp.priv ./vboxnetadp.der /lib/modules/$UNAMER/misc/vboxnetadp.ko
openssl req -new -x509 -newkey rsa:2048 -keyout vboxpci.priv -outform DER -out vboxpci.der -nodes -days 36500 -subj "/CN=vboxpci/"
/usr/src/linux-headers-$UNAMER/scripts/sign-file sha256 ./vboxpci.priv ./vboxpci.der /lib/modules/$UNAMER/misc/vboxpci.ko
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

  # test qui vérifie l'activation du SecureBoot
  if command -v mokutil > /dev/null; then
      test_secure_boot="$(mokutil --sb-state 2> /dev/null | grep 'SecureBoot')"
      if [ "$test_secure_boot" == 'SecureBoot enabled' ]; then
          configure_SecureBoot_params
          # displayandexec "Install du script pour signer module (SecureBoot)   " "$AGI dkms"
      fi
  fi
}
################################################################################

################################################################################
## instalation de KeePassXC
##------------------------------------------------------------------------------
install_keepassxc() {
  displayandexec "Installation de KeePassXC                           " "\
$WGET -P "$manual_install_dir"/KeePassXC/ https://github.com/keepassxreboot/keepassxc/releases/download/"$keepassxc_version"/KeePassXC-"$keepassxc_version"-x86_64.AppImage && \
$WGET -P "$manual_install_dir"/KeePassXC/ 'https://keepassxc.org/images/keepassxc-logo.svg' && \
chmod +x "$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage"
cat> /usr/share/applications/keepassxc.desktop << EOF
[Desktop Entry]
Comment=Password Manager
Terminal=false
Name=KeePassXC
Exec=$manual_install_dir/KeePassXC/KeePassXC-$keepassxc_version-x86_64.AppImage
Type=Application
Icon=$manual_install_dir/KeePassXC/keepassxc-logo.svg
Categories=Utility;Security;Qt;
MimeType=application/x-keepass2;
X-GNOME-Autostart-enabled=true' > /usr/share/applications/keepassxc.desktop
EOF
}
################################################################################

################################################################################
## instalation de MKVToolNix
##------------------------------------------------------------------------------
install_mkvtoolnix_buster() {
  displayandexec "Installation de MKVToolNix                          " "\
cat> /etc/apt/sources.list.d/mkvtoolnix.download.list << 'EOF'
deb https://mkvtoolnix.download/debian/ buster main
#deb-src https://mkvtoolnix.download/debian/ buster main
EOF
$WGET --output-document - 'https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt' | apt-key add - && \
$AG update && \
$AGI mkvtoolnix mkvtoolnix-gui"
}
install_mkvtoolnix_bullseye() {
  displayandexec "Installation de MKVToolNix                          " "\
cat> /etc/apt/sources.list.d/mkvtoolnix.download.list << 'EOF'
deb [signed-by=/usr/share/keyrings/mkvtoolnix-archive-keyring.gpg] https://mkvtoolnix.download/debian/ bullseye main
#deb-src https://mkvtoolnix.download/debian/ bullseye main
EOF
$WGET --output-document - 'https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt' | gpg --dearmor --output /usr/share/keyrings/mkvtoolnix-archive-keyring.gpg && \
$AG update && \
$AGI mkvtoolnix mkvtoolnix-gui"
}
################################################################################

################################################################################
## instalation de Etcher
##------------------------------------------------------------------------------
install_etcher() {
  displayandexec "Installation de Etcher                              " "\
mkdir "$manual_install_dir"/balenaEtcher/ && \
$WGET -P "$manual_install_dir"/balenaEtcher/ https://github.com/balena-io/etcher/releases/download/v"$etcher_version"/balenaEtcher-"$etcher_version"-x64.AppImage && \
$WGET -P "$manual_install_dir"/balenaEtcher/ 'https://github.com/balena-io/etcher/raw/master/assets/icon.png' && \
chmod +x "$manual_install_dir"/balenaEtcher/balenaEtcher-"$etcher_version"-x64.AppImage"
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
mkdir "$manual_install_dir"/shotcut/ && \
$WGET -P "$manual_install_dir"/shotcut/ https://github.com/mltframework/shotcut/releases/download/v"$shotcut_version"/"$shotcut_appimage" && \
chmod +x "$manual_install_dir"/shotcut/"$shotcut_appimage" && \
ln -s "$manual_install_dir"/shotcut/"$shotcut_appimage" /usr/bin/shotcut"
}
################################################################################

################################################################################
## instalation de Signal
##------------------------------------------------------------------------------
install_signal_buster() {
  displayandexec "Installation de Signal                              " "\
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' > /etc/apt/sources.list.d/signal-xenial.list && \
$CURL 'https://updates.signal.org/desktop/apt/keys.asc' | apt-key add - && \
$AG update && \
$AGI signal-desktop"
}
install_signal_bullseye() {
  displayandexec "Installation de Signal                              " "\
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-archive-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' > /etc/apt/sources.list.d/signal-xenial.list && \
$CURL 'https://updates.signal.org/desktop/apt/keys.asc' | gpg --dearmor --output /usr/share/keyrings/signal-archive-keyring.gpg && \
$AG update && \
$AGI signal-desktop"
}
################################################################################

################################################################################
## instalation de Stacer
##------------------------------------------------------------------------------
install_stacer() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Stacer                              " "\
$WGET -P "$tmp_dir" https://github.com/oguzhaninan/Stacer/releases/download/v"$stacer_version"/stacer_"$stacer_version"_amd64.deb && \
dpkg -i "$tmp_dir"/stacer_"$stacer_version"_amd64.deb
rm -rf "$tmp_dir""
}
################################################################################

################################################################################
## instalation de asbru
##------------------------------------------------------------------------------
install_asbru_buster() {
  displayandexec "Installation des dépendances de Asbru               " "$AGI perl libvte-2.91-0 libcairo-perl libglib-perl libpango-perl libsocket6-perl libexpect-perl libnet-proxy-perl libyaml-perl libcrypt-cbc-perl libcrypt-blowfish-perl libgtk3-perl libnet-arp-perl libossp-uuid-perl openssh-client telnet ftp libcrypt-rijndael-perl libxml-parser-perl libcanberra-gtk-module dbus-x11 libx11-guitest-perl libgtk3-simplelist-perl gir1.2-wnck-3.0 gir1.2-vte-2.91"
  displayandexec "Installation de Asbru                               " "\
cat> /etc/apt/sources.list.d/asbru-cm_asbru-cm.list << 'EOF'
# this file was generated by packagecloud.io for
# the repository at https://packagecloud.io/asbru-cm/asbru-cm

deb [arch=amd64] https://packagecloud.io/asbru-cm/asbru-cm/debian/ buster main
#deb-src https://packagecloud.io/asbru-cm/asbru-cm/debian/ buster main
EOF
$CURL --location 'https://packagecloud.io/asbru-cm/asbru-cm/gpgkey' | apt-key add - && \
$AG update && \
$AGI asbru-cm"
}
install_asbru_bullseye() {
  displayandexec "Installation des dépendances de Asbru               " "$AGI perl libvte-2.91-0 libcairo-perl libglib-perl libpango-perl libsocket6-perl libexpect-perl libnet-proxy-perl libyaml-perl libcrypt-cbc-perl libcrypt-blowfish-perl libgtk3-perl libnet-arp-perl libossp-uuid-perl openssh-client telnet ftp libcrypt-rijndael-perl libxml-parser-perl libcanberra-gtk-module dbus-x11 libx11-guitest-perl libgtk3-simplelist-perl gir1.2-wnck-3.0 gir1.2-vte-2.91"
  displayandexec "Installation de Asbru                               " "\
cat> /etc/apt/sources.list.d/asbru-cm_asbru-cm.list << 'EOF'
# this file was generated by packagecloud.io for
# the repository at https://packagecloud.io/asbru-cm/asbru-cm

deb [arch=amd64 signed-by=/usr/share/keyrings/asbru-archive-keyring.gpg] https://packagecloud.io/asbru-cm/asbru-cm/debian/ buster main
#deb-src https://packagecloud.io/asbru-cm/asbru-cm/debian/ buster main
EOF
$CURL --location 'https://packagecloud.io/asbru-cm/asbru-cm/gpgkey' | gpg --dearmor --output /usr/share/keyrings/asbru-archive-keyring.gpg && \
$AG update && \
$AGI asbru-cm"
}
################################################################################

################################################################################
## instalation de bat
##------------------------------------------------------------------------------
install_bat() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Bat                                 " "\
$WGET -P "$tmp_dir" https://github.com/sharkdp/bat/releases/download/v"$bat_version"/bat_"$bat_version"_amd64.deb && \
dpkg -i "$tmp_dir"/bat_"$bat_version"_amd64.deb
rm -rf "$tmp_dir""
}
################################################################################

################################################################################
## instalation de youtube-dl
##------------------------------------------------------------------------------
install_youtubedl() {
  displayandexec "Installation de youtube-dl                          " "\
$WGET -P /usr/bin https://github.com/ytdl-org/youtube-dl/releases/download/"$youtubedl_version"/youtube-dl && \
chmod +x /usr/bin/youtube-dl"
}
################################################################################

################################################################################
## instalation de joplin
##------------------------------------------------------------------------------
install_joplin() {
  displayandexec "Installation de joplin                              " "\
mkdir "$manual_install_dir"/Joplin/ && \
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
mkdir "$manual_install_dir"/Krita/ && \
$WGET -P "$manual_install_dir"/Krita/ https://download.kde.org/stable/krita/"$krita_version"/krita-"$krita_version"-x86_64.appimage && \
chmod +x "$manual_install_dir"/Krita/krita-"$krita_version"-x86_64.appimage"
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
Icon=calligrakrita
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
  $AGI python3-pyqt5.qtsql python3-pyinotify python3-grpcio python3-slugify && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_latest_version"/python3-opensnitch-ui_"$(sed -e 's/\.//3' -e 's/-/\./' <<< "$opensnitch_latest_version")"-1_all.deb && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_latest_version"/opensnitch_"$(sed -e 's/\.//3' -e 's/-/\./' <<< "$opensnitch_latest_version")"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/opensnitch_"$(sed -e 's/\.//3' -e 's/-/\./' <<< "$opensnitch_latest_version")"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/python3-opensnitch-ui_"$(sed -e 's/\.//3' -e 's/-/\./' <<< "$opensnitch_latest_version")"-1_all.deb && \
  $AG install -f -y
  rm -rf "$tmp_dir""
}
# l'installation de OpenSnitch est intérecatif mais n'utilise pas d'entrés dans debconf-set-selections
# potentiellement qu'on peut corriger le problème avec debian non-interractive

# attention, il y a un soucis dans la gestion de la valeur de la version par rapport au lien qu'il faut utiliser pour téléchrager les .deb
# il y a un point qui est présent dans la valeur de la version mais qui ne l'est pas dans la deuxième partie de l'URL
# par exemple avec un numéro de version 1.4.0-rc.2 la deuxième partie qui est utilisé dans l'URL est 1.4.0-rc2
# c'est pour ça qu'on est obligé d'utiliser "$(sed 's/\.//3' <<< "$opensnitch_latest_version")" pour la deuxième partie de l'URL
################################################################################

################################################################################
## instalation de Ansible
##------------------------------------------------------------------------------
install_ansible_buster() {
  displayandexec "Installation de Ansible                             " "\
echo 'deb [arch=amd64] http://ppa.launchpad.net/ansible/ansible-4/ubuntu bionic main' > /etc/apt/sources.list.d/ansible.list && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
$AG update && \
$AGI ansible"
$ExeAsUser cat>> /home/"$local_user"/.bashrc << 'EOF'

# for Ansible vault editor
export EDITOR=nano
EOF
}
install_ansible_bullseye() {
  displayandexec "Installation de Ansible                             " "\
echo 'deb [arch=amd64] http://ppa.launchpad.net/ansible/ansible-4/ubuntu focal main' > /etc/apt/sources.list.d/ansible.list && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
$AG update && \
$AGI ansible"
$ExeAsUser cat>> /home/"$local_user"/.bashrc << 'EOF'

# for Ansible vault editor
export EDITOR=nano
EOF
}
# echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] deb http://ppa.launchpad.net/ansible/ansible-4/ubuntu focal main' > /etc/apt/sources.list.d/ansible.list && \
# $CURL '' | gpg --dearmor --output /usr/share/keyrings/ansible-archive-keyring.gpg && \
################################################################################

################################################################################
## instalation de Hashcat
##------------------------------------------------------------------------------
install_hashcat() {
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de Hashcat                             " "\
$WGET -P "$tmp_dir" https://github.com/hashcat/hashcat/releases/download/v"$hashcat_version"/hashcat-"$hashcat_version".7z && \
mkdir "$manual_install_dir"/hashcat && \
7z x "$tmp_dir"/hashcat-"$hashcat_version".7z -o"$manual_install_dir"/hashcat && \
chown -R "$local_user":"$local_user" "$manual_install_dir"/hashcat && \
ln -s "$manual_install_dir"/hashcat/hashcat-"$hashcat_version"/hashcat.bin /usr/bin/hashcat && \
rm -rf "$tmp_dir""
# hashcat a besoin d'être capable d'écrire dans son répertoire, il faut donc soit associ le répertoire à l'utilisateur soit le lancer en sudo
}
################################################################################

################################################################################
## instalation de sshuttle
##------------------------------------------------------------------------------
install_sshuttle() {
  displayandexec "Installation de sshuttle                            " "\
  pip3 install sshuttle"
}
# ref : [sshuttle · PyPI](https://pypi.org/project/sshuttle/)
# on l'install pour l'utilisateur root car sshuttle sera executer en sudo
################################################################################

check_latest_version_manual_install_apps

install_all_manual_install_apps_buster() {
  install_atom_buster
  install_winscp
  install_veracrypt
  install_spotify_buster
  install_apt-fast
  install_drawio
  install_freefilesync
  install_boostnote
  install_typora_buster
  install_virtualbox_buster
  install_keepassxc
  install_mkvtoolnix_buster
  install_etcher
  install_shotcut
  install_signal_buster
  install_stacer
  install_asbru_buster
  install_bat
  install_youtubedl
  install_joplin
  install_krita
  install_opensnitch
  install_ansible_buster
  install_hashcat
  install_sshuttle
}
install_all_manual_install_apps_bullseye() {
  install_atom_bullseye
  install_winscp
  install_veracrypt
  install_spotify_bullseye
  install_apt-fast
  install_drawio
  install_freefilesync
  install_boostnote
  install_typora_bullseye
  install_virtualbox_bullseye
  install_keepassxc
  install_mkvtoolnix_bullseye
  install_etcher
  install_shotcut
  install_signal_bullseye
  install_stacer
  install_asbru_bullseye
  install_bat
  install_youtubedl
  install_joplin
  install_krita
  install_opensnitch
  install_ansible_bullseye
  install_hashcat
  install_sshuttle
}

if [ "$buster" == 1 ]; then
 install_all_manual_install_apps_buster
fi
if [ "$bullseye" == 1 ]; then
  install_all_manual_install_apps_bullseye
fi
################################################################################

################################################################################
## désinstalation des logicels inutils
##------------------------------------------------------------------------------
echo "############### désinstalation des logicels inutils ###############"
#Konqueror
displayandexec "Désinstalation de Konqueror                         " "$AG remove -y Konqueror*"

#iceweasel
displayandexec "Désinstalation de iceweasel                         " "$AG remove -y iceweasel*"

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

#exim4
displayandexec "Désinstalation de exim4                             " "$AG remove -y exim4-base exim4-config exim4-daemon-light"

#libreoffice
#displayandexec "désinstalation de libreoffice                       " "$AG remove libreoffice* -y"
################################################################################

#OpenOffice
# displayandexec "Installation de OpenOffice                          " "\
# $WGET http://sourceforge.net/projects/openofficeorg.mirror/files/"$openoffice_version"/binaries/fr/Apache_OpenOffice_"$openoffice_version"_Linux_x86-64_install-deb_fr.tar.gz && \
# tar xzf Apache_OpenOffice_"$openoffice_version"_Linux_x86-64_install-deb_fr.tar.gz && \
# cd fr/DEBS/ && \
# dpkg -i *.deb && cd desktop-integration/ && \
# dpkg -i openoffice4.1-debian-menu*.deb"

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

install_GSH_buster() {
#Screenshot Tool
install_GSH_screenshot_tool() {
  local GnomeShellExtensionUUID='gnome-shell-screenshot@ttll.de' && \
  mkdir -p "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
  $WGET -P "$tmp_dir" 'https://extensions.gnome.org/extension-data/gnome-shell-screenshotttll.de.v40.shell-extension.zip' && \
  unzip -q "$tmp_dir"/gnome-shell-screenshotttll.de.v40.shell-extension.zip -d "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
  $ExeAsUser gnome-shell-extension-tool -e "$GnomeShellExtensionUUID"
}
#system-monitor
install_GSH_system_monitor() {
  $AGI gnome-shell-extension-system-monitor && \
  $ExeAsUser gnome-shell-extension-tool -e 'system-monitor@paradoxxx.zero.gmail.com'
}
#displayandexec "Installation des Gnome Shell Extension              " "\
#"
install_GSH_screenshot_tool
install_GSH_system_monitor
}

install_GSH_bullseye() {
#Screenshot Tool
install_GSH_screenshot_tool() {
  local GnomeShellExtensionUUID='gnome-shell-screenshot@ttll.de' && \
  mkdir -p "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
  $WGET -P "$tmp_dir" 'https://extensions.gnome.org/extension-data/gnome-shell-screenshotttll.de.v40.shell-extension.zip' && \
  unzip -q "$tmp_dir"/gnome-shell-screenshotttll.de.v40.shell-extension.zip -d "$gnome_shell_extension_path"/"$GnomeShellExtensionUUID" && \
  $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable "$GnomeShellExtensionUUID"
}
#system-monitor
install_GSH_system_monitor() {
  $AGI gnome-shell-extension-system-monitor && \
  $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gnome-extensions enable 'system-monitor@paradoxxx.zero.gmail.com'
}
#displayandexec "Installation des Gnome Shell Extension              " "\
#"
install_GSH_screenshot_tool
install_GSH_system_monitor
}

if [ "$buster" == 1 ]; then
 install_GSH_buster
fi
if [ "$bullseye" == 1 ]; then
  install_GSH_bullseye
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
# zgrep -a '"uuid":' 'gnome-shell-extension.zip' | awk -F'"' '{print $4}'
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
#                            INSTALL SCRIP PERSO                               #
#//////////////////////////////////////////////////////////////////////////////#

################################################################################
## install du scrip gitupdate
##------------------------------------------------------------------------------
install_gitupdate() {
# probablement améliorer le script gitupdate avec une condition if quand la branche principal n'est pas origin master
cat> /opt/gitupdate << 'EOF'
#!/bin/bash

# store the current dir
CUR_DIR="$(pwd)"
# Find all git repositories and update it to the master latest revision
for i in "$(find / -name '.git' | cut -c 2-)"; do
    echo ''
    echo "\033[33m"+"$i"+"\033[0m"
    # We have to go to the .git parent directory to call the pull command
    cd /"$i"
    cd ..
    # finally pull
    git pull origin master
    # lets get back to the CUR_DIR
    cd "$CUR_DIR"
done

exit 0
EOF
displayandexec "Installation du script de mise à jour de repo git   " "\
chmod +x /opt/gitupdate && \
ln -s /opt/gitupdate /usr/bin/gitupdate"
}
################################################################################

################################################################################
## install du scrip sysupdateNG
##------------------------------------------------------------------------------
install_sysupdateng() {
cat> /opt/sysupdateNG << 'EOF'
#!/bin/bash

# a priori on ne peut pas executer de fonction (tel que CheckUpdate) dans l'appel de fonction displayandexec
# displayandexec "test d'execution de la fonction CheckUpdate      " "CheckUpdate" ne fonctionne pas

# essayer avec export -f CheckUpdate
# ref : [ubuntu - Bash function gives "command not found" when used within a bash script? - Super User](https://superuser.com/questions/1493404/bash-function-gives-command-not-found-when-used-within-a-bash-script)
# bon ça fonctionne mais il faudrait faire l'export de toute les fonctions, et on n'aurait pas les retours des commandes mais simplement le retour des echos

# pour executer les fonctions dans la fonction displayandexec :
# il faut les mettre sous la forme :
install_opensnitch() {
  local opensnitch_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local tmp_dir="$(mktemp -d)"
  displayandexec "Installation de OpenSnitch                          " "\
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_version"/python3-opensnitch-ui_"$opensnitch_version"-1_all.deb && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_version"/opensnitch_"$opensnitch_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/opensnitch_"$opensnitch_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/python3-opensnitch-ui_"$opensnitch_version"-1_all.deb && \
  rm -rf "$tmp_dir" && \
  $AG install -f -y"
}
# bien faire attention a déclarer les variables avant l'appel à la fonction dispalyandexec

# Définition des variables de couleur
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
NOIR='\e[0;30m'

manual_install_dir='/opt/manual_install'
AG='apt-get'
WGET='wget -q'
CURL='curl --silent --show-error'
local_user="$(awk -F':' '/1000/{print $1}' /etc/passwd)"
ExeAsUser="sudo -u "$local_user""
now="$(date +"%d-%m-%Y")"
[ -d /var/log/sysupdate ] || mkdir /var/log/sysupdate
log_file="/var/log/sysupdate/update-"$now".log"
touch "$log_file"

# Premier parametre: MESSAGE
# Autres parametres: COMMAND
displayandexec() {
  local message=$1
  echo -n "[En cours] $message"
  shift
  echo ">>> $*" >> "$log_file" 2>&1
  bash -c "$*" >> "$log_file" 2>&1
  local ret=$?
  if [ $ret != 0 ]; then
    echo -e "\r $message                ${RED}[ERROR]${RESET} "
  else
    echo -e "\r $message                ${GREEN}[OK]${RESET} "
  fi
  return $ret
}

displayandexec "Mise à jour des paquets debian                      " "$AG update && $AG upgrade -y"
# displayandexec "Mise à jour de la base de donnée de rkhunter        " "rkhunter --versioncheck && rkhunter --update && rkhunter --propupd"
displayandexec "Mise à jour des paquets de pip3                     " "$ExeAsUser pip3 install --upgrade pip"
displayandexec "Suppression du cache de apt-get                     " "$AG clean"

# if [ $1 = "--log" ]; then
#     more "$log_file"
# else
#     exit 0
# fi


################################################################################

CheckAvailableUpdate() {
  local PREFIX_1="$(echo $2 | sed -e 's/[a-z]//' )"
  local SUFFIX_1="$(echo $2 | sed -e 's/[0-9]//' )"
  local PREFIX_2="$(echo $3 | sed -e 's/[a-z]//' )"
  local SUFFIX_2="$(echo $3 | sed -e 's/[0-9]//' )"

  if [[ $PREFIX_1 > $PREFIX_2 ]] || ([[ $PREFIX_1 == $PREFIX_2 ]] && [[ $SUFFIX_1 > $SUFFIX_2 ]]); then
    # echo "$2 est plus grand que $3"
    echo "une mise à jour de $1 est disponible"
    retval=$1
  else
    echo "aucune mise à jour de $1 n'est disponible"
  fi
}
# vérifier que ça fonctionne bien avec le cas spécidifque $2=0.17.1 et $3=0.16.1
# pour faire des tests :
# [[ 2020.12.22 > 2020.12.25 ]] && echo oui || echo non
# [[ 0.17.1 > 0.16.1 ]] && echo oui || echo non

################################################################################

CheckUpdateShotcut() {
  local SoftwareName='Shotcut'
  # local v1="$(shotcut --version | cut -c 9-)"
  local v1="$(shotcut --version 2>&1 | cut -c 9- | grep -v 'Gtk-WARNING' | sed '/^$/d')"
  # pour éviter les warnings gtk
  # ref : [Ubuntu – How to stop gedit (and other programs) from outputting GTK warnings and the like in the terminal – iTecTec](https://itectec.com/ubuntu/ubuntu-how-to-stop-gedit-and-other-programs-from-outputting-gtk-warnings-and-the-like-in-the-terminal/)
  local v2="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateYoutube-dl() {
  local SoftwareName='youtube-dl'
  local v1="$(youtube-dl --version)"
  local v2="$($CURL 'https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateBoostnote() {
  local SoftwareName='Boostnote'
  local v1="$(grep -Po '"version": "\K.*?(?=")' /usr/lib/boostnote/resources/app/package.json)"
  local v2="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateFreefilesync() {
  local SoftwareName='FreeFileSync'
  local v1="$(head "$manual_install_dir"/FreeFileSync/CHANGELOG -n 1 | grep -Po 'FreeFileSync \K(\d+\.+\d+)')"
  local v2="$($CURL 'https://freefilesync.org/download.php' | grep 'Linux.tar.gz' | grep -Po '(FreeFileSync_)\K(\d+\.+\d+)')"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateKeepassxc() {
  local SoftwareName='KeePassXC'
  local v1="$(grep -Po '^Exec.*-\K\d+.\d+.\d+' /usr/share/applications/keepassxc.desktop)"
  local v2="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateJoplin() {
  local SoftwareName='Joplin'
  local v1="$(grep -Po '^Exec.*-\K\d+.\d+.\d+' /usr/share/applications/joplin.desktop)"
  local v2="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateStacer() {
  local SoftwareName='Stacer'
  local v1="$(strings /usr/share/stacer/stacer | grep -Po '(Stacer v)\K(\d+.\d+.\d+.)')"
  local v2="$($CURL 'https://api.github.com/repos/oguzhaninan/Stacer/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateBat() {
  local SoftwareName='Bat'
  local v1="$(bat --version | grep -Po '(bat )\K.*')"
  local v2="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateKrita() {
  local SoftwareName='Krita'
  local v1="$(grep -Po '^Exec.*-\K\d+.\d+.\d+' /usr/share/applications/krita.desktop)"
  local v2="$($CURL 'https://krita.org/fr/telechargement/krita-desktop/' | grep 'stable' | grep 'appimage>' | grep -Po '(?<=/stable/krita/)(\d+\.+\d\.\d+)')"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateOpensnitch() {
  local SoftwareName='OpenSnitch'
  local v1="$(opensnitchd --version)"
  local v2="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  # Pour récupérer la dernière release non-stable : local v2="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases' | grep -m 1 -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

CheckUpdateDrawio() {
  local SoftwareName='Drawio'
  local v1="$()"
  local v2="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

UpdateEtcher() {
  local SoftwareName='Etcher'
  local v1="$()"
  local v2="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)"
  CheckAvailableUpdate "$SoftwareName" "$v2" "$v1"
}

################################################################################

UpdateShotcut() {
  local shotcut_version="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local shotcut_appimage="$($CURL 'https://api.github.com/repos/mltframework/shotcut/releases/latest' | grep -Po '"name": "\K.*?(?=")' | grep 'AppImage')" && \
  rm -f /usr/bin/shotcut && \
  rm -f "$manual_install_dir"/shotcut/*.AppImage && \
	$WGET -P "$manual_install_dir"/shotcut/ https://github.com/mltframework/shotcut/releases/download/v"$shotcut_version"/"$shotcut_appimage" && \
	chmod +x "$manual_install_dir"/shotcut/"$shotcut_appimage" && \
  ln -s "$manual_install_dir"/shotcut/"$shotcut_appimage" /usr/bin/shotcut
}

UpdateYoutube-dl() {
  youtube-dl --update
}

UpdateBoostnote() {
  local boostnote_version="$($CURL 'https://api.github.com/repos/BoostIO/boost-releases/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local tmp_dir="$(mktemp -d)" && \
  $WGET -P "$tmp_dir" https://github.com/BoostIO/boost-releases/releases/download/v$boostnote_version/boostnote_"$boostnote_version"_amd64.deb && \
  dpkg -i "$tmp_dir"/boostnote_"$boostnote_version"_amd64.deb
  # rm -rf "$tmp_dir"
}

UpdateFreefilesync() {
  local freefilesync_version="$($CURL 'https://freefilesync.org/download.php' | grep 'Linux.tar.gz' | grep -Po "(FreeFileSync_)\K(\d+\.+\d+)")" && \
  rm -rf "$manual_install_dir"/FreeFileSync && \
  local tmp_dir="$(mktemp -d)" && \
  aria2c -d "$tmp_dir" https://freefilesync.org/download/FreeFileSync_"$freefilesync_version"_Linux.tar.gz -o /FreeFileSync_"$freefilesync_version"_Linux.tar.gz && \
  tar xvf "$tmp_dir"/FreeFileSync_"$freefilesync_version"_Linux.tar.gz --directory "$manual_install_dir" > /dev/null
  # rm -rf "$tmp_dir"
}

UpdateKeepassxc() {
  local keepassxc_version="$($CURL 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")')" && \
  rm -rf "$manual_install_dir"/KeePassXC/KeePassXC-*.AppImage && \
  $WGET -P "$manual_install_dir"/KeePassXC/ https://github.com/keepassxreboot/keepassxc/releases/download/"$keepassxc_version"/KeePassXC-"$keepassxc_version"-x86_64.AppImage && \
  chmod +x "$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage && \
  sed -i "s,.*Exec=.*,Exec="$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage,g" /usr/share/applications/keepassxc.desktop && \
  [ -f /home/"$local_user"/.config/autostart/keepassxc.desktop ] && sed -i s,.*Exec=.*,Exec="$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage,g /home/"$local_user"/.config/autostart/keepassxc.desktop && \
  [ -f "$manual_install_dir"/KeePassXC/keepassxc-logo.svg ] || $WGET -P "$manual_install_dir"/KeePassXC/ 'https://keepassxc.org/images/keepassxc-logo.svg'
  [ -f /home/"$local_user"/.config/asbru/asbru.yml ] && sed -i "s,pathcli: /opt/manual_install/KeePassXC/KeePassXC-.*.AppImage,pathcli: "$manual_install_dir"/KeePassXC/KeePassXC-"$keepassxc_version"-x86_64.AppImage,g" /home/"$local_user"/.config/asbru/asbru.yml
  # bon a priori la commande précendante ne fonctionne pas, elle change bien la version dans le fichier de conf de asbru, mais cette modification ne permet pas de changer réellement la conf de asbru
}

UpdateJoplin() {
  local joplin_version="$($CURL 'https://api.github.com/repos/laurent22/joplin/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  rm -f "$manual_install_dir"/Joplin/Joplin-*.AppImage && \
  $WGET -P "$manual_install_dir"/Joplin/ https://github.com/laurent22/joplin/releases/download/v"$joplin_version"/Joplin-"$joplin_version".AppImage && \
  chmod +x "$manual_install_dir"/Joplin/Joplin-"$joplin_version".AppImage && \
  sed -i "s,^Exec=.*,Exec="$manual_install_dir"/Joplin/Joplin-"$joplin_version".AppImage --no-sandbox,g" /usr/share/applications/joplin.desktop && \
  [ -f /home/"$local_user"/.config/autostart/joplin.desktop ] && sed -i "s,^Exec=.*,Exec="$manual_install_dir"/Joplin/Joplin-"$joplin_version".AppImage --no-sandbox,g" /home/"$local_user"/.config/autostart/joplin.desktop && \
  [ -f "$manual_install_dir"/Joplin/256x256.png ] || $WGET -P "$manual_install_dir"/Joplin/ 'https://raw.githubusercontent.com/laurent22/joplin/master/Assets/LinuxIcons/256x256.png'
}

UpdateStacer() {
  local stacer_version="$($CURL 'https://api.github.com/repos/oguzhaninan/Stacer/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local tmp_dir="$(mktemp -d)" && \
  $WGET -P "$tmp_dir" https://github.com/oguzhaninan/Stacer/releases/download/v$stacer_version/stacer_"$stacer_version"_amd64.deb && \
  dpkg -i "$tmp_dir"/stacer_"$stacer_version"_amd64.deb
  # rm -rf "$tmp_dir"
}

UpdateBat() {
  local bat_version="$($CURL 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local tmp_dir="$(mktemp -d)" && \
  $WGET -P "$tmp_dir" https://github.com/sharkdp/bat/releases/download/v"$bat_version"/bat_"$bat_version"_amd64.deb && \
  dpkg -i "$tmp_dir"/bat_"$bat_version"_amd64.deb
  # rm -rf "$tmp_dir"
}

UpdateKrita() {
  local krita_version="$($CURL 'https://krita.org/fr/telechargement/krita-desktop/' | grep 'stable' | grep 'appimage>' | grep -Po '(?<=/stable/krita/)(\d+\.+\d\.\d+)')" && \
  rm -f "$manual_install_dir"/Krita/krita-*.appimage && \
  $WGET -P "$manual_install_dir"/Krita/ https://download.kde.org/stable/krita/"$krita_version"/krita-"$krita_version"-x86_64.appimage && \
  chmod +x "$manual_install_dir"/Krita/krita-"$krita_version"-x86_64.appimage && \
  sed -i "s,^Exec=.*,Exec="$manual_install_dir"/Krita/krita-"$krita_version"-x86_64.appimage,g" /usr/share/applications/krita.desktop
}

UpdateOpensnitch() {
  local opensnitch_version="$($CURL 'https://api.github.com/repos/evilsocket/opensnitch/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  local tmp_dir="$(mktemp -d)" && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_version"/python3-opensnitch-ui_"$opensnitch_version"-1_all.deb && \
  $WGET -P "$tmp_dir" https://github.com/evilsocket/opensnitch/releases/download/v"$opensnitch_version"/opensnitch_"$opensnitch_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/opensnitch_"$opensnitch_version"-1_amd64.deb && \
  dpkg -i "$tmp_dir"/python3-opensnitch-ui_"$opensnitch_version"-1_all.deb && \
  rm -rf "$tmp_dir" && \
  $AG install -f -y
}

UpdateDrawio() {
  local drawio_version="$($CURL 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  rm -f "$manual_install_dir"/drawio/drawio-*.AppImage && \
  $WGET -P "$manual_install_dir"/drawio/ https://github.com/jgraph/drawio-desktop/releases/download/v"$drawio_version"/drawio-x86_64-"$drawio_version".AppImage && \
  chmod +x "$manual_install_dir"/drawio/drawio-x86_64-"$drawio_version".AppImage && \
  sed -i "s,^Exec=.*,Exec=$manual_install_dir/drawio/drawio-x86_64-"$drawio_version".AppImage,g" /usr/share/applications/drawio.desktop
  [ -f "$manual_install_dir"/drawio/drawlogo256.png ] || $WGET -P "$manual_install_dir"/drawio/ 'https://raw.githubusercontent.com/jgraph/drawio/master/src/main/webapp/images/drawlogo256.png'
}

UpdateEtcher() {
  local etcher_version="$($CURL 'https://api.github.com/repos/balena-io/etcher/releases/latest' | grep -Po '"tag_name": "\K.*?(?=")' | cut -c 2-)" && \
  rm -f "$manual_install_dir"/balenaEtcher/balenaEtcher-*.AppImage && \
  $WGET -P "$manual_install_dir"/balenaEtcher/ https://github.com/balena-io/etcher/releases/download/v"$etcher_version"/balenaEtcher-"$etcher_version"-x64.AppImage && \
  chmod +x "$manual_install_dir"/balenaEtcher/balenaEtcher-"$etcher_version"-x64.AppImage && \
  sed -i "s,^Exec=.*,Exec=$manual_install_dir/balenaEtcher/balenaEtcher-"$etcher_version"-x64.AppImage,g" /usr/share/applications/balena-etcher-electron.desktop
  [ -f "$manual_install_dir"/balenaEtcher/icon.png ] || $WGET -P "$manual_install_dir"/balenaEtcher/ 'https://github.com/balena-io/etcher/raw/master/assets/icon.png'
}

################################################################################

# on déclare le tableau qui contiendra les logiciels qui ont besoin d'être mis à jour
software_that_needs_updating=()

# on déclare la fonction permettant d'ajouter des valeurs dans le tableau software_that_needs_updating
AddTo_software_that_needs_updating() {
  software_that_needs_updating["${#software_that_needs_updating[*]}"]=$1
}

# on déclare le tableau qui contiendra les logiciels qui ont été mis à jour
software_update_failed=()

# on déclare la fonction permettant d'ajouter des valeurs dans le tableau software_update_failed
AddTo_software_update_failed() {
  software_update_failed["${#software_update_failed[*]}"]=$1
}

################################################################################

software_list='
Shotcut
Youtube-dl
Boostnote
Freefilesync
Keepassxc
Joplin
Stacer
Bat
Krita
Opensnitch
Drawio
Etcher'

CheckUpdate() {
for software in $software_list; do
	CheckUpdate"$software"
	if [ "$retval" ]; then
		AddTo_software_that_needs_updating "$retval"
		Update"$software" || AddTo_software_update_failed "$retval"
		unset retval
	fi
done

  # echo ${software_that_needs_updating[*]}

if [ "${#software_that_needs_updating[*]}" == 0 ]; then
  echo 'Tous les logiciels sont à jour.'
else
  echo 'Les logiciels suivants nécessitent une mise à jour :' "${software_that_needs_updating[*]}"
fi

if [ "${#software_update_failed[*]}" != 0 ]; then
  echo 'Les logiciels suivants ne se sont pas mis à jour correctement :' "${software_update_failed[*]}"
else
  echo 'Les logiciels se sont mis à jour correctement.'
fi
}

################################################################################

CheckUpdate

exit 0
EOF
displayandexec "Installation du script sysupdateNG                  " "\
chmod +x /opt/sysupdateNG && \
ln -s /opt/sysupdateNG /usr/bin/sysupdateNG"
}
################################################################################

################################################################################
## install du scrip check_backport_update
##------------------------------------------------------------------------------
install_check_backport_update() {
  # porbablement qu'il vaudrait lister les paquets qui peuvent être mis à jours avec sudo apt-get update && sudo apt list --upgradable
  # certainement avec quelque chose comme : awk '/~bpo/ && /.bpo/ {print $0}' <(sudo apt list --upgradable 2> /dev/null)
  # c'est beaucoup plus rapide
cat> /usr/bin/check_backport_update << 'EOF'
#!/bin/bash

debian_release="$(lsb_release -sc)"
list_backport="$(dpkg-query -W | awk '/~bpo/{print $1}')"

sudo sed -i "s%^#deb http://deb.debian.org/debian "$debian_release"-backports%deb http://deb.debian.org/debian "$debian_release"-backports%" /etc/apt/sources.list
sudo apt-get update > /dev/null

while read package; do
  sudo apt-get upgrade -s -t "$debian_release"-backports "$package" | grep 'est déjà la version la plus récente'
done <<< "$list_backport"

sudo sed -i "s%^deb http://deb.debian.org/debian "$debian_release"-backports%#deb http://deb.debian.org/debian "$debian_release"-backports%" /etc/apt/sources.list
sudo apt-get update > /dev/null

exit 0
EOF
displayandexec "Installation du script check_backport_update        " "\
chmod +x /usr/bin/check_backport_update"
}
################################################################################

################################################################################
## install du scrip wsudo
##------------------------------------------------------------------------------
install_wsudo() {
cat> /usr/bin/wsudo << 'EOF'
#small script to enable root access to x-windows system
xhost +SI:localuser:root
sudo $1
#disable root access after application terminates
xhost -SI:localuser:root
#print access status to allow verification that root access was removed
xhost
EOF
displayandexec "Installation du script wsudo                        " "chmod +x /usr/bin/wsudo"
}
################################################################################

################################################################################
## install du scrip launch_url_file
##------------------------------------------------------------------------------
install_launch_url_file() {
echo 'chromium `tail -n 1 "$@" | cut -c 5-`' > /usr/bin/launch_url_file
displayandexec "Installation du script launch_url_file              " "chmod +x /usr/bin/launch_url_file"
# création du fichier launch_url_file.desktop qui permet d'utiliser le script launch_url_file comme une application
cat> /usr/share/applications/launch_url_file.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=launch_url_file
Comment=script de lancement des fichiers URL depuis nautilus
Icon=chromium
Exec=/usr/bin/launch_url_file
Categories=FileTools;
OnlyShowIn=Old;
EOF
# si Icon=chromium ne marche pas mettre Icon=applications-other
}
################################################################################

################################################################################
## install du scrip scanmyhome
##------------------------------------------------------------------------------
install_scanmyhome() {
displayandexec "Installation du script scanmyhome                   " "\
echo 'clamscan -r -i /home/' > /usr/bin/scanmyhome && \
chmod +x /usr/bin/scanmyhome"
}
################################################################################

################################################################################
## install du scrip rktscan
##------------------------------------------------------------------------------
install_rktscan() {
cat> /usr/bin/rktscan << 'EOF'
echo "scan de rootkit avec rkhunter"
sudo rkhunter --checkall --report-warnings-only
echo "--------------------------------------------------------------------------------"
echo "scan de rootkit avec chkrootkit"
sudo chkrootkit -q
echo "--------------------------------------------------------------------------------"
EOF
displayandexec "Installation du script rktscan                      " "chmod +x /usr/bin/rktscan"
}
################################################################################

################################################################################
## install du scrip spyme
##------------------------------------------------------------------------------
install_spyme() {
displayandexec "Installation du script spyme                        " "\
echo 'sudo lnav /var/log/syslog /var/log/auth.log' > /usr/bin/spyme && \
chmod +x /usr/bin/spyme"
}
################################################################################

################################################################################
## install du scrip check_domain_creation_date
##------------------------------------------------------------------------------
install_check_domain_creation_date() {
cat> /usr/bin/check_domain_creation_date << 'EOF'
#!/bin/bash

domain_creation_date="$(whois "$1" | grep -Po -m 1 '(Creation Date:[[:space:]])\K(\d+-\d+-\d+)')"

if [[ -z "$domain_creation_date" ]]; then
	domain_creation_date="$(whois "$1" | grep -Po -m 1 '(created:[[:space:]]+)\K(\d+-\d+-\d+)')"
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

exit 0
EOF
displayandexec "Installation du script check_domain_creation_date   " "chmod +x /usr/bin/check_domain_creation_date"
################################################################################

################################################################################
## install du scrip appairmebt
##------------------------------------------------------------------------------
install_appairmebt() {
cat> /usr/bin/appairmebt << 'EOF'
gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "<false>" > /dev/null
bluetoothctl select AA:AA:AA:AA:AA:AA > /dev/null
bluetoothctl power on > /dev/null
bluetoothctl trust BB:BB:BB:BB:BB:BB > /dev/null
bluetoothctl connect BB:BB:BB:BB:BB:BB > /dev/null
EOF
displayandexec "Installation du script appairmebt                   " "chmod +x /usr/bin/appairmebt"
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
################################################################################

################################################################################
## install du script desactivebt
##------------------------------------------------------------------------------
install_desactivebt() {
cat> /usr/bin/desactivebt << 'EOF'
gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "<true>" > /dev/null
EOF
displayandexec "Installation du script desactivebt                  " "chmod +x /usr/bin/desactivebt"
}
################################################################################

################################################################################
## install du script play_pause_chromium
##------------------------------------------------------------------------------
install_play_pause_chromium() {
  cat> /usr/bin/play_pause_chromium << 'EOF'
dbus_dest_org="$(dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | awk '/org.mpris.MediaPlayer2.chromium/ {gsub(/\"/,"");print $2}')" && \
dbus-send --print-reply --dest=$dbus_dest_org /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause > /dev/null
EOF
displayandexec "Installation du script play_pause_chromium          " "chmod +x /usr/bin/play_pause_chromium"
}
################################################################################

install_all_perso_script() {
  install_gitupdate
  install_sysupdateng
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
}
install_all_perso_script
################################################################################

#//////////////////////////////////////////////////////////////////////////////#
#                              CONFIGURATION                                   #
#//////////////////////////////////////////////////////////////////////////////#

################################################################################
## configuration de SSH
##------------------------------------------------------------------------------
# on change le port par défaut
sed -i "s/#Port\ 22/Port\ "$SSH_Port"/g" /etc/ssh/sshd_config && \
sed -E -i '/(^#PermitRootLogin|^PermitRootLogin) (yes|no|without-password|prohibit-password)/{s/yes/no/;t;s/without-password/no/;t;s/prohibit-password/no/;}' /etc/ssh/sshd_config && \
sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
# (^#PermitRootLogin|^PermitRootLogin) : permet d'identifier que le ligne commence par #PermitRootLogin ou qu'elle commence par PermitRootLogin, uniquement
# (yes|no|without-password|prohibit-password) : permet de donner les quatre possibilités différentes de valeur pour PermitRootLogin, à savoir yes, no, without-password, prohibit-password
# {s/yes/no/;t;s/without-password/no/;t;s/prohibit-password/no/;} : permet de remplacer yes par no , without-password par no ainsi que prohibit-password par no
# sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' : permet de décommenter la ligne si celle si l'était
# voici une autre commande moins complexe qui fait le job
# sed -E -i 's/(^#PermitRootLogin|^PermitRootLogin).*/PermitRootLogin no/' /etc/ssh/sshd_config
# Pour autoriser root sur Kali :
# sed -E -i '/(^#PermitRootLogin|^PermitRootLogin) (yes|no|without-password|prohibit-password)/{s/no/yes/;t;s/without-password/yes/;t;s/prohibit-password/yes/;}' /etc/ssh/sshd_config && sed -E -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config

cat>> /etc/ssh/sshd_config << EOF

# "Disables all forwarding features, including X11, ssh-agent(1), TCP and StreamLocal. This option overrides all other forwarding-related options and may simplify restricted configurations."
# ref : https://manpages.debian.org/unstable/openssh-server/sshd_config.5.en.html#DisableForwarding
DisableForwarding yes

# only allow this user ("$local_user") to connect to SSH
AllowUsers "$local_user"
EOF
################################################################################

################################################################################
## configuration de SSHFS
##------------------------------------------------------------------------------
# création du répertoire qui servira de point de montage pour SSHFS
[ -d /home/"$local_user"/.mnt/sshfs/ ] || $ExeAsUser mkdir -p /home/"$local_user"/.mnt/sshfs/
################################################################################

################################################################################
## configuration du logrotate pour le auth.log
##------------------------------------------------------------------------------
# cette conf permet de garder 12 mois de log de auth.log. Cela permet donc de garder pendant un an toutes les commandes utilisées ainsi que toutes les connexions d'utilisateur
sed -i '\/var\/log\/auth\.log/d' /etc/logrotate.d/rsyslog && \
echo '
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
}' >> /etc/logrotate.d/rsyslog
################################################################################

################################################################################
## configuration des règles auditd
##------------------------------------------------------------------------------
cat> /etc/audit/rules.d/audit.rules << 'EOF'
# Linux Audit Daemon - Best Practice Configuration
# /etc/audit/audit.rules
#
# Compiled by Florian Roth
#
# Based on rules published here:
#   Gov.uk auditd rules
#   	https://github.com/gds-operations/puppet-auditd/pull/1
# 	CentOS 7 hardening
# 		https://highon.coffee/blog/security-harden-centos-7/#auditd---audit-daemon
# 	Linux audit repo
# 		https://github.com/linux-audit/audit-userspace/tree/master/rules
# 	Auditd high performance linux auditing
# 		https://linux-audit.com/tuning-auditd-high-performance-linux-auditing/
#
# Further rules
# 	For PCI DSS compliance see:
# 		https://github.com/linux-audit/audit-userspace/blob/master/rules/30-pci-dss-v31.rules
# 	For NISPOM compliance see:
# 		https://github.com/linux-audit/audit-userspace/blob/master/rules/30-nispom.rules

# Remove any existing rules
-D

# Buffer Size
## Feel free to increase this if the machine panic's
-b 8192

# Failure Mode
## Possible values: 0 (silent), 1 (printk, print a failure message), 2 (panic, halt the system)
-f 1

# Ignore errors
## e.g. caused by users or files not found in the local environment
-i

# Self Auditing ---------------------------------------------------------------

## Audit the audit logs
### Successful and unsuccessful attempts to read information from the audit records
-w /var/log/audit/ -k auditlog

## Auditd configuration
### Modifications to audit configuration that occur while the audit collection functions are operating
-w /etc/audit/ -p wa -k auditconfig
-w /etc/libaudit.conf -p wa -k auditconfig
-w /etc/audisp/ -p wa -k audispconfig

## Monitor for use of audit management tools
-w /sbin/auditctl -p x -k audittools
-w /sbin/auditd -p x -k audittools
-w /usr/sbin/augenrules -p x -k audittools

# Filters ---------------------------------------------------------------------

### We put these early because audit is a first match wins system.

## Ignore SELinux AVC records
-a always,exclude -F msgtype=AVC

## Ignore current working directory records
-a always,exclude -F msgtype=CWD

## Ignore EOE records (End Of Event, not needed)
-a always,exclude -F msgtype=EOE

## This is not very interesting and wastes a lot of space if the server is public facing
-a always,exclude -F msgtype=CRYPTO_KEY_USER

### High Volume Event Filter (especially on Linux Workstations)
-a never,exit -F arch=b32 -F dir=/dev/shm -k sharedmemaccess
-a never,exit -F arch=b64 -F dir=/dev/shm -k sharedmemaccess
-a never,exit -F arch=b32 -F dir=/var/lock/lvm -k locklvm
-a never,exit -F arch=b64 -F dir=/var/lock/lvm -k locklvm

## More information on how to filter events
### https://access.redhat.com/solutions/2482221

# Rules -----------------------------------------------------------------------

## Kernel parameters
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d -p wa -k sysctl

## Kernel module loading and unloading
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules
-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules
-a always,exit -F arch=b32 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules

## Modprobe configuration
-w /etc/modprobe.conf -p wa -k modprobe
-w /etc/modprobe.d -p wa -k modprobe

## KExec usage (all actions)
-a always,exit -F arch=b64 -S kexec_load -k KEXEC
-a always,exit -F arch=b32 -S sys_kexec_load -k KEXEC

## Special files
-a always,exit -F arch=b32 -S mknod -S mknodat -k specialfiles
-a always,exit -F arch=b64 -S mknod -S mknodat -k specialfiles

## Mount operations (only attributable)
-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount
-a always,exit -F arch=b32 -S mount -S umount -S umount2 -F auid!=-1 -k mount

## Change swap (only attributable)
-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap
-a always,exit -F arch=b32 -S swapon -S swapoff -F auid!=-1 -k swap

## Time
# -a always,exit -F arch=b32 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time
# -a always,exit -F arch=b64 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time
### Local time zone
-w /etc/localtime -p wa -k localtime

## Stunnel
-w /usr/sbin/stunnel -p x -k stunnel
-w /usr/bin/stunnel -p x -k stunnel

## Cron configuration & scheduled jobs
-w /etc/cron.allow -p wa -k cron
-w /etc/cron.deny -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /etc/cron.daily/ -p wa -k cron
-w /etc/cron.hourly/ -p wa -k cron
-w /etc/cron.monthly/ -p wa -k cron
-w /etc/cron.weekly/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -k cron

## User, group, password databases
-w /etc/group -p wa -k etcgroup
-w /etc/passwd -p wa -k etcpasswd
-w /etc/gshadow -k etcgroup
-w /etc/shadow -k etcpasswd
-w /etc/security/opasswd -k opasswd

## Sudoers file changes
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

## Passwd
-w /usr/bin/passwd -p x -k passwd_modification

## Tools to change group identifiers
-w /usr/sbin/groupadd -p x -k group_modification
-w /usr/sbin/groupmod -p x -k group_modification
-w /usr/sbin/addgroup -p x -k group_modification
-w /usr/sbin/useradd -p x -k user_modification
-w /usr/sbin/userdel -p x -k user_modification
-w /usr/sbin/usermod -p x -k user_modification
-w /usr/sbin/adduser -p x -k user_modification

## Login configuration and information
-w /etc/login.defs -p wa -k login
-w /etc/securetty -p wa -k login
-w /var/log/faillog -p wa -k login
-w /var/log/lastlog -p wa -k login
-w /var/log/tallylog -p wa -k login

## Network Environment
### Changes to hostname
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications

### Successful IPv4 Connections
-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4
-a always,exit -F arch=b32 -S connect -F a2=16 -F success=1 -F key=network_connect_4

### Successful IPv6 Connections
-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6
-a always,exit -F arch=b32 -S connect -F a2=28 -F success=1 -F key=network_connect_6

### Changes to other files
-w /etc/hosts -p wa -k network_modifications
#-w /etc/sysconfig/network -p wa -k network_modifications # ne fonctionne pas
# -w /etc/sysconfig/network-scripts -p w -k network_modifications # ne fonctionne pas
-w /etc/network/ -p wa -k network
-a always,exit -F dir=/etc/NetworkManager/ -F perm=wa -k network_modifications

### Changes to issue
-w /etc/issue -p wa -k etcissue
-w /etc/issue.net -p wa -k etcissue

## System startup scripts
-w /etc/inittab -p wa -k init
-w /etc/init.d/ -p wa -k init
-w /etc/init/ -p wa -k init

## Library search paths
-w /etc/ld.so.conf -p wa -k libpath
-w /etc/ld.so.conf.d -p wa -k libpath

## Systemwide library preloads (LD_PRELOAD)
-w /etc/ld.so.preload -p wa -k systemwide_preloads

## Pam configuration
-w /etc/pam.d/ -p wa -k pam
-w /etc/security/limits.conf -p wa  -k pam
-w /etc/security/limits.d -p wa  -k pam
-w /etc/security/pam_env.conf -p wa -k pam
-w /etc/security/namespace.conf -p wa -k pam
-w /etc/security/namespace.d -p wa -k pam
-w /etc/security/namespace.init -p wa -k pam

## Mail configuration
-w /etc/aliases -p wa -k mail
-w /etc/postfix/ -p wa -k mail
-w /etc/exim4/ -p wa -k mail

## SSH configuration
-w /etc/ssh/sshd_config -k sshd
-w /etc/ssh/sshd_config.d -k sshd

## root ssh key tampering
-w /root/.ssh -p wa -k rootkey

# Systemd
-w /bin/systemctl -p x -k systemd
-w /etc/systemd/ -p wa -k systemd

## SELinux events that modify the system's Mandatory Access Controls (MAC)
-w /etc/selinux/ -p wa -k mac_policy

## Critical elements access failures
-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileaccess

## Process ID change (switching accounts) applications
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc
-w /etc/sudoers -p rw -k priv_esc
-w /etc/sudoers.d -p rw -k priv_esc

## Power state
-w /sbin/shutdown -p x -k power
-w /sbin/poweroff -p x -k power
-w /sbin/reboot -p x -k power
-w /sbin/halt -p x -k power

## Session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

## Discretionary Access Control (DAC) modifications
-a always,exit -F arch=b32 -S chmod -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fchownat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S fsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S removexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chmod  -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=-1 -k perm_mod

# Special Rules ---------------------------------------------------------------

## Reconnaissance
-w /usr/bin/whoami -p x -k recon
-w /usr/bin/id -p x -k recon
-w /bin/hostname -p x -k recon
-w /bin/uname -p x -k recon
-w /etc/issue -p r -k recon
-w /etc/hostname -p r -k recon

## Suspicious activity
-w /usr/bin/wget -p x -k susp_activity
-w /usr/bin/curl -p x -k susp_activity
-w /usr/bin/base64 -p x -k susp_activity
-w /bin/nc -p x -k susp_activity
-w /bin/netcat -p x -k susp_activity
-w /usr/bin/ncat -p x -k susp_activity
-w /usr/bin/ssh -p x -k susp_activity
-w /usr/bin/scp -p x -k susp_activity
-w /usr/bin/sftp -p x -k susp_activity
-w /usr/bin/ftp -p x -k susp_activity
-w /usr/bin/socat -p x -k susp_activity
-w /usr/bin/wireshark -p x -k susp_activity
-w /usr/bin/tshark -p x -k susp_activity
-w /usr/bin/rawshark -p x -k susp_activity
-w /usr/bin/rdesktop -p x -k susp_activity
-w /usr/bin/nmap -p x -k susp_activity

## Added to catch netcat on Ubuntu
-w /bin/nc.openbsd -p x -k susp_activity
-w /bin/nc.traditional -p x -k susp_activity

## Sbin suspicious activity
-w /sbin/iptables -p x -k sbin_susp
-w /sbin/ip6tables -p x -k sbin_susp
-w /sbin/ifconfig -p x -k sbin_susp
-w /usr/sbin/arptables -p x -k sbin_susp
-w /usr/sbin/ebtables -p x -k sbin_susp
-w /sbin/xtables-nft-multi -p x -k sbin_susp
-w /usr/sbin/nft -p x -k sbin_susp
-w /usr/sbin/tcpdump -p x -k sbin_susp
-w /usr/sbin/traceroute -p x -k sbin_susp
-w /usr/sbin/ufw -p x -k sbin_susp

## dbus-send invocation
### may indicate privilege escalation CVE-2021-3560
-w /usr/bin/dbus-send -p x -k dbus_send

## Injection
### These rules watch for code injection by the ptrace facility.
### This could indicate someone trying to do something bad or just debugging
-a always,exit -F arch=b32 -S ptrace -F a0=0x4 -k code_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection
-a always,exit -F arch=b32 -S ptrace -F a0=0x5 -k data_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection
-a always,exit -F arch=b32 -S ptrace -F a0=0x6 -k register_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection
-a always,exit -F arch=b32 -S ptrace -k tracing
-a always,exit -F arch=b64 -S ptrace -k tracing

## Privilege Abuse
### The purpose of this rule is to detect when an admin may be abusing power by looking in user's home dir.
-a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=-1 -C auid!=obj_uid -k power_abuse

# Software Management ---------------------------------------------------------

# DPKG / APT-GET (Debian/Ubuntu)
-w /usr/bin/dpkg -p x -k software_mgmt
-w /usr/bin/apt -p x -k software_mgmt
-w /usr/bin/apt-add-repository -p x -k software_mgmt
-w /usr/bin/apt-get -p x -k software_mgmt
-w /usr/bin/aptitude -p x -k software_mgmt
-w /usr/bin/wajig -p x -k software_mgmt
-w /usr/bin/snap -p x -k software_mgmt

# PIP (Python installs)
-w /usr/bin/pip -p x -k software_mgmt
-w /usr/bin/pip3 -p x -k software_mgmt

# Special Software ------------------------------------------------------------

## Docker
-w /usr/bin/dockerd -k docker
-w /usr/bin/docker -k docker
-w /usr/bin/docker-containerd -k docker
-w /usr/bin/docker-runc -k docker
-w /var/lib/docker -k docker
-w /etc/docker -k docker
# -w /etc/sysconfig/docker -k docker # ne fonctionne pas
# -w /etc/sysconfig/docker-storage -k docker # ne fonctionne pas
-w /usr/lib/systemd/system/docker.service -k docker

# High Volume Events ----------------------------------------------------------

## Remove them if they cause to much volume in your environment

## Root command executions
-a always,exit -F arch=b64 -F euid=0 -S execve -k rootcmd
-a always,exit -F arch=b32 -F euid=0 -S execve -k rootcmd

## File Deletion Events by User
-a always,exit -F arch=b32 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -k delete
-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -k delete

## File Access
### Unauthorized Access (unsuccessful)
-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k file_access
-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k file_access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k file_access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k file_access

### Unsuccessful Creation
-a always,exit -F arch=b32 -S creat,link,mknod,mkdir,symlink,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
-a always,exit -F arch=b32 -S link,mkdir,symlink,mkdirat -F exit=-EPERM -k file_creation
-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation

### Unsuccessful Modification
-a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
-a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification

## 32bit API Exploitation
### If you are on a 64 bit platform, everything _should_ be running
### in 64 bit mode. This rule will detect any use of the 32 bit syscalls
### because this might be a sign of someone exploiting a hole in the 32
### bit API.
-a always,exit -F arch=b32 -S all -k 32bit_api

# Make The Configuration Immutable --------------------------------------------

##-e 2
EOF
systemctl restart auditd
# rules based on https://github.com/Neo23x0/auditd/blob/master/audit.rules
# les règles vont être généré (lors du restart) à l'aide de augenrules et seront ensuite dans le fichier /etc/audit/audit.rules
################################################################################

################################################################################
## configuration de /etc/inputrc
##------------------------------------------------------------------------------
# # do not bell on tab-completion
sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc
################################################################################

################################################################################
## configuration de freshclam (clamav)
##------------------------------------------------------------------------------
# sed -E -i 's/^Checks [[:digit:]]+/Checks 1/g' /etc/clamav/freshclam.conf
onlyexec "sed -E -i 's/^Checks [[:digit:]]+/Checks 1/g' /etc/clamav/freshclam.conf"
# Check for new database 1 times a day (insteed of 24)
# les logs de freshclam sont dans /var/log/clamav/freshclam.log
# c'est le service clamav-freshclam qui fait tourner freshclam
################################################################################

################################################################################
## configuration de stacer
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.config/stacer/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/stacer/ && \
$ExeAsUser echo '[General]
AppQuitDialogDontAsk=true
Language=fr' > /home/"$local_user"/.config/stacer/settings.ini
################################################################################

################################################################################
## configuration de Etcher
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.config/balena-etcher-electron/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/balena-etcher-electron/ && \
$ExeAsUser cat> /home/"$local_user"/.config/balena-etcher-electron/config.json << 'EOF'
{
  "errorReporting": false,
  "updatesEnabled": false,
  "desktopNotifications": true,
  "autoBlockmapping": true,
  "decompressFirst": true
}
EOF
################################################################################

################################################################################
## configuration de rkhunter
##------------------------------------------------------------------------------
# suite aux infos de ce site : https://forum.cabane-libre.org/topic/239/invalid-web_cmd-configuration-option-relative-pathname-bin-false
sed -i "s/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/" /etc/rkhunter.conf && \
sed -i "s/MIRRORS_MODE=1/MIRRORS_MODE=0/" /etc/rkhunter.conf && \
sed -i 's/WEB_CMD=\"\/bin\/false\"/WEB_CMD=\"\"/' /etc/rkhunter.conf
################################################################################

################################################################################
## configuration des fichiers template
##------------------------------------------------------------------------------
create_template_for_new_file() {
  [ -d /home/"$local_user"/Modèles/ ] && template_dir="/home/"$local_user"/Modèles/"
  [ -d /home/"$local_user"/Templates/ ] && template_dir="/home/"$local_user"/Templates/"
  $ExeAsUser touch ""$template_dir"/Fichier Texte.txt" && \
  $ExeAsUser touch ""$template_dir"/Document ODT.txt" && \
  $ExeAsUser unoconv -f odt ""$template_dir"/Document ODT.txt" && \
  rm -f ""$template_dir"/Document ODT.txt"
# ref : https://ask.libreoffice.org/en/question/153444/how-to-create-empty-libreoffice-file-in-a-current-directory-on-the-command-line/
}
create_template_for_new_file
# cette fonction permet d'obtnir dans le clique droit de nautilus l'accès à "Nouveau Document -> Ficher Texte"
################################################################################

################################################################################
## configuration de Libreoffice
##------------------------------------------------------------------------------
# conf de Libreoffice
sed -i --follow-symlinks '/^export LC_ALL/a export GTK_THEME=Adwaita' /usr/bin/libreoffice
# variante avec awk :
# awk '1;/^export LC_ALL/{print "export GTK_THEME=Adwaita"}' /usr/bin/libreoffice
# avec awk, on ne peut pas écrire directement dans le fichier, mais ce hack permet d'obtenir le même résultat
# echo "$(awk '1;/^export LC_ALL/{print "export GTK_THEME=Adwaita"}' /usr/bin/libreoffice)" > /usr/bin/libreoffice
# variante en perl (permet d'écrire directement dans le fichier, comme avec sed -i):
# perl -pi -e '$_ .= qq(export GTK_THEME=Adwaita\n) if /export LC_ALL/' /usr/bin/libreoffice

#if you want to use this in a .desktop file, you have to prepend 'env' for setting the env variable. I.e. copy the libreoffice-*.desktop files from /usr/share/applications to ~.local/share/applications, then open them in a text editor and change the line saying 'Exec' so it looks like this:
# Exec=env GTK_THEME=Adwaita:light libreoffice --writer

# disable java settings in LibreOffice
# $ExeAsUser sed -i 's%<enabled xsi:nil="false">true</enabled>%<enabled xsi:nil="false">false</enabled>%g' /home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml
# il faut potentiellement le mettre comme ça :
[ -f /home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml ] && \
$ExeAsUser sed -i 's%<enabled xsi:nil="true"></enabled>%<enabled xsi:nil="false">false</enabled>%g' /home/"$local_user"/.config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml

# ref : https://ask.libreoffice.org/en/question/167622/how-to-disable-java-in-configuration-files/
# Pour aider à chercher les fichiers concernés par la modification de la configuration
# find /home/$USER/.config/libreoffice/*/ -type f -mmin -5 -exec grep -l "java" {} \;
# find /usr/lib/libreoffice/share/ -type f -mmin -5 -exec grep -l "java" {} \;

# Disable startup logo
sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc
# ref : https://wiki.archlinux.org/title/LibreOffice#Disable_startup_logo

# cette configuration n'existe pas dans le fichier après une install, il faut donc trouver le moyen de l'ajouter en insérant la ligne
# Pour changer la valeur du niveau de sécurité des macros de Elevé à Très Elevé
[ -f /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu ] && \
$ExeAsUser sed -i 's%<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>2</value></prop></item>%<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>%g' /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu
# rajouter || créer le contenu du fichier avec un cat EOF

# Pour insérer la ligne lorsque le fichier existe :
# sed -i '\%</oor:items>%i <item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>' /home/"$local_user"/.config/libreoffice/4/user/registrymodifications.xcu
################################################################################

################################################################################
## configuration de nano
##------------------------------------------------------------------------------
# la configuration de nano s'effectue dans le fichier /etc/nanorc
sed -i 's/# set linenumbers/set linenumbers/g' /etc/nanorc
################################################################################

################################################################################
## configuration de atom
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.atom/ ] || $ExeAsUser mkdir /home/"$local_user"/.atom/ && \
$ExeAsUser cat> /home/"$local_user"/.atom/config.cson << 'EOF'
"*":
  autosave:
    enabled: true
  core:
    telemetryConsent: "no"
  editor:
    softWrap: true
  welcome:
    showOnStartup: false
EOF
displayandexec "Installation des plugins pour Atom                  " "\
$ExeAsUser apm install language-cisco && \
$ExeAsUser apm install language-powershell && \
$ExeAsUser apm install script && \
$ExeAsUser apm install vertical-tabs && \
$ExeAsUser apm install tab-title"
# Les plugins atom en commentaire sont encore en cour de validation
# apm install autoclose-html-plus
# apm install atom-beautify
# apm install markdown-themeable-pdf
# apm install markdown-pdf
# apm install atom-marp
# regarder pour faire du collaboratif avec atom : https://atom.io/packages/teletype

# pour voir la liste des plugins installés : apm ls
################################################################################

################################################################################
## configuration de typora
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.config/Typora/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/Typora/ && \
$ExeAsUser echo '7b22696e697469616c697a655f766572223a22302e392e3738222c226c696e655f656e64696e675f63726c66223a66616c73652c227072654c696e65627265616b4f6e4578706f7274223a747275652c2275756964223a2237346265383439362d343239372d343362382d616633632d336439343463646432376439222c227374726963745f6d6f6465223a747275652c22636f70795f6d61726b646f776e5f62795f64656661756c74223a747275652c226261636b67726f756e64436f6c6f72223a2223333633423430222c227468656d65223a226e696768742e637373222c22736964656261725f746162223a22222c2273656e645f75736167655f696e666f223a66616c73652c22656e61626c654175746f53617665223a747275652c226c617374436c6f736564426f756e6473223a7b2266756c6c73637265656e223a66616c73652c226d6178696d697a6564223a747275657d7d' > /home/"$local_user"/.config/Typora/profile.data
# la configuration des préférences de Typora ne peut se faire que graphiquement le seul moyen de contourner ce problème est de configurer graphiquement les préférences et de récupérer le contenu du fichier /home/$local_user/.config/Typora/profile.data
################################################################################

################################################################################
## configuration de FreeFileSync
##------------------------------------------------------------------------------
# Méthode utilisé pour obtenir la configuration de FreeFileSync
# on cherche le fichier de configuration de FreeFileSync avec un tree -af /home/$USER/
# on obtient le fichier suivant :
# /home/$USER/.config/FreeFileSync/GlobalSettings.xml
# bat GlobalSettings.xml > /tmp/tmpfreefilesync1
# effectuer le changmeent dans l'interface graphique qui permet de ne pas checker les mises à jour dans l'onglet Aide, avec l'option "Contrôler une fois par semaine"
# bat GlobalSettings.xml > /tmp/tmpfreefilesync2
# diff /tmp/tmpfreefilesync1 /tmp/tmpfreefilesync2
# on obtient :
# <         <LastOnlineCheck>1604659734</LastOnlineCheck>
# ---
# >         <LastOnlineCheck>51715</LastOnlineCheck>
# ensuite on fait un sed pour changer avec la valeur qui permet de désactiver la recherche des mises à jours une fois par semaine
# $ExeAsUser sed -i 's/.*\<LastOnlineCheck\>.*/        \<LastOnlineCheck\>51715\<\/LastOnlineCheck\>/g' /home/$local_user/.config/FreeFileSync/GlobalSettings.xml
# Le fait de remplacer la valeur par 0 ne change rien, en tout cas cela ne décoche pas le case du check des mises à jour
# l'action de sed ne peut se faire qu'apèrs que FreeFileSync ne se soit executer en moins une fois, car le fichier de configuration nh'existe pas avant cela
################################################################################

################################################################################
## configuration de Joplin
##------------------------------------------------------------------------------
# début de réflexion pour faire des confs sur des apps qui utilise une base de donnée pour stocker la conf
# apt-get install -y sqlite3 && sqlite3 .config/joplin-desktop/database.sqlite "select * from settings"

[ -d /home/"$local_user"/.config/Joplin/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/Joplin/ && \
$ExeAsUser cat> /home/"$local_user"/.config/Joplin/Preferences << 'EOF'
{"spellcheck":{"dictionaries":["fr"],"dictionary":""}}
EOF
################################################################################

################################################################################
## configuration de asbru
##------------------------------------------------------------------------------
# La configuration de asbru est situé dans /home/$local_user/.config/asbru/asbru.yml
# La configuration est beaucoup trop longue et sensible pour pouvoir la mettre dans ce script, il vaut mieux faire un import/export de la conf
################################################################################

################################################################################
## configuration de Handbrake
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.config/ghb/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/ghb/ && \
$ExeAsUser sed -E -i '/("UseM4v":) (false|true)/{s/true/false/;}' /home/"$local_user"/.config/ghb/preferences.json
# permet de décocher la case "Utiliser l'extension de fichier compatible iPod/iTunes (.m4v) pour MP4" (Fichier -> Préférences -> Général)
# le fichier de conf n'existe pas tant que handbrake n'a pas été lancé
# donc il faut soit trouver un moyen de lancer handbrake silencieusement soit copier coller la conf entière dans le fichier directement
# et donc qu'il faille faire le sed qu'une fois que le fichier de configuration ne soit présent
################################################################################

# ajout du dossier partagé pour VirtualBox
[ -d /home/"$local_user"/dossier_partage_VM/ ] || $ExeAsUser mkdir /home/"$local_user"/dossier_partage_VM/

# ajout du dossier autostart pour les apps qui se lance au démarage
[ -d /home/"$local_user"/.config/autostart/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/autostart/

################################################################################
## configuration des applis qui doivent se lancer au démarage
##------------------------------------------------------------------------------
#signal
$ExeAsUser cat> /home/"$local_user"/.config/autostart/signal.desktop << 'EOF'
[Desktop Entry]
Name=Signal
Comment=Private messaging from your desktop
Exec="/opt/Signal/signal-desktop" %U
Terminal=false
Type=Application
Icon=signal-desktop
StartupWMClass=Signal
Categories=Network;InstantMessaging;Chat;
EOF

#terminal
$ExeAsUser cat>  /home/"$local_user"/.config/autostart/terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=lancement du terminal au démarage
Exec=gnome-terminal --maximize
Type=Application
Terminal=false
Hidden=false
EOF

#keepassxc
$ExeAsUser cat> /home/"$local_user"/.config/autostart/keepassxc.desktop << EOF
[Desktop Entry]
Name=KeePassXC
Comment=Password Manager
Exec=$manual_install_dir/KeePassXC/KeePassXC-$keepassxc_version-x86_64.AppImage
Type=Application
Terminal=false
Hidden=false
EOF

#joplin
$ExeAsUser cat> /home/"$local_user"/.config/autostart/joplin.desktop << EOF
[Desktop Entry]
Name=Joplin
Comment=Markdown Editor
Exec=$manual_install_dir/Joplin/Joplin-$joplin_version.AppImage
Type=Application
Terminal=false
Hidden=false
EOF
# Il n'est pas impossible qu'il faille rajuter à la fin de la commande Exec --no-sandbox
# Au début Jolin ne se lançait pas sans se paramètre, depuis cela à l'air d'être corrigé
################################################################################

################################################################################
## configuration de KeePassXC
##------------------------------------------------------------------------------
[ -d /home/"$local_user"/.config/keepassxc/ ] || $ExeAsUser mkdir /home/"$local_user"/.config/keepassxc/ && \
$ExeAsUser cat> /home/"$local_user"/.config/keepassxc/keepassxc.ini << 'EOF'
[General]
AutoReloadOnChange=true
AutoSaveAfterEveryChange=true
AutoSaveOnExit=true
ConfigVersion=1
UpdateCheckMessageShown=true
OpenPreviousDatabasesOnStartup=true
RememberLastDatabases=true
RememberLastKeyFiles=true
SingleInstance=true

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
CheckForUpdates=true
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
PreviewSplitterState=@Invalid()
SearchViewState=@ByteArray()
ShowTrayIcon=false
SplitterState=@Invalid()
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
# réfléchir au parametre DropToBackgroundOnCopy=false, voir si on ne le passe pas à True
################################################################################

################################################################################
## configuration de audacity
##------------------------------------------------------------------------------
# sed -i '/Enabled=1/a [GUI]' /home/$local_user/.audacity-data/audacity.cfg
# sed -i '/[GUI]/a ShowSplashScreen=0' /home/$local_user/.audacity-data/audacity.cfg
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
$ExeAsUser cat> tmp_conf_dconf << 'EOF'
[gnome/documents]
window-maximized=true

[gnome/settings-daemon/peripherals/keyboard]
numlock-state='on'

[gnome/Weather/Application]
locations=[<(uint32 2, <('Le Mans', 'LFRM', true, [(0.83659448230485101, 0.0034906585039886592)], [(0.83775804095727813, 0.0034906585039886592)])>)>]

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
gtk-theme='Adwaita'

[gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'

[gnome/shell]
app-picker-view=uint32 1
favorite-apps=['chromium.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'signal-desktop.desktop', 'joplin.desktop', 'firefox-esr.desktop', 'boostnote.desktop', 'atom.desktop', 'org.gnome.Todo.desktop', 'veracrypt.desktop', 'spotify.desktop', 'libreoffice-writer.desktop', 'asbru-cm.desktop']
had-bluetooth-devices-setup=false

[gtk/settings/file-chooser]
sort-directories-first=true
show-hidden=true
EOF
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf load /org/ < tmp_conf_dconf
# ref : https://superuser.com/questions/726550/use-dconf-or-comparable-to-set-configs-for-another-user/1265786#1265786


CustomGnomeShortcut() {
	local name="$1"
	local command="$2"
	local shortcut="$3"
	local value="$($ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"
	local test="$(echo "$value" | sed "s/\['//;s/', '/,/g;s/'\]//" - | tr ',' '\n' | grep -oP ".*/custom\K[0-9]*(?=/$)")"

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
CustomGnomeShortcut "Appairer automatiquement avec le peripherique bluetooth" "/usr/bin/appairmebt" "<Super><Alt>b"
CustomGnomeShortcut "désactiver le bluetooth" "/usr/bin/desactivebt" "<Primary><Alt>b"

# $1       name of the shortcut
# $2       command to execute
# $3       keyboard shortcut

# TODO
# - before shortcut creation, check if:
#   - the shortcut is not used already in custom shortcuts;
#   - the command is not used already in custom shortcuts;
# - sometimes is uses the very same $num multiple times
################################################################################

# Pour obtenir le lien de l'image utilisé commend fond d'écran
# dconf read /org/gnome/shell/extensions/walkpaper/workspace-wallpapers

################################################################################
## configuration des MIME types
##------------------------------------------------------------------------------
# bien faire attention au point virgule, présent dans "Added Associations" mais pas dans "Default Applications"
$ExeAsUser cat> /home/"$local_user"/.config/mimeapps.list << 'EOF'
[Added Associations]
application/octet-stream=atom.desktop;
application/vnd.jgraph.mxfile=drawio.desktop;
application/x-php=atom.desktop;
application/x-mswinurl=launch_url_file.desktop;
application/x-shellscript=atom.desktop;
application/x-gettext-translation=org.gnome.gedit.desktop;
application/x-raw-disk-image=gnome-disk-image-mounter.desktop;
application/x-shellscript=atom.desktop;
application/x-keepass2=keepassxc.desktop;
application/x-kdbx=keepassxc.desktop;
text/markdown=typora.desktop;org.gnome.gedit.desktop;
text/csv=libreoffice-calc.desktop;org.gnome.gedit.desktop;
text/html=chromium.desktop;atom.desktop;
text/x-patch=atom.desktop;
text/x-python=atom.desktop;
video/x-matroska=mpv.desktop;
video/webm=mpv.desktop;
video/x-flv=mpv.desktop;
video/mp4=mpv.desktop;org.gnome.Totem.desktop;vlc.desktop;

[Default Applications]
application/x-mswinurl=launch_url_file.desktop;
application/x-shellscript=atom.desktop
application/x-keepass2=keepassxc.desktop
application/x-kdbx=keepassxc.desktop
text/html=chromium.desktop
text/plain=atom.desktop
text/markdown=typora.desktop
video/mp4=mpv.desktop
video/x-matroska=mpv.desktop
video/webm=mpv.desktop
video/x-flv=mpv.deskto
x-scheme-handler/http=chromium.desktop
x-scheme-handler/https=chromium.desktop
x-scheme-handler/about=chromium.desktop
x-scheme-handler/unknown=chromium.desktop
EOF
################################################################################

################################################################################
## configuration de nautilus
##------------------------------------------------------------------------------
# a priori, il n'est pas possible de modifier ou de supprimer les options du click droit de nautilus, il est simplement possible d'en ajouter de nouveaux
# une manière de contourner les problème est de supprimer l'extension rajouter lors de l'installation d'un paquet dans le répertoire /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/
# ref : [gnome - Edit/Remove existing File Manager (right-click/context menu) actions - Ask Ubuntu](https://askubuntu.com/questions/1300049/edit-remove-existing-file-manager-right-click-context-menu-actions/1300079#1300079)
# par exemple le paquet nautilus-wipe rajoute des entrés dans le clic droit assez dangereuses comme "Ecraser" et "Ecraser l'espace disque disponnible"
# pour supprimer ces entrées des options de clic droit de nautilus, il faut soit désinstaller le paquet, soit supprimer le .so correspondant dans le répertoire des extensions de nautilus
mv /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/libnautilus-wipe.so /usr/lib/x86_64-linux-gnu/nautilus/extensions-3.0/libnautilus-wipe.so.backup

# pour supprimer des options internes à nautilus, il faudrait modifier son code source et le recompiler
# ref : [Comment supprimer Change Desktop Background du clic droit?](https://qastack.fr/ubuntu/34803/how-to-remove-change-desktop-background-from-right-click)
################################################################################


#[desktop/interface]
#gtk-theme='Bubble-Dark-Blue'
#icon-theme='Papirus'

################################################################################
## configuration de l'audio
##------------------------------------------------------------------------------
displayandexec "Désactivation du microphone                         " "$ExeAsUser amixer set Capture nocap"
displayandexec "Réglage du volume audio à 10%                       " "$ExeAsUser amixer set Master 10%"
# Les deux commandes amixer ne fonctionnenet pas dans une install sur bullseye. A priori le problème serrait lié au fait qu'elles sont lancés depuis des sudo -u user.
# Les commandes fonctionnement parfaitement si elles sont lancés depuis le user dans un terminal.
################################################################################



# /.local/share/gnome-shell/extensions/

# [Added Associations]
# application/x-shellscript=atom.desktop;
# application/octet-stream=atom.desktop;
# application/x-php=atom.desktop;

################################################################################
## configuration spéficique pour le pc pro
##------------------------------------------------------------------------------
configure_for_pro() {
    echo "conf pro"
}
if [ "$conf_pro" == 1 ]; then
    configure_for_pro
fi
################################################################################

################################################################################
## configuration spéficique pour le pc perso
##------------------------------------------------------------------------------
configure_for_perso() {
#     $ExeAsUser cat> tmp_conf_dconf_perso << EOF
# [gnome/settings-daemon/plugins/media-keys]
# custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']
#
# [gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
# binding='<Primary><Shift>y'
# command='/usr/bin/eteindreecran'
# name='réactiver l ecran'
# [gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3]
# binding='<Primary><Shift>h'
# command='/usr/bin/redemarerecran'
# name="réactiver l écran du PC avec les paramètres à gauche de l écran principal"
# EOF
#     $ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$local_user_UID/bus" dconf load /org/ < tmp_conf_dconf_perso

  install_redemarerecran() {
  #redemarerecran
  displayandexec "Installation du script redemarerecran               " "\
  echo 'xrandr --output eDP-1 --left-of HDMI-1 --auto' > /usr/bin/redemarerecran && \
  chmod +x /usr/bin/redemarerecran"

  # pour obtenir le nom des écrans : xrandr -q
  # https://askubuntu.com/questions/62858/turn-off-monitor-using-command-line
  }
  install_redemarerecran

  install_eteindreecran() {
  #eteindreecran
  displayandexec "Installation du script eteindreecran                " "\
  echo 'xrandr --output eDP-1 --off' > /usr/bin/eteindreecran && \
  chmod +x /usr/bin/eteindreecran"
  }
  install_eteindreecran

  CustomGnomeShortcut "eteindre l ecran" "/usr/bin/eteindreecran" "<Primary><Shift>y"
  CustomGnomeShortcut "réactiver l écran du PC avec les paramètres à gauche de l écran principal" "/usr/bin/redemarerecran" "<Primary><Shift>h"
}
if [ "$conf_perso" == 1 ]; then
    configure_for_perso
fi
################################################################################

# apparement obligatoire pour executer Signal
chmod 4755 /opt/Signal/chrome-sandbox

# apparement obligatoire pour executer balena-etcher
chmod 4755 /opt/balenaEtcher/chrome-sandbox

################################################################################
## configuration du bashrc et du zsh
##------------------------------------------------------------------------------

# alias for the user
$ExeAsUser cat>> /home/"$local_user"/.bashrc << EOF

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
alias i='sudo apt-get install'
alias u='sudo apt-get update'
alias up='sudo apt-get upgrade'
alias upp='sudo apt-get update && sudo apt-get upgrade'
alias uppr='sudo apt-get update && sudo apt-get dist-upgrade'
alias x='exit'
alias xx='sudo shutdown now'
alias xwx='sudo poweroff'
# a priori le stream de funradio ne fonctionne plus
# alias funradio='mpv --cache=no http://streaming.radio.funradio.fr/fun-1-48-192'
alias youtube-dl='youtube-dl -o "%(title)s.%(ext)s"'
alias spyme='sudo lnav /var/log/syslog /var/log/auth.log'
alias ngupp='sudo /usr/bin/sysupdateNG'
alias bat='bat -pp'
alias free='free -ht'
alias showshortcut='dconf dump /org/gnome/settings-daemon/plugins/media-keys/'
alias bitcoin='curl -s "http://api.coindesk.com/v1/bpi/currentprice.json"  | jq ".bpi.EUR.rate" | tr -d \"'
alias sshuttle='sudo sshuttle'
HISTTIMEFORMAT="%Y/%m/%d %T   "
is_bad_hash() { curl https://api.hashdd.com/v1/knownlevel/\$1 ;}

# for Ansible vault editor
export EDITOR=nano

# for python binnary
export PATH="\$PATH:/home/$local_user/.local/bin"
EOF

# alias for root
cat>> /root/.bashrc << EOF

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
alias i='apt-get install'
alias u='apt-get update'
alias up='apt-get upgrade'
alias upp='apt-get update && apt-get upgrade'
alias uppr='apt-get update && apt-get dist-upgrade'
alias x='exit'
alias xx='shutdown now'
alias xwx='poweroff'
alias spyme='lnav /var/log/syslog /var/log/auth.log'
alias bat='bat -pp'
alias free='free -ht'
HISTTIMEFORMAT=\"%Y/%m/%d %T   \"
EOF
displayandexec "Configuration du bashrc                             " "stat /root/.bashrc && stat /home/$local_user/.bashrc"


$ExeAsUser cat>> /home/"$local_user"/.zshrc << 'EOF'
setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
    RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && [ "$color_prompt" = yes ]; then
	. /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
	ZSH_HIGHLIGHT_STYLES[default]=none
	ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[path]=underline
	ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[command-substitution]=none
	ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[process-substitution]=none
	ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[assign]=none
	ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
	ZSH_HIGHLIGHT_STYLES[named-fd]=none
	ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
	ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
	ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a'
    ;;
*)
    ;;
esac

new_line_before_prompt=yes
precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$new_line_before_prompt" = yes ]; then
	if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
	    _NEW_LINE_BEFORE_PROMPT=1
	else
	    print ""
	fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi
EOF
displayandexec "Configuration du zshrc                             " "stat /home/"$local_user"/.zshrc"
# rajouter stat /root/.zshrc &&
# si on  met aussi la conf zsh pour root
################################################################################

# Commande temporaire pour éviter que des fichiers de /home/user/.config n'appartienent à root lors de l'install, sans qu'on comprenne bien pourquoi (executé par ExeAsUser)
chown -R "$local_user":"$local_user" /home/"$local_user"/.config/

################################################################################
## Mise à jour de la base de donnée de rkhunter
##------------------------------------------------------------------------------
displayandexec "Mise à jour de la base de donnée de rkhunter        " "rkhunter --versioncheck ; rkhunter --update ; rkhunter --propupd"
################################################################################

################################################################################
## Execution d'un scan pour détecter la présence de rootkits
##------------------------------------------------------------------------------
# execution de rktscan
# displayandexec "Execution de rktscan                                " "/usr/bin/rktscan"
################################################################################

################################################################################
## création d'un fichier de backup du header LUKS
##------------------------------------------------------------------------------
backup_LUKS_header() {
luks_partition="$(lsblk --fs --list | awk '/crypto_LUKS/{print $1}')"
$ExeAsUser mkdir --parents /home/"$local_user"/backup/
cryptsetup luksHeaderBackup /dev/"$luks_partition" --header-backup-file /home/"$local_user"/backup/LUKS_Header_Backup.img
}
backup_LUKS_header
################################################################################

################################################################################
## désactivation du bluetooth
##------------------------------------------------------------------------------
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" gdbus call --session --dest org.gnome.SettingsDaemon.Rfkill --object-path /org/gnome/SettingsDaemon/Rfkill --method org.freedesktop.DBus.Properties.Set "org.gnome.SettingsDaemon.Rfkill" "BluetoothAirplaneMode" "<true>" > /dev/null
################################################################################

################################################################################
## stoper les services inutiles
##------------------------------------------------------------------------------
# /etc/init.d/knockd stop
# /etc/init.d/fail2ban stop
displayandexec "Redémarage du service SSH                           " "systemctl restart ssh"
################################################################################

################################################################################
## configuration des règles de firewall
##------------------------------------------------------------------------------
displayandexec "Configuration du firewall                           " "\
ufw --force reset && \
ufw default deny incoming && \
ufw default allow outgoing && \
ufw allow "$SSH_Port"/tcp && \
ufw limit "$SSH_Port"/tcp && \
ufw logging high && \
ufw --force enable"
################################################################################

#réapplication de la cond par défaut pour la mise en veille automatique
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'suspend'"
$ExeAsUser DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/"$local_user_UID"/bus" dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'"

# remise au propre du fichier de configuration DNS
rm -f /etc/resolv.conf
mv /etc/resolv.conf.old /etc/resolv.conf

# suppression du dossier temporaire pour l'execution du script
rm -rf "$tmp_dir"

echo '--------------------------------------------------------------------' >> "$log_file"
echo '' >> "$log_file"
echo '####################################################################' >> "$log_file"
echo '#                           Fin du script                          #' >> "$log_file"
echo '####################################################################' >> "$log_file"

echo ''
echo '       ####################################################################'
echo "       #                    L'installation est terminée                   #"
echo '       ####################################################################'
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

################################################################################
## after install options
##------------------------------------------------------------------------------
if [ "$show_log" == 1 ]; then
    more "$log_file"
fi

if [ "$show_only_error" == 1 ]; then
    grep -i 'error' "$install_file"
fi

if [ "$reboot_after_install" == 1 ]; then
    reboot
fi

if [ "$shutdown_after_install" == 1 ]; then
    poweroff
fi
################################################################################

exit 0


# Si la distrib a besoin de rebooter, alors reboot automatique
# [ -f /var/run/reboot-required ] && reboot -f






# a garder dans un coin, très intéressant !
# https://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies








#problème de paquet avec dpkg, essayer les différents truc de ce lien, ça fonctionne
#https://forum.ubuntu-fr.org/viewtopic.php?id=632091








#commandes pour vider la corbeille
# Pour la vider la corbeille utilisateur :
# rm -Rf ~/.local/share/Trash/*

# Pour la vider la corbeille administrateur :
# rm -Rf /root/.local/share/Trash/*






##!/bin/sh
#
#echo -n "Etes-vous fatigué ? "
#read on
#
#case "$on" in
#    oui | o | O | Oui | OUI ) echo "Allez faire du café !";;
#    non | n | N | Non | NON ) echo "Programmez !";;
#    * ) echo "Ah bon ?";;
#esac
#exit 0

#if [ -x /bin/sh ] ; then
#	echo "/bin/sh est exécutable. C'est bien."
#else
#	echo "/bin/sh n'est pas exécutable."
#fi
#OU [ -x /bin/sh ] || echo "/bin/sh n'est pas exécutable."









#read -p "Voulez-vous redémarer maintenant ?[O/n] " reponse
#if [[ $reponse = "o" || $reponse = "O" || $reponse = "" ]]; then
#    reboot
#else
#    exit 0
#fi













# Not an interactive shell?
# [[ $- == *i* ]] || return 0





#fmpeg -i fichiervideo.avi -vn -ar 44100 -ac 2 -f wav fichierson.wav
#avconf -i fichiervideo.avi -vn -ar 44100 -ac 2 -f wav fichierson.wav
#avconv -i video.mp4 image%d.png
#ls -1 |grep mkv | awk -F. '{print $1}' | while read entree
# do
#   avconf -i ${entree}.mkv -vn -ar 44100 -ac 2 -f wav ${entree}.wav
# done
#ls -1 |grep mp4 | awk -F. '{print $1}' | while read entree
# do
#   avconf -i ${entree}.mp4 -vn -ar 44100 -ac 2 -f wav ${entree}.wav
# done
#
#
#ls -1 |grep wmv | awk -F. '{print $1}' | while read entree
# do
#   avconv -y -i ${entree}.wmv -s 1280x720  -threads auto -vcodec mpeg4 -an -qscale 1 -mbd rd -flags +mv4+aic -trellis 2 -cmp 2 -subcmp 2 -g 300 -pass 1 -f rawvideo /dev/null
#   avconv -y -i ${entree}.wmv -s 1280x720 -threads auto -vcodec mpeg4 -qscale 1 -mbd rd -flags +mv4+aic -trellis 2 -cmp 2 -subcmp 2 -g 300 -pass 2 ${entree}.mp4
# done
