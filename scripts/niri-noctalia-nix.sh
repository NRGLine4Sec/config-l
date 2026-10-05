#!/usr/bin/env bash
# niri-noctalia-nix.sh
# Installe niri + Noctalia via Nix (profil utilisateur) en parallele de GNOME
# sur Debian 13, avec une session "Niri (Nix)" proposee par GDM.
#
# Usage : niri-noctalia-nix.sh [--install|--update|--uninstall] [--force-config]

set -Eeuo pipefail

# --- Chemins et constantes ---------------------------------------------------
readonly CFG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly FLAKE_DIR="$CFG_HOME/niri-nix"
readonly STATE_DIR="$STATE_HOME/niri-nix"
readonly GPU_LINK="$STATE_DIR/gpu-drivers"
readonly UNIT_DIR="$CFG_HOME/systemd/user"
readonly NIRI_CFG="$CFG_HOME/niri/config.kdl"
readonly NOCTALIA_CFG="$CFG_HOME/noctalia/config.toml"
readonly NOCTALIA_STATE="$STATE_HOME/noctalia/settings.toml"
readonly HYPRLOCK_CFG="$CFG_HOME/hypr/hyprlock.conf"
readonly LOCK_SCRIPT="$HOME/.local/bin/niri-lock"
readonly IDLE_DROPIN="$UNIT_DIR/niri-swayidle.service.d/override.conf"
readonly BACKPORTS_LIST="/etc/apt/sources.list.d/backports.list"
readonly MARKER="Genere par niri-noctalia-nix.sh"
readonly PORTAL_CFG="$CFG_HOME/xdg-desktop-portal/niri-portals.conf"
readonly MIME_LINK="$HOME/.local/share/applications/niri-mimeapps.list"
readonly SESSION_WRAPPER="/usr/local/bin/niri-nix-session"
readonly SESSION_DESKTOP="/usr/local/share/wayland-sessions/niri-nix.desktop"
readonly TMPFILES_CONF="/etc/tmpfiles.d/niri-nix-gpu.conf"
readonly PROFILE_ELEMENT="niri-nix-desktop"
# swaylock reste installe comme verrou de secours (deblocage depuis un TTY)
readonly APT_PACKAGES=(swaylock swayidle mate-polkit xdg-desktop-portal-gnome
                       xdg-desktop-portal-gtk gnome-keyring)
readonly NIX_FLAGS=(--extra-experimental-features "nix-command flakes")
STAMP="$(date +%Y%m%d-%H%M%S)"
readonly STAMP

TERMINAL_CMD="${TERMINAL_CMD:-gnome-terminal}"
ACTION="install"
FORCE_CONFIG=0
BIN=""

# --- Affichage -----------------------------------------------------------------
info()  { printf '\033[1;34m[i]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }
trap 'die "Échec inattendu à la ligne $LINENO (commande : $BASH_COMMAND)."' ERR

usage() {
    cat <<'EOF'
Usage : niri-noctalia-nix.sh [action] [options]

Actions :
  --install       Installe niri + Noctalia et la session GDM (par défaut)
  --update        Met à jour nixpkgs, niri, Noctalia et les pilotes Mesa
  --uninstall     Retire la session et les paquets Nix (garde tes configs)

Options :
  --force-config  Réécrit les configs niri/Noctalia (avec sauvegarde horodatée)
  -h, --help      Affiche cette aide

Variable : TERMINAL_CMD (terminal lancé par Super+T, défaut : gnome-terminal)
EOF
}

parse_args() {
    while (($#)); do
        case "$1" in
            --install)      ACTION="install" ;;
            --update)       ACTION="update" ;;
            --uninstall)    ACTION="uninstall" ;;
            --force-config) FORCE_CONFIG=1 ;;
            -h|--help)      usage; exit 0 ;;
            *) die "Option inconnue : $1 (voir --help)" ;;
        esac
        shift
    done
}

# --- Utilitaires Nix -------------------------------------------------------------
nixc() { nix "${NIX_FLAGS[@]}" "$@"; }

nix_system() {
    case "$(uname -m)" in
        x86_64)  echo "x86_64-linux" ;;
        aarch64) echo "aarch64-linux" ;;
        *) die "Architecture non prise en charge : $(uname -m)" ;;
    esac
}

profile_has_element() {
    nixc profile list --json 2>/dev/null | grep -q "\"$PROFILE_ELEMENT\""
}

