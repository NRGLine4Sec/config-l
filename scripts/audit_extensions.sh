#!/usr/bin/env bash
# __my_script__

# audit_extensions.sh - detects files whose extension does not match
#                       their real MIME type (via libmagic / file).
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
# Aliases (jpg/jpeg, tif/tiff...) are handled separately below.
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
)

# --- Accepted aliases -------------------------------------------------------
# Key = canonical extension, value = list of equivalent extensions.
# A file already bearing one of these is NOT flagged.
declare -A ALIASES=(
    [jpg]="jpg jpeg jpe jfif"
    [tiff]="tiff tif"
    [heic]="heic heics"
    [heif]="heif heifs"
    [mpg]="mpg mpeg mpe m2v"
    [3gp]="3gp 3gpp"
    [mid]="mid midi"
    [aiff]="aiff aif aifc"
    [html]="html htm"
    [gz]="gz gzip"
    [yaml]="yaml yml"
)

# --- Technical text extensions tolerated (only with --set-mime-type-text) ---
TEXT_TOLERE="txt text md markdown conf cfg ini log sh bash py rb pl js ts css scss yaml yml toml sql csv tsv env gitignore dockerignore"

# --- Helpers ----------------------------------------------------------------
lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Returns 0 if $2 (real lowercase extension) is an accepted alias of
# canonical extension $1.
is_alias() {
    local canon="$1" ext="$2" a
    if [[ -n "${ALIASES[$canon]:-}" ]]; then
        for a in ${ALIASES[$canon]}; do
            [[ "$ext" == "$a" ]] && return 0
        done
    fi
    [[ "$ext" == "$canon" ]]
}

is_text_tolere() {
    local ext="$1" t
    for t in $TEXT_TOLERE; do
        [[ "$ext" == "$t" ]] && return 0
    done
    return 1
}

progress() {
    local cur="$1" tot="$2"
    local width=40
    local pct=$(( cur * 100 / tot ))
    local filled=$(( cur * width / tot ))
    local bar
    bar=$(printf '#%.0s' $(seq 1 "$filled") 2>/dev/null || true)
    printf '\r[%-*s] %3d%% (%d/%d)' "$width" "$bar" "$pct" "$cur" "$tot" >&2
}

# --- Single filesystem traversal --------------------------------------------
# find is run ONCE; its NUL-delimited output is cached in a temp file so we
# never hit the (potentially remote / slow) filesystem tree twice.
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
    echo "set -euo pipefail"
    echo ""
} > "$FIXSCRIPT"

printf 'Rapport genere le %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT"
printf 'Racine analysee : %s\n' "$ROOT" >> "$REPORT"
printf 'Traitement des fichiers texte : %s\n\n' \
    "$([[ "$PROCESS_TEXT" -eq 1 ]] && echo active || echo desactive)" >> "$REPORT"
printf '%-12s | %-30s | %s\n' "PROBLEME" "MIME DETECTE" "FICHIER" >> "$REPORT"
printf -- '-%.0s' {1..100} >> "$REPORT"; echo >> "$REPORT"

count=0
nb_sans_ext=0
nb_mauvaise_ext=0
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
        # With --set-mime-type-text: tolerate known technical extensions.
        if [[ "$mime" == "text/plain" && "$a_extension" -eq 1 ]] && is_text_tolere "$ext_reelle"; then
            continue
        fi
    fi

    # --- Unreferenced MIME: reported, no correction proposed ---
    if [[ -z "${MIME_EXT[$mime]+x}" ]]; then
        nb_inconnu=$((nb_inconnu + 1))
        printf '%-12s | %-30s | %s\n' "MIME_INCONNU" "$mime" "$f" >> "$REPORT"
        continue
    fi

    canon="${MIME_EXT[$mime]}"

    # Empty canonical extension (executables): ignore.
    [[ -z "$canon" ]] && continue

    if [[ "$a_extension" -eq 0 ]]; then
        # No extension at all.
        nb_sans_ext=$((nb_sans_ext + 1))
        printf '%-12s | %-30s | %s\n' "SANS_EXT" "$mime" "$f" >> "$REPORT"
        printf 'mv -i -- %q %q\n' "$f" "${f}.${canon}" >> "$FIXSCRIPT"
    elif ! is_alias "$canon" "$ext_reelle"; then
        # Present but incorrect extension.
        nb_mauvaise_ext=$((nb_mauvaise_ext + 1))
        printf '%-12s | %-30s | %s\n' "MAUVAISE" "$mime" "$f" >> "$REPORT"
        nouveau="${f%.*}.${canon}"
        printf 'mv -i -- %q %q\n' "$f" "$nouveau" >> "$FIXSCRIPT"
    fi

done < "$TMPLIST"

echo >&2
chmod +x "$FIXSCRIPT"

# --- Summary ----------------------------------------------------------------
{
    echo ""
    echo "Resume :"
    echo "  Fichiers analyses      : $count"
    echo "  Sans extension         : $nb_sans_ext"
    echo "  Mauvaise extension     : $nb_mauvaise_ext"
    echo "  MIME non reference     : $nb_inconnu"
    echo "  Fichiers texte ignores : $nb_texte_ignore"
} >> "$REPORT"

echo "Termine." >&2
echo "Rapport : $REPORT" >&2
echo "Script de correction : $FIXSCRIPT (relire avant execution)" >&2