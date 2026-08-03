#!/usr/bin/env bash
# __my_script__

# audit_extensions.sh - detects files whose extension does not match
#                       their real MIME type (via libmagic / file).
#
# Design principle: only propose a rename when detection is unambiguous.
# Generic container formats (ZIP, XML, octet-stream) are reported for
# manual review instead of being blindly renamed, because a single
# container MIME can back dozens of unrelated real-world formats.
#
# Usage: ./audit_extensions.sh [--set-mime-type-text] <directory> [report.txt] [fix.sh]

set -euo pipefail

# --- Argument parsing -------------------------------------------------------
PROCESS_TEXT=0
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --set-mime-type-text)
            PROCESS_TEXT=1
            shift
            ;;
        -h|--help)
            cat <<'EOF'
Usage : audit_extensions.sh [--set-mime-type-text] <repertoire> [rapport.txt] [fix.sh]

  --set-mime-type-text   Analyse egalement les fichiers texte (desactive par defaut).
  -h, --help             Affiche cette aide.
EOF
            exit 0
            ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do POSITIONAL+=("$1"); shift; done
            ;;
        -*)
            echo "Erreur : option inconnue '$1'." >&2
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

ROOT="${POSITIONAL[0]:?Usage: $0 [--set-mime-type-text] <repertoire> [rapport.txt] [fix.sh]}"
REPORT="${POSITIONAL[1]:-rapport_extensions.txt}"
FIXSCRIPT="${POSITIONAL[2]:-corriger_extensions.sh}"

if [[ ! -d "$ROOT" ]]; then
    echo "Erreur : '$ROOT' n'est pas un repertoire." >&2
    exit 1
fi

# --- Canonical MIME -> extension table --------------------------------------
declare -A MIME_EXT=(
    # --- Common images ---
    [image/jpeg]=jpg
    [image/png]=png
    [image/gif]=gif
    [image/webp]=webp
    [image/bmp]=bmp
    [image/tiff]=tiff
    [image/svg+xml]=svg
    [image/vnd.microsoft.icon]=ico
    [image/x-icon]=ico
    # --- Modern image formats ---
    [image/heic]=heic
    [image/heif]=heif
    [image/avif]=avif
    [image/jxl]=jxl
    [image/vnd.adobe.photoshop]=psd
    # --- Camera RAW formats ---
    [image/x-canon-cr2]=cr2
    [image/x-canon-cr3]=cr3
    [image/x-canon-crw]=crw
    [image/x-nikon-nef]=nef
    [image/x-nikon-nrw]=nrw
    [image/x-sony-arw]=arw
    [image/x-adobe-dng]=dng
    [image/x-olympus-orf]=orf
    [image/x-fuji-raf]=raf
    [image/x-panasonic-rw2]=rw2
    [image/x-pentax-pef]=pef
    [image/x-samsung-srw]=srw
    [image/x-kodak-dcr]=dcr
    [image/x-minolta-mrw]=mrw
    [image/x-sigma-x3f]=x3f
    # --- Video ---
    [video/mp4]=mp4
    [video/x-matroska]=mkv
    [video/webm]=webm
    [video/quicktime]=mov
    [video/x-msvideo]=avi
    [video/mpeg]=mpg
    [video/x-ms-wmv]=wmv
    [video/x-flv]=flv
    [video/x-m4v]=m4v
    [video/3gpp]=3gp
    [video/3gpp2]=3g2
    [video/mp2t]=ts
    [video/avchd-stream]=mts
    [video/ogg]=ogv
    [video/dvd]=vob
    [video/x-ms-asf]=asf
    [application/vnd.rn-realmedia]=rm
    # --- Audio ---
    [audio/mpeg]=mp3
    [audio/flac]=flac
    [audio/x-flac]=flac
    [audio/x-wav]=wav
    [audio/wav]=wav
    [audio/ogg]=ogg
    [audio/opus]=opus
    [audio/aac]=aac
    [audio/mp4]=m4a
    [audio/x-m4a]=m4a
    [audio/x-ms-wma]=wma
    [audio/aiff]=aiff
    [audio/x-aiff]=aiff
    [audio/midi]=mid
    # --- Archives ---
    [application/zip]=zip
    [application/gzip]=gz
    [application/x-tar]=tar
    [application/x-7z-compressed]=7z
    [application/x-rar]=rar
    [application/vnd.rar]=rar
    [application/x-bzip2]=bz2
    [application/x-xz]=xz
    [application/zstd]=zst
    # --- Documents ---
    [application/pdf]=pdf
    [application/json]=json
    [application/xml]=xml
    [application/msword]=doc
    [application/vnd.openxmlformats-officedocument.wordprocessingml.document]=docx
    [application/vnd.ms-excel]=xls
    [application/vnd.openxmlformats-officedocument.spreadsheetml.sheet]=xlsx
    [application/vnd.ms-powerpoint]=ppt
    [application/vnd.openxmlformats-officedocument.presentationml.presentation]=pptx
    [application/vnd.oasis.opendocument.text]=odt
    [application/vnd.oasis.opendocument.spreadsheet]=ods
    [application/vnd.oasis.opendocument.presentation]=odp
    # --- Executables (empty = ignored, no canonical extension) ---
    [application/x-executable]=""
    [application/x-sharedlib]=""
    [application/x-pie-executable]=""
    [application/x-dosexec]=""
)