profile_add() {
    if nixc profile add --help >/dev/null 2>&1; then
        nixc profile add "$@"
    else
        nixc profile install "$@"
    fi
}

resolve_bin() {
    local p
    for p in "$HOME/.nix-profile" "$STATE_HOME/nix/profile"; do
        if [[ -x "$p/bin/niri" && -x "$p/bin/noctalia" ]]; then
            BIN="$p/bin"
            return 0
        fi
    done
    die "niri ou noctalia introuvable dans le profil Nix après installation."
}

# --- Verifications prealables ----------------------------------------------------
preflight() {
    [[ $EUID -ne 0 ]] || die "Lance ce script avec ton utilisateur, pas en root (sudo est appelé quand il le faut)."

    # shellcheck disable=SC1091
    . /etc/os-release
    [[ "${ID:-}" == "debian" ]] || warn "Distribution détectée : ${ID:-inconnue}. Script prévu pour Debian 13."
    [[ "${VERSION_ID:-}" == "13" ]] || warn "Version Debian détectée : ${VERSION_ID:-inconnue}. Script prévu pour Debian 13 (trixie)."

    command -v nix >/dev/null || die "Nix est introuvable dans le PATH."
    nixc --version >/dev/null || die "La commande nix ne répond pas."

    dpkg-query -W -f='${Status}' gdm3 2>/dev/null | grep -q "install ok installed" \
        || warn "gdm3 n'est pas installé : la session n'apparaîtra que dans un gestionnaire lisant /usr/local/share/wayland-sessions."
    if grep -Eqs '^[[:space:]]*WaylandEnable[[:space:]]*=[[:space:]]*false' /etc/gdm3/daemon.conf; then
        die "Wayland est désactivé dans /etc/gdm3/daemon.conf : GDM masquera la session niri."
    fi

    if command -v lspci >/dev/null && lspci -k 2>/dev/null | grep -q "Kernel driver in use: nvidia"; then
        die "Pilote NVIDIA propriétaire détecté : ce script ne gère que Mesa (Intel/AMD)."
    fi

    if [[ -e /run/opengl-driver && "$(readlink -f /run/opengl-driver)" != "$(readlink -f "$GPU_LINK" 2>/dev/null || true)" ]]; then
        die "/run/opengl-driver existe déjà et ne vient pas de ce script (nixGL, Home Manager ?). Arrêt pour éviter un conflit."
    fi

    info "Demande des droits sudo (paquets apt et fichiers système)."
    sudo -v
}

