#!/usr/bin/env python3
# =============================================================================
# fix_zip_file_with_filename_too_long.py  --  V2  (Python rewrite of the original Bash script)
#
# WHAT THIS TOOL DOES
# -------------------
# Some ZIP archives contain paths that are too long for the target filesystem
# (Linux ext4 limits a single path *component* to 255 BYTES, NAME_MAX). Trying
# to extract such an archive fails with "File name too long" (ENAMETOOLONG).
#
# This tool reads an input ZIP and writes a NEW ZIP in which every path has been
# shortened so it can be extracted safely, while:
#   * preserving the first two directory levels when possible (readability),
#   * hashing (MD5) the intermediate directories and the file base name,
#   * preserving the file extension,
#   * preserving timestamps and permissions of every entry,
#   * neutralising dangerous or malformed components (path traversal, control
#     characters, invalid names),
#   * detecting and resolving name collisions instead of silently overwriting,
#   * producing a JSON mapping (original path -> new path).
#
# WHY IT IS A STREAMING ZIP->ZIP TOOL (design note for the Bash-minded reader)
# ---------------------------------------------------------------------------
# The original script extracted every file to a temporary directory on disk and
# then re-zipped that directory. That approach has two problems: it needs the
# local filesystem to accept the (possibly still-long) staged names, and it
# clobbers directory timestamps when files are written into them. Here we never
# touch the local filesystem for the payload: we copy each entry's bytes
# directly from the input ZIP object to the output ZIP object, carrying the
# metadata over verbatim. This is faster, avoids a whole class of filesystem
# bugs, and preserves permissions/timestamps exactly.
#
# The observable outputs are identical in spirit to V1: a "<name>-fixed.zip" and
# a "<name>-fixed.json" mapping file.
#
# USAGE
# -----
#   ./fix_zip_file_with_filename_too_long.py ARCHIVE.zip                 # produce ARCHIVE-fixed.zip + .json
#   ./fix_zip_file_with_filename_too_long.py ARCHIVE.zip --dry-run       # only print the mapping
#   ./fix_zip_file_with_filename_too_long.py ARCHIVE.zip -o out.zip -f   # custom output, overwrite if exists
#   ./fix_zip_file_with_filename_too_long.py ARCHIVE.zip --max-component-len 200
# =============================================================================

import argparse                 # command line argument parsing (like getopts, but nicer)
import hashlib                  # provides md5()
import json                     # to write the mapping file
import os                       # path helpers (splitext, basename, ...)
import shutil                   # copyfileobj() for streaming bytes
import sys                      # stderr, exit codes
import unicodedata              # to classify characters (control, format, ...)
import zipfile                  # the whole ZIP read/write machinery


# Make console output robust regardless of the ambient locale. Our French
# messages contain accented characters; without this, running under a non
# UTF-8 stdout (for instance LANG=C from a cron job) would raise
# UnicodeEncodeError and abort the program. We force UTF-8 and degrade
# gracefully (backslash escapes) if a stream truly cannot represent a
# character. This is wrapped in a try/except because some execution contexts
# replace sys.stdout with an object that lacks reconfigure().
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="backslashreplace")
    except (AttributeError, ValueError):
        pass


# -----------------------------------------------------------------------------
# Small, pure helper functions.
# In Python, a function is defined with "def name(args):" and the body is the
# indented block. There are no braces; indentation IS the block structure.
# -----------------------------------------------------------------------------

def md5_hex(text: str) -> str:
    """Return the 32-character hexadecimal MD5 of a string.

    MD5 is used ONLY to shorten/normalise names, never for security here.
    We hash the UTF-8 bytes of the string. 'surrogatepass' lets us also hash
    strings that contain lone surrogate code points (which can appear when a
    filename was decoded from raw bytes with error recovery); a normal UTF-8
    encode would raise on those.
    """
    data = text.encode("utf-8", errors="surrogatepass")
    return hashlib.md5(data).hexdigest()


