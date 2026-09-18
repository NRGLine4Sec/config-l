#!/usr/bin/env bash
# __my_script__

# nix-check-updates.sh — Vérifie les mises à jour disponibles pour les paquets nix profile

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── Parsing des arguments ────────────────────────────────────────────────────
VERBOSE=false
ONLY_UPDATES=false
JOBS=5

for arg in "$@"; do
  case $arg in
    -v|--verbose)      VERBOSE=true ;;
    -u|--updates-only) ONLY_UPDATES=true ;;
    -j=*|--jobs=*)     JOBS="${arg#*=}" ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -v, --verbose          Affiche aussi les paquets à jour et les ignorés"
      echo "  -u, --updates-only     N'affiche que les paquets avec une MAJ dispo"
      echo "  -j=N, --jobs=N         Nombre de vérifications en parallèle (défaut: 5)"
      echo "  -h, --help             Affiche cette aide"
      exit 0
      ;;
  esac
done

# ─── Vérification des dépendances ────────────────────────────────────────────
for cmd in nix jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${RED}Erreur : '$cmd' est requis mais introuvable.${RESET}" >&2
    exit 1
  fi
done

# ─── Récupération de la liste des paquets installés ──────────────────────────
echo -e "\n${BOLD}${BLUE}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║       Nix Profile — Vérification des MAJ     ║${RESET}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════╝${RESET}\n"

echo -e "${DIM}Récupération de la liste des paquets installés...${RESET}"

PROFILE_JSON=$(nix profile list --json 2>/dev/null)