# --- Paquets Debian ----------------------------------------------------------
install_apt_packages() {
    local -a missing=()
    local p
    for p in "${APT_PACKAGES[@]}"; do
        dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed" || missing+=("$p")
    done
    if ((${#missing[@]})); then
        info "Installation via apt : ${missing[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y --no-install-recommends "${missing[@]}"
    fi
    ok "Paquets Debian présents (verrouillage, polkit, portails, trousseau)."
}

# hyprlock Debian : utilise la pile PAM du systeme, contrairement a un verrou
# construit par Nix (linux-pam de Nix ne comprend pas les @include de Debian)
install_hyprlock() {
    if dpkg-query -W -f='${Status}' hyprlock 2>/dev/null | grep -q "install ok installed"; then
        ok "hyprlock déjà installé."
        return 0
    fi
    local suite="${VERSION_CODENAME:-trixie}-backports"
    if ! grep -rqs -- "$suite" /etc/apt/sources.list /etc/apt/sources.list.d/; then
        info "Activation du dépôt $suite."
        echo "deb http://deb.debian.org/debian $suite main" | sudo tee "$BACKPORTS_LIST" >/dev/null
    fi
    sudo apt-get update -qq
    sudo apt-get install -y -t "$suite" hyprlock
    [[ -f /etc/pam.d/hyprlock ]] || warn "/etc/pam.d/hyprlock absent : hyprlock risque de refuser le mot de passe."
    ok "hyprlock installé depuis $suite."
}

# --- Flake Nix ------------------------------------------------------------------
write_flake() {
    mkdir -p "$FLAKE_DIR" "$STATE_DIR"
    cat >"$FLAKE_DIR/flake.nix" <<'EOF'
{
  description = "niri + Noctalia pour Debian, en parallele de GNOME";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
    in {
      packages = forAll (pkgs: {
        niri-nix-desktop = pkgs.buildEnv {
          name = "niri-nix-desktop";
          paths = [ pkgs.niri pkgs.xwayland-satellite pkgs.noctalia ];
        };
        # Meme revision de nixpkgs que niri et Noctalia : Mesa reste synchrone
        niri-nix-gpu = pkgs.buildEnv {
          name = "niri-nix-gpu";
          paths = [ pkgs.mesa ];
        };
      });
    };
}
EOF
    if [[ ! -f "$FLAKE_DIR/flake.lock" ]]; then
        nixc flake lock "path:$FLAKE_DIR"
    fi
    ok "Flake écrit dans $FLAKE_DIR (révision nixpkgs figée dans flake.lock)."
}

build_gpu_env() {
    info "Construction de l'environnement Mesa (Nix)."
    nixc build "path:$FLAKE_DIR#packages.$(nix_system).niri-nix-gpu" --out-link "$GPU_LINK"
    ok "Pilotes Mesa disponibles : $GPU_LINK"
}

install_profile() {
    local ref system
    system="$(nix_system)"
    ref="path:$FLAKE_DIR#packages.$system.$PROFILE_ELEMENT"
    if profile_has_element; then
        info "Mise à jour de $PROFILE_ELEMENT dans le profil Nix."
        nixc profile upgrade "$PROFILE_ELEMENT"
    else
        info "Ajout de niri, xwayland-satellite et Noctalia au profil Nix."
        profile_add "$ref" \
            || die "Échec de l'ajout au profil. Si ton profil a été créé avec nix-env, il est incompatible avec nix profile."
    fi
    resolve_bin
    ok "niri $("$BIN/niri" --version 2>/dev/null | awk '{print $2}') et Noctalia installés dans $BIN"
}

# --- Fichiers systeme (sudo) ---------------------------------------------------
install_system_files() {
    info "Lien /run/opengl-driver vers les pilotes Mesa Nix (ignoré par les binaires Debian)."
    printf '# Genere par niri-noctalia-nix.sh\nL+ /run/opengl-driver - - - - %s\n' "$GPU_LINK" \
        | sudo tee "$TMPFILES_CONF" >/dev/null
    sudo systemd-tmpfiles --create "$TMPFILES_CONF"

    info "Lanceur de session et entrée GDM."
    sudo install -d -m 0755 "$(dirname "$SESSION_DESKTOP")"
    sudo tee "$SESSION_WRAPPER" >/dev/null <<'EOF'
#!/bin/sh
# Genere par niri-noctalia-nix.sh : lance niri installe via Nix
for p in "$HOME/.nix-profile" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"; do
    if [ -x "$p/bin/niri-session" ]; then
        exec "$p/bin/niri-session" "$@"
    fi
done
echo "niri-session introuvable dans le profil Nix de $USER" >&2
exit 1
EOF
    sudo chmod 0755 "$SESSION_WRAPPER"

    sudo tee "$SESSION_DESKTOP" >/dev/null <<EOF
[Desktop Entry]
Name=Niri (Nix)
Comment=Compositeur Wayland à défilement, installé via Nix
Exec=$SESSION_WRAPPER
Type=Application
DesktopNames=niri
EOF
    ok "Session « Niri (Nix) » ajoutée à GDM."
}

# --- Unites systemd utilisateur ----------------------------------------------------
polkit_agent_path() {
    dpkg -L mate-polkit 2>/dev/null | grep -m1 'polkit-mate-authentication-agent-1$' \
        || die "Agent polkit MATE introuvable (paquet mate-polkit)."
}

install_user_units() {
    mkdir -p "$UNIT_DIR"

    cat >"$UNIT_DIR/niri.service" <<EOF
# Genere par niri-noctalia-nix.sh (copie de l'unite officielle avec chemin absolu)
[Unit]
Description=niri (Nix) : compositeur Wayland à défilement
BindsTo=graphical-session.target
Before=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
Wants=xdg-desktop-autostart.target
Before=xdg-desktop-autostart.target

[Service]
Slice=session.slice
Type=notify
ExecStart=$BIN/niri --session
EOF

    cat >"$UNIT_DIR/niri-shutdown.target" <<'EOF'
[Unit]
Description=Shutdown running niri session
DefaultDependencies=no
StopWhenUnneeded=true
Conflicts=graphical-session.target graphical-session-pre.target
After=graphical-session.target graphical-session-pre.target
EOF

    # Pas de verrouillage sur inactivite ; ecrans eteints apres 10 min,
    # et 30 s apres le verrouillage si on ne deverrouille pas
    cat >"$UNIT_DIR/niri-swayidle.service" <<EOF
# $MARKER
[Unit]
Description=Extinction des écrans et verrouillage avant veille (niri)
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w \\
    timeout 30 'pidof hyprlock && $BIN/niri msg action power-off-monitors' \\
    timeout 600 '$BIN/niri msg action power-off-monitors' \\
    before-sleep '$LOCK_SCRIPT' \\
    lock '$LOCK_SCRIPT'
Restart=on-failure
EOF

    # Ancien override de niri-hyprlock-setup.sh : son contenu est desormais dans l'unite
    if grep -qs 'niri-hyprlock-setup.sh' "$IDLE_DROPIN"; then
        rm -f "$IDLE_DROPIN"
        rmdir --ignore-fail-on-non-empty "$(dirname "$IDLE_DROPIN")"
        info "Ancien override swayidle de niri-hyprlock-setup.sh supprimé."
    fi

    cat >"$UNIT_DIR/niri-polkit.service" <<EOF
[Unit]
Description=Agent d'authentification polkit (MATE) pour niri
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=$(polkit_agent_path)
Restart=on-failure
EOF

    systemctl --user daemon-reload
    systemctl --user add-wants niri.service niri-swayidle.service niri-polkit.service
    ok "Unités systemd utilisateur installées (liées uniquement à la session niri)."
}

# Script genere (pas une config utilisateur) : reecrit a chaque install/update
write_lock_script() {
    mkdir -p "$(dirname "$LOCK_SCRIPT")"
    cat >"$LOCK_SCRIPT" <<EOF
#!/bin/sh
# $MARKER
# Verrouille avec hyprlock (PAM Debian) puis eteint reellement les ecrans
if ! pidof hyprlock >/dev/null; then
    /usr/bin/hyprlock &
fi
sleep 1
$BIN/niri msg action power-off-monitors
EOF
    chmod 0755 "$LOCK_SCRIPT"
    ok "Script de verrouillage écrit : $LOCK_SCRIPT"
}

restart_idle_if_running() {
    if systemctl --user -q is-active niri.service; then
        systemctl --user restart niri-swayidle.service
        ok "swayidle redémarré dans la session niri en cours."
    fi
}

install_portal_and_mime() {
    mkdir -p "$(dirname "$PORTAL_CFG")" "$(dirname "$MIME_LINK")"
    cat >"$PORTAL_CFG" <<'EOF'
[preferred]
default=gnome;gtk;
org.freedesktop.impl.portal.Access=gtk;
org.freedesktop.impl.portal.Notification=gtk;
org.freedesktop.impl.portal.Secret=gnome-keyring;
EOF
    # Reprend les applications par defaut de GNOME sous niri
    if [[ -f /usr/share/applications/gnome-mimeapps.list && ! -e "$MIME_LINK" ]]; then
        ln -s /usr/share/applications/gnome-mimeapps.list "$MIME_LINK"
    fi
    ok "Portails (partage d'écran, sélecteur de fichiers) et applications par défaut configurés."
}

# --- Configurations utilisateur ------------------------------------------------------
# Ecrit un fichier seulement s'il est absent, ou avec --force-config apres sauvegarde
should_write() {
    local f="$1"
    if [[ -e "$f" ]]; then
        if ((FORCE_CONFIG)); then
            cp -a "$f" "$f.bak-$STAMP"
            info "Sauvegarde : $f.bak-$STAMP"
            return 0
        fi
        info "Conservé (déjà présent) : $f"
        return 1
    fi
    mkdir -p "$(dirname "$f")"
    return 0
}

keyboard_layout() {
    localectl status 2>/dev/null | awk -F': *' '/X11 Layout/ {print $2; exit}'
}

workspace_binds() {
    local -a keys
    if [[ "$(keyboard_layout)" == fr* ]]; then
        keys=(ampersand eacute quotedbl apostrophe parenleft minus egrave underscore ccedilla)
    else
        keys=(1 2 3 4 5 6 7 8 9)
    fi
    local i
    for i in "${!keys[@]}"; do
        printf '    Mod+%s { focus-workspace %d; }\n' "${keys[i]}" "$((i + 1))"
        printf '    Mod+Ctrl+%s { move-column-to-workspace %d; }\n' "${keys[i]}" "$((i + 1))"
    done
}

width_binds() {
    if [[ "$(keyboard_layout)" == fr* ]]; then
        printf '    Mod+parenright { set-column-width "-10%%"; }\n'
        printf '    Mod+equal { set-column-width "+10%%"; }\n'
    else
        printf '    Mod+Minus { set-column-width "-10%%"; }\n'
        printf '    Mod+Equal { set-column-width "+10%%"; }\n'
    fi
}

write_niri_config() {
    should_write "$NIRI_CFG" || return 0
    local pictures shots
    pictures="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
    shots="$pictures/Captures d’écran/Capture d’écran du %Y-%m-%d %H-%M-%S.png"

    cat >"$NIRI_CFG" <<EOF
// Genere par niri-noctalia-nix.sh le $STAMP
// Reference : https://niri-wm.github.io/niri/Configuration:-Introduction

input {
    keyboard {
        xkb {
            // Vide : niri reprend la disposition systeme (localectl), comme GNOME
        }
        numlock
    }
    touchpad {
        tap
        dwt
        natural-scroll
    }
}

layout {
    gaps 10
    center-focused-column "on-overflow"
    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
    }
    default-column-width { proportion 0.5; }
    focus-ring {
        width 3
        active-color "#3584e4"
        inactive-color "#505050"
    }
    border {
        off
    }
    shadow {
        on
        softness 30
        spread 4
        offset x=0 y=4
        color "#0006"
    }
}

cursor {
    xcursor-theme "Adwaita"
    xcursor-size 24
}

overview {
    zoom 0.5
}

environment {
    ELECTRON_OZONE_PLATFORM_HINT "auto"
}

xwayland-satellite {
    path "$BIN/xwayland-satellite"
}

screenshot-path "$shots"

spawn-at-startup "$BIN/noctalia"

window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}

window-rule {
    match app-id="dev.noctalia.Noctalia"
    open-floating true
    default-column-width { fixed 1080; }
    default-window-height { fixed 920; }
}

// Fond d'ecran floute dans la vue d'ensemble, facon Activites
layer-rule {
    match namespace="^noctalia-backdrop"
    place-within-backdrop true
}

debug {
    honor-xdg-activation-with-invalid-serial
}

binds {
    Mod+Shift+Slash { show-hotkey-overlay; }

    // Raccourcis inspires de GNOME
    Mod+A hotkey-overlay-title="Applications" { spawn "$BIN/noctalia" "msg" "panel-toggle" "launcher"; }
    Mod+S hotkey-overlay-title="Réglages rapides" { spawn "$BIN/noctalia" "msg" "panel-toggle" "control-center"; }
    Mod+Comma hotkey-overlay-title="Paramètres Noctalia" { spawn "$BIN/noctalia" "msg" "settings-toggle"; }
    Mod+T hotkey-overlay-title="Terminal" { spawn "$TERMINAL_CMD"; }
    Ctrl+Alt+T { spawn "$TERMINAL_CMD"; }
    Mod+E hotkey-overlay-title="Fichiers" { spawn "nautilus" "--new-window"; }
    Mod+L hotkey-overlay-title="Verrouiller" { spawn "$LOCK_SCRIPT"; }
    Mod+O repeat=false { toggle-overview; }
    Mod+Q repeat=false { close-window; }
    Alt+F4 repeat=false { close-window; }

    XF86AudioRaiseVolume allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-up"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-down"; }
    XF86AudioMute allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-mute"; }
    XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
    XF86MonBrightnessUp allow-when-locked=true { spawn "$BIN/noctalia" "msg" "brightness-up"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "$BIN/noctalia" "msg" "brightness-down"; }

    // Navigation (fleches uniquement, Mod+L etant reserve au verrouillage)
    // Haut/Bas changent d'espace de travail comme GNOME, sauf fenetres empilees
    Mod+Left  { focus-column-left; }
    Mod+Right { focus-column-right; }
    Mod+Up    { focus-window-or-workspace-up; }
    Mod+Down  { focus-window-or-workspace-down; }
    Mod+Ctrl+Left  { move-column-left; }
    Mod+Ctrl+Right { move-column-right; }
    Mod+Ctrl+Up    { move-window-up-or-to-workspace-up; }
    Mod+Ctrl+Down  { move-window-down-or-to-workspace-down; }
    Mod+Home { focus-column-first; }
    Mod+End  { focus-column-last; }

    Mod+Shift+Left  { focus-monitor-left; }
    Mod+Shift+Right { focus-monitor-right; }
    Mod+Shift+Up    { focus-monitor-up; }
    Mod+Shift+Down  { focus-monitor-down; }
    Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
    Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

    Mod+Page_Down      { focus-workspace-down; }
    Mod+Page_Up        { focus-workspace-up; }
    Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
    Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

$(workspace_binds)

    Mod+R { switch-preset-column-width; }
    Mod+Shift+R { switch-preset-column-width-back; }
    Mod+Ctrl+R { reset-window-height; }
$(width_binds)
    Mod+F { maximize-column; }
    Mod+M { maximize-window-to-edges; }
    Mod+Shift+F { fullscreen-window; }
    Mod+C { center-column; }
    Mod+V { toggle-window-floating; }
    Mod+Shift+V { switch-focus-between-floating-and-tiling; }
    Mod+W { toggle-column-tabbed-display; }
    Mod+BracketLeft  { consume-or-expel-window-left; }
    Mod+BracketRight { consume-or-expel-window-right; }

    Print { screenshot; }
    Ctrl+Print { screenshot-screen; }
    Alt+Print { screenshot-window; }

    Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
    Mod+Shift+P { power-off-monitors; }
    Mod+Shift+E { quit; }
    Ctrl+Alt+Delete { quit; }
}

// Ecrans propres a la machine (positions, echelles), hors de ce fichier.
// Facultatif : niri l'ignore s'il n'existe pas (niri >= 26.04).
include optional=true "outputs.kdl"
EOF
    ok "Config niri écrite : $NIRI_CFG"
}