def component_needs_hashing(component: str, max_len_bytes: int) -> bool:
    """Decide whether a single path component must be replaced by its hash.

    A component is replaced when it is dangerous, malformed, or too long:

      * '.' or '..'  -> path-traversal / no-op segments. We NEVER keep these,
        otherwise a crafted archive like "../../etc/passwd" could escape the
        extraction directory. Hashing them turns them into harmless directory
        names while keeping the entry distinct.

      * contains the Unicode replacement character U+FFFD -> a tell-tale sign
        that the original name was already damaged during decoding.

      * contains any "Other" character (Unicode general category starting with
        'C': control Cc, format Cf, surrogate Cs, private-use Co, unassigned
        Cn). These are non-printable / non-portable and often break tools.

      * is longer than max_len_bytes when encoded as UTF-8. NOTE: the relevant
        filesystem limit (NAME_MAX = 255 on Linux) is measured in BYTES, not
        characters, so a name made of many multi-byte characters (e.g. emoji)
        can be short in characters yet too long in bytes. We measure bytes.
    """
    # Path-traversal / current-dir markers: always neutralise.
    if component in (".", ".."):
        return True

    # Replacement character U+FFFD has category 'So' (not 'C'), so check it out
    # explicitly here.
    if "\ufffd" in component:
        return True

    # Any control/format/surrogate/private/unassigned character.
    for ch in component:
        if unicodedata.category(ch)[0] == "C":
            return True

    # Byte-length limit for the target filesystem.
    if len(component.encode("utf-8", errors="surrogatepass")) > max_len_bytes:
        return True

    return False


def keep_or_hash(component: str, max_len_bytes: int) -> str:
    """Return the component unchanged if it is safe/short, else its MD5."""
    if component_needs_hashing(component, max_len_bytes):
        return md5_hex(component)
    return component


def sanitize_extension(ext: str, max_len_bytes: int) -> str:
    """Return a file extension that is safe to append after a 32-char MD5.

    The extension returned by os.path.splitext includes the leading dot
    (e.g. ".txt"). We keep it as-is in the normal case. We DROP it (return "")
    only in two pathological situations:

      * the extension contains control/format/etc. characters, or
      * an MD5 (32 chars) plus this extension would still exceed the per
        component byte budget.

    Dropping a pathological extension is a rare, bounded loss and keeps the
    guarantee that every produced component fits the filesystem limit.
    """
    if not ext:
        return ""

    # Strip the leading dot only to classify the extension body's characters.
    body = ext[1:] if ext.startswith(".") else ext
    if body and component_needs_hashing(body, max_len_bytes):
        return ""

    # 32 = length of an MD5 hex digest, which is what precedes the extension.
    if 32 + len(ext.encode("utf-8", errors="surrogatepass")) > max_len_bytes:
        return ""

    return ext


def split_components(path: str):
    """Split a ZIP entry name into clean components and a directory flag.

    Returns a tuple (parts, is_dir) where:
      * parts is a list of non-empty path components, in order,
      * is_dir is True if the original name ended with '/' (a directory entry).

    Normalisation performed here:
      * a trailing '/' marks a directory entry (recorded, then irrelevant),
      * leading '/' is stripped (an absolute name must not stay absolute),
      * a leading './' is stripped,
      * empty components (from '//' or leading/trailing slashes) are dropped,
      * '.' components (current directory, no-op) are dropped.

    IMPORTANT: per the ZIP specification only the forward slash '/' separates
    components. A backslash '\\' is a *valid character* in a Unix filename, so
    we deliberately do NOT treat it as a separator. '..' is kept here as a
    component and neutralised later by component_needs_hashing().
    """
    is_dir = path.endswith("/")

    p = path.lstrip("/")            # drop any leading slashes (absolute -> relative)
    if p.startswith("./"):
        p = p[2:]                   # drop a single leading "./"

    parts = [seg for seg in p.split("/") if seg not in ("", ".")]
    return parts, is_dir


