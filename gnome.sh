# configuration de l'environnement de bureau Gnome


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
favorite-apps=['brave-browser.desktop', 'chromium.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'signal-desktop.desktop', 'joplin.desktop', 'firefox-esr.desktop', 'firefox-esr-private.desktop', 'dev.zed.Zed.desktop', 'org.gnome.Todo.desktop', 'veracrypt.desktop', 'spotify.desktop', 'libreoffice-writer.desktop', 'io.github.totoshko88.RustConn.desktop']
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
CustomGnomeShortcut "Appairer automatiquement avec le peripherique bluetooth" ""$my_user_bin_path"/appairmebt" "<Super><Alt>b"
CustomGnomeShortcut "désactiver le bluetooth" ""$my_user_bin_path"/desactivebt" "<Primary><Alt>b"

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