# Config niri conservee d'une version precedente : bascule Mod+L vers hyprlock
migrate_niri_lock_bind() {
    grep -Eq '^[[:space:]]*Mod\+L[[:space:]].*swaylock' "$NIRI_CFG" || return 0
    local new_line="    Mod+L hotkey-overlay-title=\"Verrouiller\" { spawn \"$LOCK_SCRIPT\"; }"
    cp -a "$NIRI_CFG" "$NIRI_CFG.bak-$STAMP"
    sed -Ei "s|^[[:space:]]*Mod\+L[[:space:]].*swaylock.*$|${new_line}|" "$NIRI_CFG"
    if ! "$BIN/niri" validate -c "$NIRI_CFG" >/dev/null 2>&1; then
        cp -a "$NIRI_CFG.bak-$STAMP" "$NIRI_CFG"
        warn "Impossible de basculer Mod+L vers hyprlock : config niri restaurée."
        return 0
    fi
    ok "Mod+L bascule de swaylock vers $LOCK_SCRIPT (sauvegarde : $NIRI_CFG.bak-$STAMP)."
}

write_noctalia_config() {
    should_write "$NOCTALIA_CFG" || return 0
    cat >"$NOCTALIA_CFG" <<'EOF'
# Genere par niri-noctalia-nix.sh : base "facon GNOME"
# Reference complete : https://docs.noctalia.dev/noctalia/configuration/

[shell]
font_family = "Adwaita Sans"
telemetry_enabled = false
polkit_agent = false                        # agent fourni par mate-polkit (Debian)
niri_overview_type_to_launch_enabled = true # taper dans la vue d'ensemble ouvre la recherche

[shell.launcher]
app_grid = true
categories = false
fetch_exchange_rates = false

[theme]
mode = "dark"
source = "builtin"
builtin = "Noctalia"

[theme.templates]
enable_builtin_templates = true
builtin_ids = []                  # aucun theme ecrit dans les configs GTK/Qt
enable_community_templates = false
community_ids = []

[backdrop]
enabled = true

[lockscreen]
enabled = false                   # verrouillage assure par hyprlock (PAM Debian)
lock_before_suspend = false       # sinon le verrou Noctalia (PAM Nix) bloque au reveil

[osd]
position = "bottom_center"

[dock]
enabled = true
position = "bottom"
show_running = true           # ajoute aussi les applis ouvertes non epinglees
launcher_position = "end"     # bouton grille d'applications a droite, comme le dash GNOME
launcher_icon = "grid-dots"
icon_size = 44
show_dots = true              # point sous les applis ouvertes
magnification = false         # pas d'effet loupe facon macOS
auto_hide = false
reserve_space = true          # les fenetres ne passent pas sous le dock
pinned = [
  "brave-browser",
  "chromium",
  "org.gnome.Terminal",
  "org.gnome.Nautilus",
  "signal-desktop",
  "joplin",
  "firefox-esr",
  "firefox-esr-private",
  "dev.zed.Zed",
  "org.gnome.Todo",
  "veracrypt",
  "spotify",
  "libreoffice-writer",
  "io.github.totoshko88.RustConn"
]

[bar.main]
position = "top"
thickness = 32
background_opacity = 1.0
radius = 0
margin_ends = 0
margin_edge = 0
padding = 10
shadow = false
capsule = false
start  = ["workspaces"]
center = ["clock", "notifications"]
end    = ["tray", "network", "bluetooth", "volume", "battery", "control-center"]

[widget.clock]
format = "{:%a %e %b  %H:%M}"
EOF
    ok "Config Noctalia écrite : $NOCTALIA_CFG"
}