def build_target(parts, is_file: bool, max_len_bytes: int) -> str:
    """Build the shortened path for an entry from its ORIGINAL components.

    Composition rules (mirroring the original script, with fixes):

      * The first and second components are PRESERVED, unless they are
        dangerous/malformed/too-long, in which case they are hashed.
      * Every component strictly between the second and the last (the "middle"
        directories) is collapsed into a SINGLE MD5 of their '/'-joined value.
      * The last component is the "name":
          - for a FILE: its base name is ALWAYS hashed (this is the core
            shortening) and the sanitised extension is appended,
          - for a DIRECTORY: it is preserved unless dangerous/too-long.

    Layout by number of components N:
        N == 1 :  <name>
        N == 2 :  <first>/<name>
        N >= 3 :  <first>/<second>/<md5(middle)>/<name>       (if middle exists)
                  <first>/<second>/<name>                      (if no middle)

    'parts' must be non-empty (guaranteed by the caller).
    """
    n = len(parts)

    first = keep_or_hash(parts[0], max_len_bytes)
    second = keep_or_hash(parts[1], max_len_bytes) if n >= 2 else None

    # Build the final "name" component.
    last = parts[-1]
    if is_file:
        base, ext = os.path.splitext(last)     # dotfile-safe: '.bashrc' -> ('.bashrc','')
        name = md5_hex(base) + sanitize_extension(ext, max_len_bytes)
    else:
        name = keep_or_hash(last, max_len_bytes)

    # Middle directories = everything after first+second and before the last.
    # parts[2 : n-1] is empty when n <= 3, which is exactly what we want.
    middle = parts[2:n - 1]
    md5_middle = md5_hex("/".join(middle)) if middle else None

    if n == 1:
        return name
    if n == 2:
        return f"{first}/{name}"
    # n >= 3
    if md5_middle is not None:
        return f"{first}/{second}/{md5_middle}/{name}"
    return f"{first}/{second}/{name}"


def disambiguate(target: str, is_dir: bool, used: set) -> str:
    """Return a variant of 'target' that is not present in 'used'.

    Collisions are resolved by inserting a numeric suffix:
      * FILE  "a/b/HASH.txt"  -> "a/b/HASH-1.txt", "a/b/HASH-2.txt", ...
      * DIR   "a/b/HASH/"     -> "a/b/HASH-1/",   "a/b/HASH-2/",   ...

    The suffix is inserted BEFORE the file extension so the extension is kept.
    'used' is a set of already-taken target paths; directory targets are stored
    in it WITHOUT the trailing slash so a file and a directory can never share
    the same path (which is illegal on a real filesystem).
    """
    # Normalise the key we test against 'used' (directories tracked without '/').
    def key(t):
        return t.rstrip("/") if is_dir else t

    if key(target) not in used:
        return target

    # Split into "head/<stem><ext>" so we can insert a suffix on the stem.
    if is_dir:
        stem = target.rstrip("/")
        ext = ""
        head = ""
        if "/" in stem:
            head, stem = stem.rsplit("/", 1)
            head += "/"
    else:
        head = ""
        name = target
        if "/" in target:
            head, name = target.rsplit("/", 1)
            head += "/"
        stem, ext = os.path.splitext(name)

    i = 1
    while True:
        candidate = f"{head}{stem}-{i}{ext}"
        if is_dir:
            candidate += "/"
        if key(candidate) not in used:
            return candidate
        i += 1


# -----------------------------------------------------------------------------
# Mapping computation: turn the list of input entries into a list of
# (ZipInfo, target_path, is_dir) triples with all collisions resolved.
# -----------------------------------------------------------------------------

