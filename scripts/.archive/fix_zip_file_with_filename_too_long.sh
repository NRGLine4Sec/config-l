#!/usr/bin/env bash
# __my_script__

set -euo pipefail

#set -x

###########################################################################
# This script renames all files in a ZIP archive to avoid "filename too long"
# issues by preserving the first two directories when possible, hashing 
# remaining directories and the filename with MD5 if necessary, preserving 
# extensions, timestamps, permissions, and generating a JSON mapping.
# Supports dry-run mode to preview changes without creating a zip.
#
# Usage: ./script.sh <zipfile> [--dry-run]
#
# Usage with big files:
# mkdir $HOME/.tmpdir && TMPDIR=$HOME/.tmpdir ./script.sh <zipfile>
###########################################################################

if [ $# -lt 1 ]; then
    echo "Usage: $0 <zipfile> [--dry-run]" >&2
    exit 1
fi

ZIPFILE="$1"
DRYRUN=false
[ "${2:-}" == "--dry-run" ] && DRYRUN=true

BASENAME=$(basename "$ZIPFILE" .zip)
OUTZIP="${BASENAME}-fixed.zip"

CURRENT_DIR="$(pwd)"
WORKDIR=$(mktemp -d)
MAPFILE=$(mktemp)
trap 'rm -rf "$WORKDIR" "$MAPFILE" "$TMP_MAPPING"' EXIT

###########################################################################
# Max length per path component before hashing
MAX_COMPONENT_LEN=250

###########################################################################
# Function: transform_path
# Input: original path in the zip
# Output: new transformed path
# Logic:
#   1. For all components (first_dir, second_dir, subdirs, filename):
#       - if component length > MAX_COMPONENT_LEN OR contains weird chars → MD5
#   2. For filename:
#       - preserve extension after MD5 of basename
#   3. Compose final path according to number of components:
#       - 1 component: MD5(filename).ext
#       - 2 components: first_dir/md5_file.ext
#       - 3+ components: first_dir/second_dir/md5_subdirs/md5_file.ext
###########################################################################
transform_path() {
    local path="$1"
    path="${path#./}"
    path="${path#/}"
    path="$(printf "%s" "$path" | sed 's|//\+|/|g')"

    IFS='/' read -r -a parts <<< "$path"
    local n=${#parts[@]}
    if (( n == 0 )); then
        printf ""
        return
    fi

    # Detect weird segments (invalid UTF-8, non-printable, or replacement char)
    is_weird() {
        local s="$1"
        if ! printf '%s' "$s" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
            return 0
        fi
        if printf '%s' "$s" | grep -q '[^[:print:]]'; then
            return 0
        fi
        if printf '%s' "$s" | grep -q '�'; then
            return 0
        fi
        return 1
    }

    md5_of() { printf "%s" "$1" | md5sum | cut -d' ' -f1; }

    # Sanitize all components: weird OR too long → hash
    local i
    for (( i=0; i<n; i++ )); do
        local seg="${parts[i]}"
        if [[ -z "$seg" ]] || is_weird "$seg" || (( ${#seg} > MAX_COMPONENT_LEN )); then
            parts[i]=$(md5_of "$seg")
        fi
    done

    local first="${parts[0]}"
    local second="${parts[1]:-}"
    local filename="${parts[n-1]}"

    # Extract basename and extension
    local basename_orig="${filename%.*}"
    local extension=""
    [[ "$basename_orig" != "$filename" ]] && extension=".${filename##*.}"

    # MD5 of filename
    local md5_file
    md5_file=$(md5_of "$basename_orig")

    # MD5 of subdirs if present
    local md5_subdir=""
    if (( n > 3 )); then
        local tmp_arr=()
        for (( i=2; i<=n-2; i++ )); do
            tmp_arr+=("${parts[i]}")
        done
        local concat
        concat=$(IFS=/; printf "%s" "${tmp_arr[*]}")
        md5_subdir=$(md5_of "$concat")
    fi

    # Compose final path according to number of components
    if (( n == 1 )); then
        printf "%s%s" "$md5_file" "$extension"
    elif (( n == 2 )); then
        printf "%s/%s%s" "$first" "$md5_file" "$extension"
    else
        if [[ -n "$md5_subdir" ]]; then
            printf "%s/%s/%s/%s%s" "$first" "$second" "$md5_subdir" "$md5_file" "$extension"
        else
            printf "%s/%s/%s%s" "$first" "$second" "$md5_file" "$extension"
        fi
    fi
}

###########################################################################
# List all entries in the zip
###########################################################################
echo "Listing archive entries..."
python3 - "$ZIPFILE" "$MAPFILE" <<'PYTHON'
import sys
import zipfile

zip_path = sys.argv[1]
mapfile = sys.argv[2]

with zipfile.ZipFile(zip_path, "r") as zf:
    with open(mapfile, "w", encoding="utf-8") as f:
        for info in zf.infolist():
            f.write(info.filename + "\n")
PYTHON

###########################################################################
# Generate mapping original -> new path
###########################################################################
echo "Generating mapping..."
TMP_MAPPING=$(mktemp)
while IFS= read -r orig; do
    [ -z "$orig" ] && continue
    new=$(transform_path "$orig")
    echo -e "$orig\t$new"
done < "$MAPFILE" > "$TMP_MAPPING"

if [ "$DRYRUN" = true ]; then
    echo "=== Dry-run: mapping original -> new ==="
    cat "$TMP_MAPPING"
    exit 0
fi

###########################################################################
# Extract files to temporary working directory
###########################################################################
echo "Extracting files..."
python3 - "$ZIPFILE" "$WORKDIR" "$TMP_MAPPING" <<'PYTHON'
import sys, os, zipfile, time

zip_path = sys.argv[1]
workdir = sys.argv[2]
mapping_file = sys.argv[3]

mapping = []
with open(mapping_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\r\n")
        if not line or "\t" not in line:
            continue
        orig, new = line.split("\t", 1)
        mapping.append((orig, new))

with zipfile.ZipFile(zip_path, "r") as zf:
    for orig, new in mapping:
        dest = os.path.join(workdir, new)
        if orig.endswith("/"):
            os.makedirs(dest, exist_ok=True)
            try:
                info = zf.getinfo(orig)
                dt = info.date_time
                mtime = time.mktime((*dt,0,0,-1))
                os.utime(dest, (mtime, mtime))
            except Exception:
                pass
            continue
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        try:
            with zf.open(orig) as rf, open(dest, "wb") as wf:
                while chunk := rf.read(8192):
                    wf.write(chunk)
            info = zf.getinfo(orig)
            dt = info.date_time
            mtime = time.mktime((*dt,0,0,-1))
            os.utime(dest, (mtime, mtime))
            perm = info.external_attr >> 16
            if perm != 0:
                os.chmod(dest, perm)
        except KeyError:
            sys.stderr.write(f"⚠ Warning: entry not found in zip: {orig}\n")
        except Exception as e:
            sys.stderr.write(f"Error extracting {orig} -> {new}: {e}\n")
PYTHON

###########################################################################
# Create the new zip in the current working directory
###########################################################################
echo "Creating new zip $OUTZIP..."
cd "$WORKDIR"
zip -r -q "$CURRENT_DIR/$OUTZIP" .
cd - >/dev/null

###########################################################################
# Generate JSON mapping
###########################################################################
JSON_OUT="$CURRENT_DIR/${BASENAME}-fixed.json"

python3 <<PYTHON
import json
mapping_file = "$TMP_MAPPING"
json_file = "$JSON_OUT"

mapping = {}
with open(mapping_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        if not line or "\t" not in line:
            continue
        orig, new = line.split("\t", 1)
        mapping[orig] = new

with open(json_file, "w", encoding="utf-8") as jf:
    json.dump(mapping, jf, indent=2, ensure_ascii=False)

try:
    with open(json_file, "r", encoding="utf-8") as jf:
        json.load(jf)
except Exception as e:
    import sys
    sys.stderr.write(f"ERROR: JSON validation failed: {e}\n")
    sys.exit(1)
PYTHON

echo "Done. New zip created: $OUTZIP"
echo "JSON mapping saved into: ${BASENAME}-fixed.json"
echo "Mapping original -> new (tab separated):"
cat "$TMP_MAPPING"
