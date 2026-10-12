#!/usr/bin/env bash
# niri-noctalia-nix.sh
# Installe niri + Noctalia via Nix (profil utilisateur) en parallèle de GNOME
# sur Debian 13, avec une session "Niri (Nix)" proposée par GDM.
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
readonly COLUMN_DOWN="$HOME/.local/bin/niri-column-down"
readonly IDLE_DROPIN="$UNIT_DIR/niri-swayidle.service.d/override.conf"
readonly BACKPORTS_LIST="/etc/apt/sources.list.d/backports.list"
readonly MARKER="Généré par niri-noctalia-nix.sh"
readonly PORTAL_CFG="$CFG_HOME/xdg-desktop-portal/niri-portals.conf"
readonly MIME_LINK="$HOME/.local/share/applications/niri-mimeapps.list"
# Préfixe 99 : appliqué après /etc/environment (99-environment.conf), qui peut
# redéfinir PATH
readonly SESSION_ENV="$CFG_HOME/environment.d/99-niri-nix.conf"
readonly SESSION_WRAPPER="/usr/local/bin/niri-nix-session"
readonly SESSION_DESKTOP="/usr/local/share/wayland-sessions/niri-nix.desktop"
readonly TMPFILES_CONF="/etc/tmpfiles.d/niri-nix-gpu.conf"
readonly PROFILE_ELEMENT="niri-nix-desktop"
# swaylock reste installé comme verrou de secours (déblocage depuis un TTY)
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
trap 'die "Unexpected failure at line $LINENO (command: $BASH_COMMAND)."' ERR

usage() {
    cat <<'EOF'
Usage: niri-noctalia-nix.sh [action] [options]

Actions:
  --install       Install niri + Noctalia and the GDM session (default)
  --update        Update nixpkgs, niri, Noctalia and the Mesa drivers
  --uninstall     Remove the session and the Nix packages (keeps your configs)

Options:
  --force-config  Rewrite the niri/Noctalia/hyprlock configs (timestamped backup)
  -h, --help      Show this help

Variable: TERMINAL_CMD (terminal started by Super+T, default: gnome-terminal)
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
            *) die "Unknown option: $1 (see --help)" ;;
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
    # "nix profile install" a été renommé "add" dans les versions récentes
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
    die "niri or noctalia not found in the Nix profile after installation."
}

# --- Vérifications préalables ----------------------------------------------------
preflight() {
    [[ $EUID -ne 0 ]] || die "Run this script as your regular user, not as root (sudo is called when needed)."

    # shellcheck disable=SC1091
    . /etc/os-release
    [[ "${ID:-}" == "debian" ]] || warn "Detected distribution: ${ID:-unknown}. This script targets Debian 13."
    [[ "${VERSION_ID:-}" == "13" ]] || warn "Detected Debian version: ${VERSION_ID:-unknown}. This script targets Debian 13 (trixie)."

    command -v nix >/dev/null || die "Nix not found in PATH."
    nixc --version >/dev/null || die "The nix command does not respond."

    dpkg-query -W -f='${Status}' gdm3 2>/dev/null | grep -q "install ok installed" \
        || warn "gdm3 is not installed: the session will only show up in a display manager reading /usr/local/share/wayland-sessions."
    if grep -Eqs '^[[:space:]]*WaylandEnable[[:space:]]*=[[:space:]]*false' /etc/gdm3/daemon.conf; then
        die "Wayland is disabled in /etc/gdm3/daemon.conf: GDM would hide the niri session."
    fi

    if command -v lspci >/dev/null && lspci -k 2>/dev/null | grep -q "Kernel driver in use: nvidia"; then
        die "Proprietary NVIDIA driver detected: this script only supports Mesa (Intel/AMD)."
    fi

    if [[ -e /run/opengl-driver && "$(readlink -f /run/opengl-driver)" != "$(readlink -f "$GPU_LINK" 2>/dev/null || true)" ]]; then
        die "/run/opengl-driver already exists and was not created by this script (nixGL, Home Manager?). Stopping to avoid a conflict."
    fi

    info "Requesting sudo (apt packages and system files)."
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
        info "Installing with apt: ${missing[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y --no-install-recommends "${missing[@]}"
    fi
    ok "Debian packages present (locker, polkit, portals, keyring)."
}