# Extraire : "NOM|STORE_BASENAME|ORIGINAL_URL|LOCKED_URL"
mapfile -t PKG_LINES < <(echo "$PROFILE_JSON" | jq -r '
  .elements | to_entries[] |
  .key + "|"
  + (.value.storePaths[0] // "" | split("/")[-1]) + "|"
  + (.value.originalUrl // "") + "|"
  + (.value.url // "")
')

if [[ ${#PKG_LINES[@]} -eq 0 ]]; then
  echo -e "${RED}Aucun paquet trouvé dans nix profile.${RESET}"
  exit 1
fi

TOTAL=${#PKG_LINES[@]}

echo -e "${DIM}$TOTAL paquets trouvés. Interrogation upstream (${JOBS} en parallèle)...${RESET}\n"

# ─── Fichiers temporaires pour les résultats parallèles ──────────────────────
TMPDIR_RESULTS=$(mktemp -d)
trap 'rm -rf "$TMPDIR_RESULTS"' EXIT

PROGRESS_FILE="$TMPDIR_RESULTS/progress"
echo "0" > "$PROGRESS_FILE"
PROGRESS_LOCK="$TMPDIR_RESULTS/progress.lock"

# ─── Fonction de vérification d'un paquet ────────────────────────────────────
check_pkg() {
  local line="$1"
  local pkg_name store_basename original_url locked_url
  IFS='|' read -r pkg_name store_basename original_url locked_url <<< "$line"

  # Incrémenter le compteur de progression
  (
    flock 9
    local count
    count=$(cat "$PROGRESS_FILE")
    echo $((count + 1)) > "$PROGRESS_FILE"
  ) 9>"$PROGRESS_LOCK"

  # ── Flake externe (non nixpkgs) ──────────────────────────────────────────
  if [[ "$original_url" != "flake:nixpkgs" && -n "$original_url" ]]; then
    local rev_installed rev_upstream date_upstream result_file
    result_file="$TMPDIR_RESULTS/ext_${pkg_name}"

    rev_installed=$(echo "$locked_url" | grep -oP '[0-9a-f]{40}' | head -1 || echo "")

    local metadata_json
    metadata_json=$(nix flake metadata "$original_url" --json 2>/dev/null || echo "")

    if [[ -z "$metadata_json" ]]; then
      echo "SKIP_EXT|$pkg_name|$original_url" > "$result_file"
      return
    fi

    rev_upstream=$(echo "$metadata_json" | jq -r '.locked.rev // ""')
    local ts_upstream
    ts_upstream=$(echo "$metadata_json" | jq -r '.locked.lastModified // ""')
    date_upstream=""
    [[ -n "$ts_upstream" ]] && date_upstream=$(date -d "@${ts_upstream}" +%Y-%m-%d 2>/dev/null || echo "$ts_upstream")

    if [[ -z "$rev_upstream" ]]; then
      echo "SKIP_EXT|$pkg_name|$original_url" > "$result_file"
    elif [[ "$rev_installed" == "$rev_upstream" ]]; then
      echo "OK_EXT|$pkg_name|${date_upstream}|$original_url" > "$result_file"
    else
      # Récupérer la date du commit installé si possible
      local date_installed="${rev_installed:0:8}"  # rev court comme fallback
      echo "UPDATE_EXT|$pkg_name|${date_installed}|${date_upstream}|$original_url" > "$result_file"
    fi
    return
  fi

  # ── Paquet nixpkgs ───────────────────────────────────────────────────────
  local -a KNOWN_SUFFIXES=(-dev -man -doc -lib -bin -out -info -static -debug -locale)

  local without_hash="${store_basename#*-}"

  local stripped="$without_hash"
  local changed=true
  while $changed; do
    changed=false
    for suf in "${KNOWN_SUFFIXES[@]}"; do
      if [[ "$stripped" == *"$suf" ]]; then
        stripped="${stripped%${suf}}"
        changed=true
      fi
    done
  done

  local pkg_normalized="${pkg_name#_}"
  local installed_version="?"
  local IFS_BAK="$IFS"
  IFS='-' read -ra PARTS <<< "$stripped"
  IFS="$IFS_BAK"
  local found=false
  local version_parts=()
  local first_segment=true
  for part in "${PARTS[@]}"; do
    if $found; then
      version_parts+=("$part")
    elif [[ "$part" =~ ^[0-9] ]]; then
      if $first_segment && [[ "$part" == "$pkg_normalized" ]]; then
        first_segment=false
        continue
      fi
      found=true
      version_parts+=("$part")
    fi
    first_segment=false
  done
  if $found; then
    installed_version=$(IFS='-'; echo "${version_parts[*]}")
  fi

  local upstream_version
  upstream_version=$(nix eval --raw "nixpkgs#${pkg_name}.version" 2>/dev/null || echo "")

  local result_file="$TMPDIR_RESULTS/$pkg_name"
  if [[ -z "$upstream_version" ]]; then
    echo "SKIP|$pkg_name" > "$result_file"
  elif [[ "$installed_version" == "$upstream_version" ]]; then
    echo "OK|$pkg_name|$installed_version" > "$result_file"
  else
    echo "UPDATE|$pkg_name|$installed_version|$upstream_version" > "$result_file"
  fi
}

export -f check_pkg
export TMPDIR_RESULTS PROGRESS_FILE PROGRESS_LOCK

# ─── Lancement parallèle ─────────────────────────────────────────────────────
declare -a PIDS=()

for line in "${PKG_LINES[@]}"; do
  while [[ ${#PIDS[@]} -ge $JOBS ]]; do
    for i in "${!PIDS[@]}"; do
      if ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
        unset 'PIDS[$i]'
      fi
    done
    PIDS=("${PIDS[@]}")
    sleep 0.05
  done

  check_pkg "$line" &
  PIDS+=($!)

  DONE=$(cat "$PROGRESS_FILE")
  printf "\r${DIM}[%d/%d] en cours...${RESET}" "$DONE" "$TOTAL"
done

while [[ ${#PIDS[@]} -gt 0 ]]; do
  for i in "${!PIDS[@]}"; do
    if ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
      unset 'PIDS[$i]'
    fi
  done
  PIDS=("${PIDS[@]}")
  DONE=$(cat "$PROGRESS_FILE")
  printf "\r${DIM}[%d/%d] en cours...${RESET}" "$DONE" "$TOTAL"
  sleep 0.1
done

printf "\r%-60s\r" " "

# ─── Collecte des résultats ───────────────────────────────────────────────────
declare -a UPDATES_AVAILABLE=()
declare -a UPDATES_EXT=()
declare -a UP_TO_DATE=()
declare -a UP_TO_DATE_EXT=()
declare -a SKIPPED=()

while IFS= read -r result_file; do
  content=$(cat "$result_file")
  IFS='|' read -ra parts <<< "$content"
  case "${parts[0]}" in
    UPDATE)     UPDATES_AVAILABLE+=("${parts[1]}|${parts[2]}|${parts[3]}") ;;
    UPDATE_EXT) UPDATES_EXT+=("${parts[1]}|${parts[2]}|${parts[3]}|${parts[4]}") ;;
    OK)         UP_TO_DATE+=("${parts[1]}|${parts[2]}") ;;
    OK_EXT)     UP_TO_DATE_EXT+=("${parts[1]}|${parts[2]}|${parts[3]}") ;;
    SKIP|SKIP_EXT) SKIPPED+=("${parts[1]}") ;;
  esac
done < <(find "$TMPDIR_RESULTS" -maxdepth 1 -type f ! -name 'progress*' | sort)

# ─── Affichage des résultats ──────────────────────────────────────────────────

if [[ ${#UPDATES_AVAILABLE[@]} -gt 0 ]]; then
  echo -e "${BOLD}${YELLOW}⬆  Mises à jour disponibles — nixpkgs (${#UPDATES_AVAILABLE[@]})${RESET}"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  printf "${BOLD}  %-28s %-18s %-18s${RESET}\n" "Paquet" "Installé" "Disponible"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  for entry in "${UPDATES_AVAILABLE[@]}"; do
    IFS='|' read -r name installed upstream <<< "$entry"
    printf "  ${CYAN}%-28s${RESET} ${RED}%-18s${RESET} ${GREEN}%s${RESET}\n" "$name" "$installed" "$upstream"
  done
  echo ""
fi

if [[ ${#UPDATES_EXT[@]} -gt 0 ]]; then
  echo -e "${BOLD}${YELLOW}⬆  Mises à jour disponibles — flakes externes (${#UPDATES_EXT[@]})${RESET}"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  printf "${BOLD}  %-28s %-12s %-12s %-s${RESET}\n" "Paquet" "Installé" "Disponible" "Source"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  for entry in "${UPDATES_EXT[@]}"; do
    IFS='|' read -r name date_inst date_up source <<< "$entry"
    printf "  ${CYAN}%-28s${RESET} ${RED}%-12s${RESET} ${GREEN}%-12s${RESET} ${DIM}%s${RESET}\n" "$name" "$date_inst" "$date_up" "$source"
  done
  echo ""
fi

if ! $ONLY_UPDATES; then
  if [[ ${#UP_TO_DATE[@]} -gt 0 ]]; then
    echo -e "${BOLD}${GREEN}✓  À jour — nixpkgs (${#UP_TO_DATE[@]})${RESET}"
    if $VERBOSE; then
      echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
      for entry in "${UP_TO_DATE[@]}"; do
        IFS='|' read -r name version <<< "$entry"
        printf "  ${GREEN}✓${RESET}  %-28s ${DIM}%s${RESET}\n" "$name" "$version"
      done
      echo ""
    fi
  fi

  if [[ ${#UP_TO_DATE_EXT[@]} -gt 0 ]]; then
    echo -e "${BOLD}${GREEN}✓  À jour — flakes externes (${#UP_TO_DATE_EXT[@]})${RESET}"
    if $VERBOSE; then
      echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
      for entry in "${UP_TO_DATE_EXT[@]}"; do
        IFS='|' read -r name date source <<< "$entry"
        printf "  ${GREEN}✓${RESET}  %-28s ${DIM}%s  %s${RESET}\n" "$name" "$date" "$source"
      done
      echo ""
    fi
  fi
fi

if $VERBOSE && [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo -e "${BOLD}${DIM}?  Non évaluables (${#SKIPPED[@]})${RESET}"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  for name in "${SKIPPED[@]}"; do
    printf "  ${DIM}?  %s${RESET}\n" "$name"
  done
  echo ""
fi

# ─── Résumé ──────────────────────────────────────────────────────────────────
TOTAL_UPDATES=$(( ${#UPDATES_AVAILABLE[@]} + ${#UPDATES_EXT[@]} ))
TOTAL_OK=$(( ${#UP_TO_DATE[@]} + ${#UP_TO_DATE_EXT[@]} ))
echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}Résumé :${RESET}  ${YELLOW}${TOTAL_UPDATES} MAJ dispo${RESET}  •  ${GREEN}${TOTAL_OK} à jour${RESET}  •  ${DIM}${#SKIPPED[@]} ignorés${RESET}  •  Total : $TOTAL\n"

if [[ $TOTAL_UPDATES -gt 0 ]]; then
  echo -e "${DIM}Pour tout mettre à jour :${RESET}  ${BOLD}nix profile upgrade --all${RESET}\n"
fi