# Force une cle dans une section TOML (cree la section ou la cle si besoin).
# Ne reecrit le fichier (avec sauvegarde) que s'il change.
set_toml_key() {
    local file="$1" section="$2" key="$3" value="$4" tmp
    tmp="$(mktemp)"
    awk -v sec="[$section]" -v key="$key" -v val="$value" '
        function flush() { while (blanks > 0) { print ""; blanks-- } }
        BEGIN { insec = 0; found = 0; done = 0; blanks = 0 }
        /^[[:space:]]*$/ { blanks++; next }
        /^\[/ {
            if (insec && !done) { print key " = " val; done = 1 }
            flush()
            insec = ($0 == sec)
            if (insec) found = 1
            print; next
        }
        insec && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
            line = $0
            sub(/^[^=]*=[[:space:]]*/, "", line)
            if (line ~ "^" val "([[:space:]]|#|$)") print
            else print key " = " val
            flush(); done = 1; next
        }
        { flush(); print }
        END {
            if (insec && !done) print key " = " val
            else if (!found) { print ""; print sec; print key " = " val }
            flush()
        }' "$file" >"$tmp"
    if ! cmp -s "$tmp" "$file"; then
        [[ -e "$file.bak-$STAMP" ]] || cp -a "$file" "$file.bak-$STAMP"
        cat "$tmp" >"$file"
        info "$file : [$section] $key = $value"
    fi
    rm -f "$tmp"
}