# hyprlock Debian : utilise la pile PAM du système, contrairement à un verrou
# construit par Nix (linux-pam de Nix ne comprend pas les @include de Debian)
install_hyprlock() {
    if dpkg-query -W -f='${Status}' hyprlock 2>/dev/null | grep -q "install ok installed"; then
        ok "hyprlock already installed."
        return 0
    fi
    local suite="${VERSION_CODENAME:-trixie}-backports"
    if ! grep -rqs -- "$suite" /etc/apt/sources.list /etc/apt/sources.list.d/; then
        info "Enabling the $suite repository."
        echo "deb http://deb.debian.org/debian $suite main" | sudo tee "$BACKPORTS_LIST" >/dev/null
    fi
    sudo apt-get update -qq
    sudo apt-get install -y -t "$suite" hyprlock
    [[ -f /etc/pam.d/hyprlock ]] || warn "/etc/pam.d/hyprlock is missing: hyprlock may reject your password."
    ok "hyprlock installed from $suite."
}

# --- Flake Nix ------------------------------------------------------------------
write_flake() {
    mkdir -p "$FLAKE_DIR" "$STATE_DIR"
    cat >"$FLAKE_DIR/flake.nix" <<'EOF'
{
  description = "niri + Noctalia for Debian, alongside GNOME";

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
        # Même révision de nixpkgs que niri et Noctalia : Mesa reste synchrone
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
    ok "Flake written to $FLAKE_DIR (nixpkgs revision pinned in flake.lock)."
}

build_gpu_env() {
    info "Building the Mesa environment (Nix)."
    nixc build "path:$FLAKE_DIR#packages.$(nix_system).niri-nix-gpu" --out-link "$GPU_LINK"
    ok "Mesa drivers available: $GPU_LINK"
}

install_profile() {
    local ref system
    system="$(nix_system)"
    ref="path:$FLAKE_DIR#packages.$system.$PROFILE_ELEMENT"
    if profile_has_element; then
        info "Upgrading $PROFILE_ELEMENT in the Nix profile."
        nixc profile upgrade "$PROFILE_ELEMENT"
    else
        info "Adding niri, xwayland-satellite and Noctalia to the Nix profile."
        profile_add "$ref" \
            || die "Failed to add to the profile. A profile created with nix-env is not compatible with nix profile."
    fi
    resolve_bin
    ok "niri $("$BIN/niri" --version 2>/dev/null | awk '{print $2}') and Noctalia installed in $BIN"
}

# --- Fichiers système (sudo) ---------------------------------------------------
install_system_files() {
    info "Linking /run/opengl-driver to the Nix Mesa drivers (ignored by Debian binaries)."
    printf '# Généré par niri-noctalia-nix.sh\nL+ /run/opengl-driver - - - - %s\n' "$GPU_LINK" \
        | sudo tee "$TMPFILES_CONF" >/dev/null
    sudo systemd-tmpfiles --create "$TMPFILES_CONF"

    info "Session launcher and GDM entry."
    sudo install -d -m 0755 "$(dirname "$SESSION_DESKTOP")"
    sudo tee "$SESSION_WRAPPER" >/dev/null <<'EOF'
#!/bin/sh
# Généré par niri-noctalia-nix.sh : lance niri installé via Nix
for p in "$HOME/.nix-profile" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"; do
    if [ -x "$p/bin/niri-session" ]; then
        exec "$p/bin/niri-session" "$@"
    fi
done
echo "niri-session not found in the Nix profile of $USER" >&2
exit 1
EOF
    sudo chmod 0755 "$SESSION_WRAPPER"

    sudo tee "$SESSION_DESKTOP" >/dev/null <<EOF
[Desktop Entry]
Name=Niri (Nix)
Comment=Scrollable-tiling Wayland compositor, installed with Nix
Exec=$SESSION_WRAPPER
Type=Application
DesktopNames=niri
EOF
    ok "\"Niri (Nix)\" session added to GDM."
}

# --- Unités systemd utilisateur ----------------------------------------------------
polkit_agent_path() {
    dpkg -L mate-polkit 2>/dev/null | grep -m1 'polkit-mate-authentication-agent-1$' \
        || die "MATE polkit agent not found (mate-polkit package)."
}

install_user_units() {
    mkdir -p "$UNIT_DIR"

    cat >"$UNIT_DIR/niri.service" <<EOF
# Généré par niri-noctalia-nix.sh (copie de l'unité officielle avec chemin absolu)
[Unit]
Description=niri (Nix): scrollable-tiling Wayland compositor
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

    # Aucune action sur inactivité : verrouillage avant la mise en veille et sur
    # demande (loginctl lock-session). L'extinction après 30 s d'inactivité
    # pendant le verrouillage est gérée par niri-lock lui-même.
    cat >"$UNIT_DIR/niri-swayidle.service" <<EOF
# $MARKER
[Unit]
Description=Lock before sleep and on request (niri)
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w \\
    before-sleep '$LOCK_SCRIPT' \\
    lock '$LOCK_SCRIPT'
Restart=on-failure
EOF

    # Ancien override de niri-hyprlock-setup.sh : son contenu est désormais dans l'unité
    if grep -qs 'niri-hyprlock-setup.sh' "$IDLE_DROPIN"; then
        rm -f "$IDLE_DROPIN"
        rmdir --ignore-fail-on-non-empty "$(dirname "$IDLE_DROPIN")"
        info "Removed the old swayidle override from niri-hyprlock-setup.sh."
    fi

    cat >"$UNIT_DIR/niri-polkit.service" <<EOF
[Unit]
Description=Polkit authentication agent (MATE) for niri
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=$(polkit_agent_path)
Restart=on-failure
EOF

    systemctl --user daemon-reload
    systemctl --user add-wants niri.service niri-swayidle.service niri-polkit.service
    ok "systemd user units installed (tied to the niri session only)."
}

# Script généré (pas une config utilisateur) : réécrit à chaque install/update
write_lock_script() {
    mkdir -p "$(dirname "$LOCK_SCRIPT")"
    cat >"$LOCK_SCRIPT" <<EOF
#!/bin/sh
# $MARKER
# Verrouille avec hyprlock (PAM Debian) et éteint réellement les écrans ;
# tant que la session reste verrouillée, 30 s d'inactivité les rééteignent.
NIRI="$BIN/niri"
EOF
    cat >>"$LOCK_SCRIPT" <<'EOF'
# /proc plutôt que pidof, absent de certaines installations Debian 13
locked() { grep -qsx hyprlock /proc/[0-9]*/comm; }

if [ "${1:-}" = --watch ]; then
    # swayidle dédié au verrouillage : se réarme à chaque réveil des écrans
    sleep 2
    /usr/bin/swayidle timeout 30 "$NIRI msg action power-off-monitors" &
    idle=$!
    while locked; do sleep 2; done
    kill "$idle"
    exit 0
fi

if ! locked; then
    # Lancés par niri : hyprlock ne dépend pas du service qui a demandé le
    # verrou (un redémarrage de swayidle ne peut pas déverrouiller la session)
    "$NIRI" msg action spawn -- /usr/bin/hyprlock
    "$NIRI" msg action spawn -- "$0" --watch
fi
sleep 1
"$NIRI" msg action power-off-monitors
EOF
    chmod 0755 "$LOCK_SCRIPT"
    ok "Lock script written: $LOCK_SCRIPT"
}

# Mod+Bas façon GNOME : niri n'a pas d'action qui réduit la colonne d'un cran
# sans boucler (switch-preset-column-width-back repasse au plus large une fois
# au plus étroit). Script généré, réécrit à chaque install/update.
write_column_down_script() {
    mkdir -p "$(dirname "$COLUMN_DOWN")"
    cat >"$COLUMN_DOWN" <<EOF
#!/usr/bin/env python3
# $MARKER
# Mod+Bas façon GNOME : écran complet → demi-écran → tiers d'écran, sans boucler
import json
import subprocess
import sys

NIRI = "$BIN/niri"
EOF
    cat >>"$COLUMN_DOWN" <<'EOF'


def niri(*args):
    return subprocess.run([NIRI, *args], capture_output=True, text=True, check=True).stdout


window = json.loads(niri("msg", "--json", "focused-window"))
output = json.loads(niri("msg", "--json", "focused-output"))
if not window or not output or not output.get("logical"):
    sys.exit(0)

# Largeur de la tuile rapportée à celle de l'écran : ~1 en écran complet,
# ~0,5 en demi-écran, ~0,33 au tiers (les marges expliquent l'écart)
ratio = window["layout"]["tile_size"][0] / output["logical"]["width"]
target = "50%" if ratio > 0.75 else "33.333%" if ratio > 0.4 else None
if target:
    niri("msg", "action", "set-column-width", target)
EOF
    chmod 0755 "$COLUMN_DOWN"
    ok "Column resize helper written: $COLUMN_DOWN"
}

restart_idle_if_running() {
    if systemctl --user -q is-active niri.service; then
        systemctl --user restart niri-swayidle.service
        ok "swayidle restarted in the running niri session."
    fi
}

# Le profil Nix n'est ajouté à PATH et XDG_DATA_DIRS que par les shells de
# connexion : niri, lancé comme service systemd, ne voit donc ni les binaires
# ni les lanceurs .desktop des applis Nix (absentes de Noctalia, clic sans
# effet). environment.d s'applique à toute la session utilisateur systemd ;
# les dossiers Flatpak sont ajoutés ensuite par leur propre générateur.
write_session_env() {
    local profile="${BIN%/bin}"
    mkdir -p "$(dirname "$SESSION_ENV")"
    cat >"$SESSION_ENV" <<EOF
# $MARKER : applis du profil Nix visibles par la session
PATH=$profile/bin:\${PATH}
XDG_DATA_DIRS=$profile/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
EOF
    ok "Session environment written: $SESSION_ENV (applies at next login)"
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
    # Reprend les applications par défaut de GNOME sous niri
    if [[ -f /usr/share/applications/gnome-mimeapps.list && ! -e "$MIME_LINK" ]]; then
        ln -s /usr/share/applications/gnome-mimeapps.list "$MIME_LINK"
    fi
    ok "Portals (screen sharing, file chooser) and default applications configured."
}

# --- Configurations utilisateur ------------------------------------------------------
# Écrit un fichier seulement s'il est absent, ou avec --force-config après sauvegarde
should_write() {
    local f="$1"
    if [[ -e "$f" ]]; then
        if ((FORCE_CONFIG)); then
            cp -a "$f" "$f.bak-$STAMP"
            info "Backup: $f.bak-$STAMP"
            return 0
        fi
        info "Kept (already present): $f"
        return 1
    fi
    mkdir -p "$(dirname "$f")"
    return 0
}

# Langue de l'interface : français si la locale l'est, anglais sinon
is_french_locale() {
    [[ "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" == fr* ]]
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
    # Même dossier et nom de fichier que les captures GNOME
    if is_french_locale; then
        shots="$pictures/Captures d’écran/Capture d’écran du %Y-%m-%d %H-%M-%S.png"
    else
        shots="$pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    fi

    cat >"$NIRI_CFG" <<EOF
// Généré par niri-noctalia-nix.sh le $STAMP
// Référence : https://niri-wm.github.io/niri/Configuration:-Introduction

input {
    keyboard {
        xkb {
            // Vide : niri reprend la disposition système (localectl), comme GNOME
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

// Fond d'écran flouté dans la vue d'ensemble, façon Activités
layer-rule {
    match namespace="^noctalia-backdrop"
    place-within-backdrop true
}

debug {
    honor-xdg-activation-with-invalid-serial
}

binds {
    Mod+Shift+Slash { show-hotkey-overlay; }

    // Raccourcis inspirés de GNOME
    Mod+A hotkey-overlay-title="Applications" { spawn "$BIN/noctalia" "msg" "panel-toggle" "launcher"; }
    Mod+S hotkey-overlay-title="Quick settings" { spawn "$BIN/noctalia" "msg" "panel-toggle" "control-center"; }
    Mod+Comma hotkey-overlay-title="Noctalia settings" { spawn "$BIN/noctalia" "msg" "settings-toggle"; }
    Mod+T hotkey-overlay-title="Terminal" { spawn "$TERMINAL_CMD"; }
    Ctrl+Alt+T { spawn "$TERMINAL_CMD"; }
    Mod+E hotkey-overlay-title="Files" { spawn "nautilus" "--new-window"; }
    Mod+L hotkey-overlay-title="Lock" { spawn "$LOCK_SCRIPT"; }
    Mod+O repeat=false { toggle-overview; }
    Mod+Q repeat=false { close-window; }
    Alt+F4 repeat=false { close-window; }

    XF86AudioRaiseVolume allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-up"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-down"; }
    XF86AudioMute allow-when-locked=true { spawn "$BIN/noctalia" "msg" "volume-mute"; }
    XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
    XF86MonBrightnessUp allow-when-locked=true { spawn "$BIN/noctalia" "msg" "brightness-up"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "$BIN/noctalia" "msg" "brightness-down"; }

    // Navigation (flèches uniquement, Mod+L étant réservé au verrouillage)
    // Haut/Bas façon GNOME : écran complet (barre et dock visibles) / réduction
    // d'un cran ; les espaces de travail restent sur Mod+Page Haut/Bas
    Mod+Left  { focus-column-left; }
    Mod+Right { focus-column-right; }
    Mod+Up    { set-column-width "100%"; }
    Mod+Down  { spawn "$COLUMN_DOWN"; }
    Mod+Ctrl+Left  { move-column-left; }
    Mod+Ctrl+Right { move-column-right; }
    Mod+Ctrl+Up    { move-window-up; }
    Mod+Ctrl+Down  { move-window-down; }
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

// Écrans propres à la machine (positions, échelles), hors de ce fichier.
// Facultatif : niri l'ignore s'il n'existe pas (niri >= 26.04).
include optional=true "outputs.kdl"
EOF
    ok "niri config written: $NIRI_CFG"
}

# Config niri conservée d'une version précédente : bascule Mod+L vers hyprlock
# Config niri conservée : remplace les raccourcis Haut/Bas d'espaces de travail
# d'une version précédente par le comportement GNOME. Seules les lignes encore
# identiques à celles générées sont touchées.
migrate_niri_updown_binds() {
    grep -Eq '^[[:space:]]*Mod\+(Ctrl\+)?(Up|Down)[[:space:]]+\{ (focus-window-or-workspace|move-window-(up|down)-or-to-workspace)' "$NIRI_CFG" || return 0
    [[ -e "$NIRI_CFG.bak-$STAMP" ]] || cp -a "$NIRI_CFG" "$NIRI_CFG.bak-$STAMP"
    local tmp
    tmp="$(mktemp)"
    sed -E \
        -e "s|^([[:space:]]*)Mod\+Up([[:space:]]+)\{ focus-window-or-workspace-up; \}|\1Mod+Up\2{ set-column-width \"100%\"; }|" \
        -e "s|^([[:space:]]*)Mod\+Down([[:space:]]+)\{ focus-window-or-workspace-down; \}|\1Mod+Down\2{ spawn \"$COLUMN_DOWN\"; }|" \
        -e "s|^([[:space:]]*)Mod\+Ctrl\+Up([[:space:]]+)\{ move-window-up-or-to-workspace-up; \}|\1Mod+Ctrl+Up\2{ move-window-up; }|" \
        -e "s|^([[:space:]]*)Mod\+Ctrl\+Down([[:space:]]+)\{ move-window-down-or-to-workspace-down; \}|\1Mod+Ctrl+Down\2{ move-window-down; }|" \
        "$NIRI_CFG" >"$tmp"
    cat "$tmp" >"$NIRI_CFG"
    rm -f "$tmp"
    if ! "$BIN/niri" validate -c "$NIRI_CFG" >/dev/null 2>&1; then
        cp -a "$NIRI_CFG.bak-$STAMP" "$NIRI_CFG"
        warn "Could not switch Mod+Up/Down to GNOME-style resizing: niri config restored."
        return 0
    fi
    ok "Mod+Up/Down now resize like GNOME (backup: $NIRI_CFG.bak-$STAMP)."
}

migrate_niri_lock_bind() {
    grep -Eq '^[[:space:]]*Mod\+L[[:space:]].*swaylock' "$NIRI_CFG" || return 0
    local new_line="    Mod+L hotkey-overlay-title=\"Lock\" { spawn \"$LOCK_SCRIPT\"; }"
    cp -a "$NIRI_CFG" "$NIRI_CFG.bak-$STAMP"
    sed -Ei "s|^[[:space:]]*Mod\+L[[:space:]].*swaylock.*$|${new_line}|" "$NIRI_CFG"
    if ! "$BIN/niri" validate -c "$NIRI_CFG" >/dev/null 2>&1; then
        cp -a "$NIRI_CFG.bak-$STAMP" "$NIRI_CFG"
        warn "Could not switch Mod+L to hyprlock: niri config restored."
        return 0
    fi
    ok "Mod+L switched from swaylock to $LOCK_SCRIPT (backup: $NIRI_CFG.bak-$STAMP)."
}

write_noctalia_config() {
    should_write "$NOCTALIA_CFG" || return 0
    cat >"$NOCTALIA_CFG" <<'EOF'
# Généré par niri-noctalia-nix.sh : base "façon GNOME"
# Référence complète : https://docs.noctalia.dev/noctalia/configuration/

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
builtin_ids = []                  # aucun thème écrit dans les configs GTK/Qt
enable_community_templates = false
community_ids = []

[backdrop]
enabled = true

[lockscreen]
enabled = false                   # verrouillage assuré par hyprlock (PAM Debian)
lock_before_suspend = false       # sinon le verrou Noctalia (PAM Nix) bloque au réveil

[osd]
position = "bottom_center"

[dock]
enabled = true
position = "bottom"
show_running = true           # ajoute aussi les applis ouvertes non épinglées
launcher_position = "end"     # bouton grille d'applications à droite, comme le dash GNOME
launcher_icon = "grid-dots"
icon_size = 44
show_dots = true              # point sous les applis ouvertes
magnification = false         # pas d'effet loupe façon macOS
auto_hide = false
reserve_space = true          # les fenêtres ne passent pas sous le dock
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
    ok "Noctalia config written: $NOCTALIA_CFG"
}

# Force une clé dans une section TOML (crée la section ou la clé si besoin).
# Ne réécrit le fichier (avec sauvegarde) que s'il change.
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
# Debian : on le coupe aussi dans les réglages GUI, qui priment sur config.toml
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
    ok "Noctalia lock screen disabled (hyprlock handles locking)."
}

# Contournement temporaire, en attendant le correctif upstream de hyprlock
# (https://github.com/hyprwm/hyprlock/issues/1071) : $TIME peut rester figé
# sur l'heure du verrouillage après une extinction des écrans ou une mise en
# veille. L'heure et la date sont donc recalculées par une commande fréquente.
# À retirer (retour à $TIME) une fois le correctif publié dans hyprlock.
readonly HYPRLOCK_TIME_TEXT='cmd[update:1000] date +"%H:%M"'
readonly HYPRLOCK_DATE_TEXT='cmd[update:5000] date +"%A %e %B"'

# Config générée par une version précédente : applique le contournement de
# l'heure figée sur les deux libellés, sans toucher au reste du fichier
migrate_hyprlock_clock() {
    grep -qs -e 'niri-noctalia-nix.sh' -e 'niri-hyprlock-setup.sh' "$HYPRLOCK_CFG" || return 0
    # shellcheck disable=SC2016 # $TIME est un motif littéral
    grep -Eqs '^[[:space:]]*text = (\$TIME|cmd\[update:60000\] date)' "$HYPRLOCK_CFG" || return 0
    cp -a "$HYPRLOCK_CFG" "$HYPRLOCK_CFG.bak-$STAMP"
    sed -Ei \
        -e "s|^([[:space:]]*)text = \\\$TIME[[:space:]]*$|\1text = ${HYPRLOCK_TIME_TEXT}|" \
        -e "s|^([[:space:]]*)text = cmd\[update:60000\] date .*$|\1text = ${HYPRLOCK_DATE_TEXT}|" \
        "$HYPRLOCK_CFG"
    ok "hyprlock clock workaround applied (backup: $HYPRLOCK_CFG.bak-$STAMP)."
}

write_hyprlock_config() {
    # Ancienne config générée (fond flouté de la session) : remplacée d'office,
    # avec sauvegarde. Une config modifiée à la main n'est pas touchée.
    if grep -qs 'path = screenshot' "$HYPRLOCK_CFG" \
        && grep -qs -e 'niri-noctalia-nix.sh' -e 'niri-hyprlock-setup.sh' "$HYPRLOCK_CFG"; then
        cp -a "$HYPRLOCK_CFG" "$HYPRLOCK_CFG.bak-$STAMP"
        info "Backup: $HYPRLOCK_CFG.bak-$STAMP (blurred background replaced)"
    else
        should_write "$HYPRLOCK_CFG" || return 0
    fi
    local placeholder="Password" failed="Wrong password"
    if is_french_locale; then
        placeholder="Mot de passe" failed="Mot de passe incorrect"
    fi
    cat >"$HYPRLOCK_CFG" <<EOF
# Généré par niri-noctalia-nix.sh
general {
    hide_cursor = true
    ignore_empty_input = true
}

# Gris graphite uni : rien de la session n'apparaît derrière le verrou
background {
    monitor =
    color = rgb(36, 38, 41)
}

# Heure et date via date(1) plutôt que \$TIME : contournement temporaire du
# bug hyprlock #1071 (heure figée après extinction des écrans), à retirer
# une fois le correctif publié
label {
    monitor =
    text = $HYPRLOCK_TIME_TEXT
    font_size = 96
    font_family = Adwaita Sans
    color = rgba(235, 235, 235, 1.0)
    position = 0, 160
    halign = center
    valign = center
}

label {
    monitor =
    text = $HYPRLOCK_DATE_TEXT
    font_size = 22
    font_family = Adwaita Sans
    color = rgba(235, 235, 235, 0.7)
    position = 0, 80
    halign = center
    valign = center
}

input-field {
    monitor =
    size = 320, 56
    outline_thickness = 2
    rounding = 14
    inner_color = rgba(255, 255, 255, 0.06)
    outer_color = rgba(255, 255, 255, 0.15)
    check_color = rgba(53, 132, 228, 1.0)
    fail_color = rgba(224, 27, 36, 1.0)
    font_color = rgba(235, 235, 235, 1.0)
    placeholder_text = $placeholder
    fail_text = $failed
    dots_center = true
    fade_on_empty = false
    position = 0, -40
    halign = center
    valign = center
}
EOF
    ok "hyprlock config written: $HYPRLOCK_CFG"
}

validate_configs() {
    "$BIN/niri" validate -c "$NIRI_CFG" \
        || die "Invalid niri config: fix $NIRI_CFG before logging in."
    if ! "$BIN/noctalia" config validate "$NOCTALIA_CFG"; then
        warn "Noctalia reports errors in $NOCTALIA_CFG (non-blocking, unknown keys are ignored)."
    fi
    ok "Configurations validated."
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
    write_column_down_script
    install_user_units
    write_session_env
    install_portal_and_mime
    write_niri_config
    migrate_niri_lock_bind
    migrate_niri_updown_binds
    write_noctalia_config
    neutralize_noctalia_lock
    write_hyprlock_config
    migrate_hyprlock_clock
    validate_configs
    restart_idle_if_running
    cat <<EOF

Installation complete.
  1. Log out of GNOME.
  2. In GDM, pick your user, then the gear at the bottom right: "Niri (Nix)".
  3. Once logged in: Mod+Shift+/ shows the shortcuts, Mod+A opens the app launcher,
     Mod+L locks the session (hyprlock) and powers off the monitors.

Machine-specific monitors: describe them in $(dirname "$NIRI_CFG")/outputs.kdl (optional).

If hyprlock rejects your password: Ctrl+Alt+F3, log in, then
  pkill -x hyprlock
  WAYLAND_DISPLAY=\$(basename "\$(ls /run/user/\$(id -u)/wayland-? | head -1)") swaylock -f

Troubleshooting: journalctl --user -u niri.service -b
Update: $0 --update
Rollback: $0 --uninstall (your configs are kept)
EOF
}

do_update() {
    preflight
    [[ -f "$FLAKE_DIR/flake.nix" ]] || die "Flake missing: run --install first."
    info "Updating the nixpkgs revision."
    nixc flake update --flake "path:$FLAKE_DIR"
    build_gpu_env
    install_profile
    install_hyprlock
    write_lock_script
    write_column_down_script
    install_user_units
    write_session_env
    migrate_niri_lock_bind
    migrate_niri_updown_binds
    neutralize_noctalia_lock
    write_hyprlock_config
    migrate_hyprlock_clock
    validate_configs
    restart_idle_if_running
    ok "Update complete: log out and back into the niri session to apply it."
}

do_uninstall() {
    [[ "${XDG_CURRENT_DESKTOP:-}" != *niri* ]] \
        || die "Run the uninstall from the GNOME session, not from niri."
    sudo -v

    if profile_has_element; then
        nixc profile remove "$PROFILE_ELEMENT"
        ok "Packages removed from the Nix profile."
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

    if grep -qs -e 'niri-noctalia-nix.sh' -e 'niri-hyprlock-setup.sh' "$LOCK_SCRIPT"; then
        rm -f "$LOCK_SCRIPT"
    fi
    if grep -qs 'niri-noctalia-nix.sh' "$COLUMN_DOWN"; then
        rm -f "$COLUMN_DOWN"
    fi

    rm -f "$PORTAL_CFG"
    if grep -qs 'niri-noctalia-nix.sh' "$SESSION_ENV"; then
        rm -f "$SESSION_ENV"
    fi
    if [[ -L "$MIME_LINK" ]]; then
        rm -f "$MIME_LINK"
    fi

    sudo rm -f "$SESSION_DESKTOP" "$SESSION_WRAPPER" "$TMPFILES_CONF"
    if [[ -L /run/opengl-driver && "$(readlink /run/opengl-driver)" == "$GPU_LINK" ]]; then
        sudo rm -f /run/opengl-driver
    fi
    rm -f "$GPU_LINK"

    cat <<EOF

Uninstall complete. Intentionally kept:
  - configs: $NIRI_CFG, $NOCTALIA_CFG, $HYPRLOCK_CFG
  - flake: $FLAKE_DIR
  - apt packages: ${APT_PACKAGES[*]} hyprlock
To free Nix store space: nix-collect-garbage
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