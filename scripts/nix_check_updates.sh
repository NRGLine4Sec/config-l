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

# Extraire : "NOM|STORE_BASENAME"
mapfile -t PKG_LINES < <(echo "$PROFILE_JSON" | jq -r '
  .elements | to_entries[] |
  .key + "|" + (.value.storePaths[0] // "" | split("/")[-1])
')

if [[ ${#PKG_LINES[@]} -eq 0 ]]; then
  echo -e "${RED}Aucun paquet trouvé dans nix profile.${RESET}"
  exit 1
fi

TOTAL=${#PKG_LINES[@]}

echo -e "${DIM}$TOTAL paquets trouvés. Interrogation de nixpkgs upstream (${JOBS} en parallèle)...${RESET}\n"

# ─── Fichiers temporaires pour les résultats parallèles ──────────────────────
TMPDIR_RESULTS=$(mktemp -d)
trap 'rm -rf "$TMPDIR_RESULTS"' EXIT

# Compteur partagé de progression (via fichier)
PROGRESS_FILE="$TMPDIR_RESULTS/progress"
echo "0" > "$PROGRESS_FILE"
PROGRESS_LOCK="$TMPDIR_RESULTS/progress.lock"

# ─── Fonction de vérification d'un paquet ────────────────────────────────────
check_pkg() {
  local line="$1"
  local pkg_name="${line%%|*}"
  local store_basename="${line##*|}"

  # Suffixes de store path à ignorer (peuvent s'enchaîner, ex: -dev-man)
  local -a KNOWN_SUFFIXES=(-dev -man -doc -lib -bin -out -info -static -debug -locale)

  # Supprimer le hash initial (premier segment avant le premier tiret)
  local without_hash="${store_basename#*-}"

  # Étape 1 : strip les suffixes connus en fin du basename complet
  # (gère -dev, -man, -doc, etc. éventuellement enchaînés)
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

  # Étape 2 : trouver le premier segment commençant par un chiffre et reconstruire
  # depuis là jusqu'à la fin. On normalise le nom du paquet (strip _ en préfixe)
  # pour gérer les cas comme _7zz dont le store path commence par "7zz-26.00" :
  # le segment "7zz" commence par un chiffre mais c'est le nom, pas la version.
  local pkg_normalized="${pkg_name#_}"  # _7zz → 7zz
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
      # Ignorer si c'est le premier segment ET qu'il correspond au nom du paquet normalisé
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

  # Interroger la version upstream
  local upstream_version
  upstream_version=$(nix eval --raw "nixpkgs#${pkg_name}.version" 2>/dev/null || echo "")

  # Incrémenter le compteur de progression (avec lock)
  (
    flock 9
    local count
    count=$(cat "$PROGRESS_FILE")
    echo $((count + 1)) > "$PROGRESS_FILE"
  ) 9>"$PROGRESS_LOCK"

  # Écrire le résultat dans un fichier dédié
  if [[ -z "$upstream_version" ]]; then
    echo "SKIP|$pkg_name" > "$TMPDIR_RESULTS/$pkg_name"
  elif [[ "$installed_version" == "$upstream_version" ]]; then
    echo "OK|$pkg_name|$installed_version" > "$TMPDIR_RESULTS/$pkg_name"
  else
    echo "UPDATE|$pkg_name|$installed_version|$upstream_version" > "$TMPDIR_RESULTS/$pkg_name"
  fi
}

export -f check_pkg
export TMPDIR_RESULTS PROGRESS_FILE PROGRESS_LOCK

# ─── Lancement parallèle avec affichage de progression ───────────────────────

# Lancer tous les jobs en parallèle avec un pool de $JOBS workers
declare -a PIDS=()
SLOT=0

for line in "${PKG_LINES[@]}"; do
  # Attendre qu'un slot se libère si on a atteint la limite
  while [[ ${#PIDS[@]} -ge $JOBS ]]; do
    for i in "${!PIDS[@]}"; do
      if ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
        unset 'PIDS[$i]'
      fi
    done
    PIDS=("${PIDS[@]}")  # re-indexer
    sleep 0.05
  done

  check_pkg "$line" &
  PIDS+=($!)

  # Afficher la progression
  DONE=$(cat "$PROGRESS_FILE")
  printf "\r${DIM}[%d/%d] en cours...${RESET}" "$DONE" "$TOTAL"
done

# Attendre la fin de tous les jobs restants avec mise à jour de la progression
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

# ─── Collecte et tri des résultats ───────────────────────────────────────────
declare -a UPDATES_AVAILABLE=()
declare -a UP_TO_DATE=()
declare -a SKIPPED=()

# Lire les résultats dans l'ordre alphabétique (ordre des fichiers)
while IFS= read -r result_file; do
  content=$(cat "$result_file")
  IFS='|' read -ra parts <<< "$content"
  case "${parts[0]}" in
    UPDATE) UPDATES_AVAILABLE+=("${parts[1]}|${parts[2]}|${parts[3]}") ;;
    OK)     UP_TO_DATE+=("${parts[1]}|${parts[2]}") ;;
    SKIP)   SKIPPED+=("${parts[1]}") ;;
  esac
done < <(find "$TMPDIR_RESULTS" -maxdepth 1 -type f ! -name 'progress*' | sort)

# ─── Affichage des résultats ──────────────────────────────────────────────────

if [[ ${#UPDATES_AVAILABLE[@]} -gt 0 ]]; then
  echo -e "${BOLD}${YELLOW}⬆  Mises à jour disponibles (${#UPDATES_AVAILABLE[@]})${RESET}"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  printf "${BOLD}  %-28s %-18s %-18s${RESET}\n" "Paquet" "Installé" "Disponible"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  for entry in "${UPDATES_AVAILABLE[@]}"; do
    IFS='|' read -r name installed upstream <<< "$entry"
    printf "  ${CYAN}%-28s${RESET} ${RED}%-18s${RESET} ${GREEN}%s${RESET}\n" "$name" "$installed" "$upstream"
  done
  echo ""
fi

if ! $ONLY_UPDATES && [[ ${#UP_TO_DATE[@]} -gt 0 ]]; then
  echo -e "${BOLD}${GREEN}✓  À jour (${#UP_TO_DATE[@]})${RESET}"
  if $VERBOSE; then
    echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
    for entry in "${UP_TO_DATE[@]}"; do
      IFS='|' read -r name version <<< "$entry"
      printf "  ${GREEN}✓${RESET}  %-28s ${DIM}%s${RESET}\n" "$name" "$version"
    done
    echo ""
  fi
fi

if $VERBOSE && [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo -e "${BOLD}${DIM}?  Non évaluables via nixpkgs#NOM.version (${#SKIPPED[@]})${RESET}"
  echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
  for name in "${SKIPPED[@]}"; do
    printf "  ${DIM}?  %s${RESET}\n" "$name"
  done
  echo ""
fi

# ─── Résumé ──────────────────────────────────────────────────────────────────
echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}Résumé :${RESET}  ${YELLOW}${#UPDATES_AVAILABLE[@]} MAJ dispo${RESET}  •  ${GREEN}${#UP_TO_DATE[@]} à jour${RESET}  •  ${DIM}${#SKIPPED[@]} ignorés${RESET}  •  Total : $TOTAL\n"

if [[ ${#UPDATES_AVAILABLE[@]} -gt 0 ]]; then
  echo -e "${DIM}Pour tout mettre à jour :${RESET}  ${BOLD}nix profile upgrade --all${RESET}\n"
fi