# Le verrou Noctalia passe par le PAM de Nix et refuse le mot de passe sous
# Debian : on le coupe aussi dans les reglages GUI, qui priment sur config.toml
neutralize_noctalia_lock() {
    local f
    for f in "$NOCTALIA_CFG" "$NOCTALIA_STATE"; do
        [[ -f "$f" ]] || continue
        if [[ "$f" == "$NOCTALIA_STATE" ]] && ! grep -q '^\[lockscreen\]' "$f"; then
            continue
        fi
        set_toml_key "$f" lockscreen enabled false
        set_toml_key "$f" lockscreen lock_before_suspend false
    done
    ok "Verrouillage Noctalia désactivé (hyprlock s'en charge)."
}

write_hyprlock_config() {
    should_write "$HYPRLOCK_CFG" || return 0
    cat >"$HYPRLOCK_CFG" <<'EOF'
# Genere par niri-noctalia-nix.sh
general {
    hide_cursor = true
    ignore_empty_input = true
}

background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
    brightness = 0.6
}

label {
    monitor =
    text = $TIME
    font_size = 96
    font_family = Adwaita Sans
    color = rgba(255, 255, 255, 1.0)
    position = 0, 160
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:60000] date +"%A %e %B"
    font_size = 22
    font_family = Adwaita Sans
    color = rgba(255, 255, 255, 0.85)
    position = 0, 80
    halign = center
    valign = center
}