# --- Generic container MIME types -------------------------------------------
# These MIME types back many unrelated real formats. libmagic cannot always
# resolve the specialization, so we never auto-rename them: an extension
# listed here is considered plausible and left untouched.
# An empty list means "nothing is ever plausible" (always flagged, never fixed).
declare -A CONTAINER_SUBTYPES=(
    [application/zip]="zip skill docx docm dotx xlsx xlsm xltx pptx pptm potx odt ods odp odg odf otp ott epub jar war ear apk aab ipa xpi crx vsix whl nupkg kra ora sb3 cbz kmz usdz oxps mcworld fcstd 3mf"
    [application/xml]="xml svg xhtml rss atom kml gpx plist xsl xslt xsd wsdl dae fodt musicxml opf ncx"
    [application/octet-stream]=""
)

# --- Accepted aliases -------------------------------------------------------
# Key = canonical extension, value = list of equivalent extensions.
# ISOBMFF-based formats (mp4/m4v/m4a/mov/3gp) share the same container and
# libmagic does not always discriminate them, so they are mutually tolerated.
declare -A ALIASES=(
    [jpg]="jpg jpeg jpe jfif"
    [tiff]="tiff tif"
    [heic]="heic heics"
    [heif]="heif heifs"
    [mp4]="mp4 m4v m4a m4b m4p mov 3gp 3g2"
    [m4a]="m4a m4b m4p mp4 aac"
    [mov]="mov qt mp4 m4v"
    [mpg]="mpg mpeg mpe m2v m1v"
    [3gp]="3gp 3gpp 3g2"
    [ts]="ts m2ts mts tsv"
    [mts]="mts m2ts ts"
    [mid]="mid midi"
    [aiff]="aiff aif aifc"
    [html]="html htm"
    [gz]="gz gzip tgz svgz"
    [bz2]="bz2 tbz tbz2"
    [xz]="xz txz"
    [zst]="zst tzst"
    [yaml]="yaml yml"
    [svg]="svg svgz"
)

# --- Technical text extensions tolerated (only with --set-mime-type-text) ---
TEXT_TOLERE="txt text md markdown conf cfg ini log sh bash zsh py rb pl php js jsx ts tsx css scss less yaml yml toml json sql csv tsv env service desktop gitignore dockerignore patch diff"

# --- Helpers ----------------------------------------------------------------
lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Returns 0 if $1 is present in the space-separated list $2.
is_in_list() {
    local needle="$1" item
    for item in $2; do
        [[ "$needle" == "$item" ]] && return 0
    done
    return 1
}

