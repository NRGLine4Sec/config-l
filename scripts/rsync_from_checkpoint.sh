#!/usr/bin/env bash
# __my_script__

# Synchronise uniquement les fichiers et répertoires plus récents qu’un fichier de référence

# =======================
# CONFIGURATION PAR DÉFAUT
# =======================
DRYRUN=0
DEBUG=1
CONFIG_FILE=""
# =======================

# =======================
# PARSING DES ARGUMENTS
# =======================
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRYRUN=1
            shift
            ;;
        --no-debug)
            DEBUG=0
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

# =======================
# DEBUG
# =======================
[ "$DEBUG" -eq 1 ] && set -x

# =======================
# CHARGEMENT CONFIG INI
# =======================
FIND_EXCLUSIONS=()

if [ -n "$CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Erreur: fichier de config introuvable"
        exit 1
    fi

    current_section=""

    while IFS= read -r line; do
        # Supprime les espaces en début et fin de ligne (trim).
        # La première ligne enlève les caractères blancs en tête via expansion de paramètres (%% + pattern négatif).
        # La seconde enlève les espaces en fin de ligne avec le même principe (## depuis la droite).
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # skip commentaires / lignes vides
        [[ -z "$line" || "$line" =~ ^[;\#] ]] && continue

        # Détecte une ligne de section INI de la forme [section] via une regex Bash.
        # Si le match réussit, le nom de la section (sans les crochets) est capturé dans BASH_REMATCH[1].
        # Permet de basculer le contexte de parsing selon la section courante.
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi

        case "$current_section" in
            main)
                # Vérifie si la ligne correspond à un couple clé=valeur via une regex Bash.
                # Si le match réussit, la partie avant '=' est capturée dans BASH_REMATCH[1] (clé),
                # et tout ce qui suit dans BASH_REMATCH[2] (valeur), sans perdre les caractères spéciaux.
                if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
                    key="${BASH_REMATCH[1]}"
                    value="${BASH_REMATCH[2]}"

                    case "$key" in
                        src) SRC="$value" ;;
                        dst) DST="$value" ;;
                    esac
                fi
                ;;
            exclusions)
                FIND_EXCLUSIONS+=("$line")
                ;;
        esac

    done < "$CONFIG_FILE"
fi

# =======================
# NORMALISATION EXCLUSIONS
# =======================
NORMALIZED_EXCLUSIONS=()

for path in "${FIND_EXCLUSIONS[@]}"; do
    # supprimer trailing slash
    path="${path%/}"

    # convertir en chemin absolu propre
    if command -v realpath >/dev/null 2>&1; then
        path="$(realpath -m "$path")"
    fi

    NORMALIZED_EXCLUSIONS+=("$path")
done

FIND_EXCLUSIONS=("${NORMALIZED_EXCLUSIONS[@]}")

# =======================
# ARGUMENTS
# =======================
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [--dry-run] [--no-debug] [--config file] [<source_dir> <dest_dir>] <reference_file>"
    exit 1
fi

# Cas avec override SRC/DST
if [ "$#" -eq 3 ]; then
    SRC="$1"
    DST="$2"
    REF_FILE="$3"
elif [ "$#" -eq 1 ]; then
    REF_FILE="$1"
else
    echo "Erreur: arguments invalides"
    exit 1
fi

# Vérification variables obligatoires
if [ -z "$SRC" ] || [ -z "$DST" ]; then
    echo "Erreur: SRC et DST doivent être définis (config ou arguments)"
    exit 1
fi

# =======================
# VALIDATIONS
# =======================
if [ ! -d "$SRC" ]; then
    echo "Erreur: le répertoire source '$SRC' n'existe pas."
    exit 1
fi
if [ ! -d "$DST" ]; then
    echo "Erreur: le répertoire destination '$DST' n'existe pas."
    exit 1
fi
if [ ! -f "$SRC/$REF_FILE" ]; then
    echo "Erreur: le fichier de référence '$REF_FILE' n'existe pas."
    exit 1
fi

# =======================
# FICHIER TEMP DE RÉF
# =======================
TMP_REF="$(mktemp --tmpdir rsync_ref.XXXXXX)"
touch -r "$SRC/$REF_FILE" -d '-1 second' "$TMP_REF"

# =======================
# EXCLUSIONS (configurable)
# =======================
EXCLUSION_ARGS=()
for path in "${FIND_EXCLUSIONS[@]}"; do
    EXCLUSION_ARGS+=( -path "$path" -prune -o )
    EXCLUSION_ARGS+=( -path "$path/*" -prune -o )
done

# =======================
# FILELIST
# =======================
FILELIST="$(mktemp --tmpdir rsync_list.XXXXXX)"
find "$SRC" "${EXCLUSION_ARGS[@]}" -type f -newer "$TMP_REF" -printf '%P\n' > "$FILELIST"

if [ ! -s "$FILELIST" ]; then
    echo "Aucun fichier plus récent que '$REF_FILE' trouvé dans '$SRC'."
    rm -f "$TMP_REF" "$FILELIST"
    exit 0
fi

# =======================
# RSYNC
# =======================
RSYNC_OPTS=(
--recursive
--archive
--no-owner
--no-group
--mkpath
--verbose
--stats
--human-readable
--no-compress
--progress
--delete
)

[ "$DRYRUN" -eq 1 ] && RSYNC_OPTS+=(--dry-run)

echo "Synchronisation des fichiers plus récents que '$REF_FILE'..."
rsync "${RSYNC_OPTS[@]}" --files-from="$FILELIST" "$SRC" "$DST"/

# =======================
# CLEANUP
# =======================
rm -f "$TMP_REF" "$FILELIST"

echo "Terminé."