input-field {
    monitor =
    size = 320, 56
    outline_thickness = 2
    rounding = 14
    inner_color = rgba(30, 30, 30, 0.6)
    outer_color = rgba(53, 132, 228, 1.0)
    check_color = rgba(53, 132, 228, 1.0)
    fail_color = rgba(224, 27, 36, 1.0)
    font_color = rgba(255, 255, 255, 1.0)
    placeholder_text = Mot de passe
    fail_text = Mot de passe incorrect
    dots_center = true
    fade_on_empty = false
    position = 0, -40
    halign = center
    valign = center
}
EOF
    ok "Config hyprlock écrite : $HYPRLOCK_CFG"
}

validate_configs() {
    "$BIN/niri" validate -c "$NIRI_CFG" \
        || die "La config niri est invalide : corrige $NIRI_CFG avant de te connecter."
    if ! "$BIN/noctalia" config validate "$NOCTALIA_CFG"; then
        warn "Noctalia signale des erreurs dans $NOCTALIA_CFG (non bloquant, les clés inconnues sont ignorées)."
    fi
    ok "Configurations validées."
}

# --- Actions ------------------------------------------------------------------
do_install() {
    preflight
    install_apt_packages
    install_hyprlock
    write_flake
    build_gpu_env
    install_profile
    install_system_files
    write_lock_script
    install_user_units
    install_portal_and_mime
    write_niri_config
    migrate_niri_lock_bind
    write_noctalia_config
    neutralize_noctalia_lock
    write_hyprlock_config
    validate_configs
    restart_idle_if_running
    cat <<EOF

Installation terminée.
  1. Déconnecte-toi de GNOME.
  2. Dans GDM, choisis ton utilisateur, puis l'engrenage en bas à droite : « Niri (Nix) ».
  3. Une fois connecté : Mod+Maj+/ affiche les raccourcis, Mod+A ouvre les applications,
     Mod+L verrouille (hyprlock) et éteint les écrans.

Écrans propres à ta machine : à décrire dans $(dirname "$NIRI_CFG")/outputs.kdl (facultatif).

Si hyprlock refuse ton mot de passe : Ctrl+Alt+F3, connexion, puis
  pkill -x hyprlock
  WAYLAND_DISPLAY=\$(basename "\$(ls /run/user/\$(id -u)/wayland-? | head -1)") swaylock -f

Diagnostic : journalctl --user -u niri.service -b
Mise à jour : $0 --update
Retour arrière : $0 --uninstall (tes configs sont conservées)
EOF
}