# Returns 0 if $2 (real lowercase extension) is an accepted alias of
# canonical extension $1.
is_alias() {
    local canon="$1" ext="$2"
    [[ "$ext" == "$canon" ]] && return 0
    [[ -n "${ALIASES[$canon]:-}" ]] && is_in_list "$ext" "${ALIASES[$canon]}"
}

is_text_tolere() {
    is_in_list "$1" "$TEXT_TOLERE"
}

progress() {
    local cur="$1" tot="$2"
    local width=40
    local pct=$(( cur * 100 / tot ))
    local filled=$(( cur * width / tot ))
    local bar=""
    if [[ "$filled" -gt 0 ]]; then
        bar=$(printf '#%.0s' $(seq 1 "$filled"))
    fi
    printf '\r[%-*s] %3d%% (%d/%d)' "$width" "$bar" "$pct" "$cur" "$tot" >&2
}

report_line() {
    # $1 = statut, $2 = mime, $3 = extension reelle, $4 = chemin
    printf '%-14s | %-32s | %-10s | %s\n' \
        "$1" "$2" "${3:-<aucune>}" "$4" >> "$REPORT"
}

# --- Single filesystem traversal --------------------------------------------
# find is run ONCE; its NUL-delimited output is cached in a temp file so we
# never walk the (potentially remote / slow) tree twice.
TMPLIST=$(mktemp)
trap 'rm -f "$TMPLIST"' EXIT

echo "Parcours du repertoire..." >&2
find "$ROOT" -type f -print0 > "$TMPLIST"

TOTAL=$(tr -cd '\0' < "$TMPLIST" | wc -c)
echo "Total : $TOTAL fichiers." >&2

if [[ "$TOTAL" -eq 0 ]]; then
    echo "Aucun fichier a analyser." >&2
    exit 0
fi

# --- Output initialization --------------------------------------------------
: > "$REPORT"
{
    echo "#!/usr/bin/env bash"
    echo "# Script de correction genere le $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# Verifiez son contenu AVANT de l'executer."
    echo "# Les lignes commentees correspondent a des cas ambigus :"
    echo "# a decommenter uniquement apres verification manuelle."
    echo "set -euo pipefail"
    echo ""
} > "$FIXSCRIPT"

{
    printf 'Rapport genere le %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'Racine analysee : %s\n' "$ROOT"
    printf 'Traitement des fichiers texte : %s\n\n' \
        "$([[ "$PROCESS_TEXT" -eq 1 ]] && echo active || echo desactive)"
    echo "Legende des statuts :"
    echo "  SANS_EXT     : aucune extension, type detecte avec certitude, renommage propose"
    echo "  MAUVAISE     : extension incorrecte, type detecte avec certitude, renommage propose"
    echo "  CONTENEUR    : format conteneur generique, extension actuelle plausible, aucune action"
    echo "  AMBIGU       : format conteneur generique, extension douteuse ou absente, revue manuelle"
    echo "  MIME_INCONNU : type non reference dans la table, aucune action"
    echo ""
    printf '%-14s | %-32s | %-10s | %s\n' "STATUT" "MIME DETECTE" "EXTENSION" "FICHIER"
    printf -- '-%.0s' {1..120}; echo
} >> "$REPORT"

count=0
nb_sans_ext=0
nb_mauvaise_ext=0
nb_conteneur=0
nb_ambigu=0
nb_inconnu=0
nb_texte_ignore=0