def compute_mapping(infos, max_len_bytes: int):
    """Compute the shortened targets for every input entry.

    'infos' is the list returned by ZipFile.infolist(), in archive order.

    Returns (plan, collisions) where:
      * plan is a list of dicts: {"info", "target", "is_dir"},
      * collisions is a list of (original, first_target, final_target) for the
        entries whose target had to be disambiguated (used only for reporting).

    Redundant directory entries are dropped: if an explicit directory entry is a
    prefix of at least one FILE entry, the file paths already recreate the
    needed structure, so keeping the (necessarily inconsistent, because the
    middle directories are collapsed) directory entry would only create orphan
    empty folders. Truly empty directories are preserved, with their metadata.
    """
    # Pre-compute the set of original file names, to detect redundant dir entries.
    file_names = [i.filename for i in infos if not i.is_dir()]

    used = set()             # already-assigned target paths (dirs without '/')
    plan = []
    collisions = []

    for info in infos:
        is_dir = info.is_dir()

        # Drop directory entries that merely prefix a file entry.
        if is_dir and any(fn.startswith(info.filename) for fn in file_names):
            continue

        parts, _ = split_components(info.filename)
        if not parts:
            # Nothing usable (e.g. a name that was only slashes). Skip it.
            sys.stderr.write(
                f"Avertissement: entrée ignorée (nom vide après normalisation) : "
                f"{info.filename!r}\n"
            )
            continue

        target = build_target(parts, is_file=not is_dir, max_len_bytes=max_len_bytes)
        if is_dir and not target.endswith("/"):
            target += "/"

        final = disambiguate(target, is_dir, used)
        if final != target:
            collisions.append((info.filename, target, final))

        used.add(final.rstrip("/") if is_dir else final)
        plan.append({"info": info, "target": final, "is_dir": is_dir})

    return plan, collisions


# -----------------------------------------------------------------------------
# Output writing.
# -----------------------------------------------------------------------------

def write_output_zip(src_zip: zipfile.ZipFile, plan, out_path: str):
    """Write the shortened archive by streaming bytes from src_zip.

    For every planned entry we build a fresh ZipInfo that carries over the
    original metadata (timestamp, permissions, compression method, comment,
    creator information) and only changes the name. File payloads are streamed
    in chunks so that arbitrarily large files never need to fit in memory.
    """
    with zipfile.ZipFile(out_path, "w", allowZip64=True) as zout:
        for item in plan:
            info = item["info"]
            target = item["target"]

            # Fresh ZipInfo with the new name and the original timestamp.
            out_info = zipfile.ZipInfo(target, date_time=info.date_time)
            # Carry the metadata over verbatim.
            out_info.compress_type = info.compress_type
            out_info.external_attr = info.external_attr     # permissions + attrs
            out_info.internal_attr = info.internal_attr
            out_info.create_system = info.create_system
            out_info.comment = info.comment
            # We intentionally let zipfile recompute the filename encoding flag
            # (it sets the UTF-8 bit automatically for non-ASCII names).

            if item["is_dir"]:
                # A directory is a zero-byte entry whose name ends with '/'.
                zout.writestr(out_info, b"")
            else:
                # Stream the payload from the source entry to the destination
                # entry without loading the whole file into memory.
                with src_zip.open(info) as source, zout.open(out_info, "w") as dest:
                    shutil.copyfileobj(source, dest, length=1024 * 1024)


def write_json_mapping(plan, json_path: str):
    """Write the original -> new mapping as JSON.

    Compatibility note: V1 produced a JSON OBJECT keyed by original path. A ZIP
    archive may legally contain DUPLICATE entry names, and an object would
    silently collapse them. Therefore:
      * if every original name is unique, we emit the V1-compatible object
        {original: new, ...};
      * if duplicates exist, we emit a LIST of
        {"original": ..., "new": ..., "is_dir": ...} objects (and warn), so no
        information is lost.
    """
    originals = [item["info"].filename for item in plan]
    has_duplicates = len(originals) != len(set(originals))

    if has_duplicates:
        sys.stderr.write(
            "Avertissement : noms dupliqués dans l'archive ; le JSON utilise le "
            "format liste au lieu du format objet.\n"
        )
        payload = [
            {"original": item["info"].filename,
             "new": item["target"],
             "is_dir": item["is_dir"]}
            for item in plan
        ]
    else:
        payload = {item["info"].filename: item["target"] for item in plan}

    with open(json_path, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, indent=2, ensure_ascii=False)

    # Re-read to validate the file is syntactically correct JSON.
    with open(json_path, "r", encoding="utf-8") as fh:
        json.load(fh)