do_update() {
    preflight
    [[ -f "$FLAKE_DIR/flake.nix" ]] || die "Flake absent : lance d'abord --install."
    info "Mise à jour de la révision nixpkgs."
    nixc flake update --flake "path:$FLAKE_DIR"
    build_gpu_env
    install_profile
    install_hyprlock
    write_lock_script
    install_user_units
    migrate_niri_lock_bind
    neutralize_noctalia_lock
    write_hyprlock_config
    validate_configs
    restart_idle_if_running
    ok "Mise à jour terminée : déconnecte-toi puis reconnecte-toi à la session niri pour l'appliquer."
}

do_uninstall() {
    [[ "${XDG_CURRENT_DESKTOP:-}" != *niri* ]] \
        || die "Lance la désinstallation depuis la session GNOME, pas depuis niri."
    sudo -v

    if profile_has_element; then
        nixc profile remove "$PROFILE_ELEMENT"
        ok "Paquets retirés du profil Nix."
    fi

    systemctl --user disable niri-swayidle.service niri-polkit.service 2>/dev/null || true
    rm -rf "$UNIT_DIR/niri.service.wants"
    rm -f "$UNIT_DIR/niri.service" "$UNIT_DIR/niri-shutdown.target" \
          "$UNIT_DIR/niri-swayidle.service" "$UNIT_DIR/niri-polkit.service"
    if grep -qs 'niri-hyprlock-setup.sh' "$IDLE_DROPIN"; then
        rm -f "$IDLE_DROPIN"
        rmdir --ignore-fail-on-non-empty "$(dirname "$IDLE_DROPIN")"
    fi
    systemctl --user daemon-reload

    if grep -qs -e "$MARKER" -e 'niri-hyprlock-setup.sh' "$LOCK_SCRIPT"; then
        rm -f "$LOCK_SCRIPT"
    fi

    rm -f "$PORTAL_CFG"
    if [[ -L "$MIME_LINK" ]]; then
        rm -f "$MIME_LINK"
    fi

    sudo rm -f "$SESSION_DESKTOP" "$SESSION_WRAPPER" "$TMPFILES_CONF"
    if [[ -L /run/opengl-driver && "$(readlink /run/opengl-driver)" == "$GPU_LINK" ]]; then
        sudo rm -f /run/opengl-driver
    fi
    rm -f "$GPU_LINK"

    cat <<EOF

Désinstallation terminée. Conservé volontairement :
  - configs : $NIRI_CFG, $NOCTALIA_CFG, $HYPRLOCK_CFG
  - flake : $FLAKE_DIR
  - paquets apt : ${APT_PACKAGES[*]} hyprlock
Pour libérer l'espace Nix : nix-collect-garbage
EOF
}

main() {
    parse_args "$@"
    case "$ACTION" in
        install)   do_install ;;
        update)    do_update ;;
        uninstall) do_uninstall ;;
    esac
}

main "$@"