# --- Main analysis loop (reads the cached list, no second find) -------------
while IFS= read -r -d '' f; do
    count=$((count + 1))
    progress "$count" "$TOTAL"

    mime=$(file -b --mime-type -- "$f" 2>/dev/null || echo "inconnu")

    base=$(basename -- "$f")
    if [[ "$base" == *.* && "$base" != .* ]]; then
        ext_reelle=$(lc "${base##*.}")
        a_extension=1
    else
        ext_reelle=""
        a_extension=0
    fi

    # --- Text files: skipped by default ---
    if [[ "$mime" == text/* ]]; then
        if [[ "$PROCESS_TEXT" -eq 0 ]]; then
            nb_texte_ignore=$((nb_texte_ignore + 1))
            continue
        fi
        if [[ "$mime" == "text/plain" && "$a_extension" -eq 1 ]] && is_text_tolere "$ext_reelle"; then
            continue
        fi
    fi

    # --- Generic containers: never auto-renamed ---
    if [[ -n "${CONTAINER_SUBTYPES[$mime]+x}" ]]; then
        subtypes="${CONTAINER_SUBTYPES[$mime]}"
        canon_container="${MIME_EXT[$mime]:-}"

        if [[ "$a_extension" -eq 0 ]]; then
            # No extension on a generic container: we cannot guess the real
            # format, so the rename is proposed but left commented out.
            nb_ambigu=$((nb_ambigu + 1))
            report_line "AMBIGU" "$mime" "$ext_reelle" "$f"
            if [[ -n "$canon_container" ]]; then
                printf '# mv -i -- %q %q   # AMBIGU : conteneur generique, verifier le format reel\n' \
                    "$f" "${f}.${canon_container}" >> "$FIXSCRIPT"
            fi
        elif is_in_list "$ext_reelle" "$subtypes"; then
            # Extension is a known specialization of this container: keep it.
            nb_conteneur=$((nb_conteneur + 1))
            report_line "CONTENEUR" "$mime" "$ext_reelle" "$f"
        else
            # Extension is not a plausible specialization: flag for review,
            # but do not guess which of the many subtypes it should become.
            nb_ambigu=$((nb_ambigu + 1))
            report_line "AMBIGU" "$mime" "$ext_reelle" "$f"
        fi
        continue
    fi

    # --- Unreferenced MIME: reported, no correction proposed ---
    if [[ -z "${MIME_EXT[$mime]+x}" ]]; then
        nb_inconnu=$((nb_inconnu + 1))
        report_line "MIME_INCONNU" "$mime" "$ext_reelle" "$f"
        continue
    fi

    canon="${MIME_EXT[$mime]}"

    # Empty canonical extension (executables and similar): ignore.
    [[ -z "$canon" ]] && continue

    if [[ "$a_extension" -eq 0 ]]; then
        # No extension at all, type detected unambiguously.
        nb_sans_ext=$((nb_sans_ext + 1))
        report_line "SANS_EXT" "$mime" "$ext_reelle" "$f"
        printf 'mv -i -- %q %q\n' "$f" "${f}.${canon}" >> "$FIXSCRIPT"
    elif ! is_alias "$canon" "$ext_reelle"; then
        # Present but incorrect extension.
        nb_mauvaise_ext=$((nb_mauvaise_ext + 1))
        report_line "MAUVAISE" "$mime" "$ext_reelle" "$f"
        printf 'mv -i -- %q %q\n' "$f" "${f%.*}.${canon}" >> "$FIXSCRIPT"
    fi

done < "$TMPLIST"

echo >&2
chmod +x "$FIXSCRIPT"

# --- Summary ----------------------------------------------------------------
{
    echo ""
    echo "Resume :"
    printf '  Fichiers analyses          : %d\n' "$count"
    printf '  Sans extension (corrigeable): %d\n' "$nb_sans_ext"
    printf '  Mauvaise extension          : %d\n' "$nb_mauvaise_ext"
    printf '  Conteneurs plausibles       : %d\n' "$nb_conteneur"
    printf '  Cas ambigus (revue manuelle): %d\n' "$nb_ambigu"
    printf '  MIME non reference          : %d\n' "$nb_inconnu"
    printf '  Fichiers texte ignores      : %d\n' "$nb_texte_ignore"
} >> "$REPORT"

echo "Termine." >&2
printf 'Corrections sures : %d | Cas ambigus a revoir : %d\n' \
    "$((nb_sans_ext + nb_mauvaise_ext))" "$nb_ambigu" >&2
echo "Rapport : $REPORT" >&2
echo "Script de correction : $FIXSCRIPT (relire avant execution)" >&2