# -----------------------------------------------------------------------------
# Command-line entry point.
# -----------------------------------------------------------------------------

def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Raccourcit les chemins d'une archive ZIP pour éviter les "
                    "erreurs 'nom de fichier trop long'."
    )
    parser.add_argument("zipfile", help="Archive ZIP à traiter.")
    parser.add_argument(
        "-o", "--output",
        help="Chemin de l'archive de sortie (défaut : <nom>-fixed.zip)."
    )
    parser.add_argument(
        "--json",
        help="Chemin du fichier de mapping JSON (défaut : <nom>-fixed.json)."
    )
    parser.add_argument(
        "--max-component-len", type=int, default=250,
        help="Longueur maximale (en octets) d'un composant avant hachage "
             "(défaut : 250)."
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true",
        help="Affiche uniquement le mapping, sans rien écrire."
    )
    parser.add_argument(
        "-f", "--force", action="store_true",
        help="Écrase les fichiers de sortie s'ils existent déjà."
    )
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv if argv is not None else sys.argv[1:])

    if args.max_component_len <= 0:
        sys.stderr.write("Erreur : --max-component-len doit être strictement positif.\n")
        return 2
    # An MD5 digest is 32 bytes; a shorter budget cannot represent hashed names.
    if args.max_component_len < 40:
        sys.stderr.write(
            "Erreur : --max-component-len doit valoir au moins 40 (un condensat "
            "MD5 fait déjà 32 caractères).\n"
        )
        return 2

    if not os.path.isfile(args.zipfile):
        sys.stderr.write(f"Erreur : fichier introuvable : {args.zipfile}\n")
        return 2

    # Derive default output names from the input base name.
    base = os.path.basename(args.zipfile)
    if base.lower().endswith(".zip"):
        base = base[:-4]
    out_zip = args.output or f"{base}-fixed.zip"
    out_json = args.json or f"{base}-fixed.json"

    # Refuse to clobber existing outputs unless --force was given.
    if not args.dry_run and not args.force:
        for path in (out_zip, out_json):
            if os.path.exists(path):
                sys.stderr.write(
                    f"Erreur : {path} existe déjà (utilisez --force pour écraser).\n"
                )
                return 2

    # Open the source archive and validate it.
    try:
        src_zip = zipfile.ZipFile(args.zipfile, "r")
    except zipfile.BadZipFile as exc:
        sys.stderr.write(f"Erreur : archive ZIP invalide : {exc}\n")
        return 1

    with src_zip:
        infos = src_zip.infolist()
        if not infos:
            sys.stderr.write("Avertissement : l'archive est vide, rien à faire.\n")

        plan, collisions = compute_mapping(infos, args.max_component_len)

        # Report collisions (both in dry-run and normal mode).
        for original, first, final in collisions:
            sys.stderr.write(
                f"Collision résolue : {original!r} -> {final!r} "
                f"(cible initiale {first!r} déjà prise).\n"
            )

        if args.dry_run:
            print("=== Simulation (dry-run): original -> nouveau ===")
            for item in plan:
                kind = "d" if item["is_dir"] else "f"
                print(f"[{kind}] {item['info'].filename}\t{item['target']}")
            print(f"\n{len(plan)} entrée(s), {len(collisions)} collision(s) résolue(s).")
            return 0

        # Write the shortened archive and the JSON mapping.
        write_output_zip(src_zip, plan, out_zip)
        write_json_mapping(plan, out_json)

    print(f"Terminé. Archive créée : {out_zip}")
    print(f"Mapping JSON : {out_json}")
    print(f"{len(plan)} entrée(s) traitée(s), {len(collisions)} collision(s) résolue(s).")
    return 0


if __name__ == "__main__":
    # sys.exit() sets the process exit code, like "exit N" in Bash.
    sys.exit(main())
