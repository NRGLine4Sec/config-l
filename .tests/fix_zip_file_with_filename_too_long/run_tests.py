#!/usr/bin/env python3
# =============================================================================
# run_tests.py -- exhaustive validation suite for fix_zip_file_with_filename_too_long.py (V2)
#
# Strategy: build several ZIP archives that deliberately exercise normal,
# edge, and MALFORMED cases, run the script as a real subprocess (so the CLI,
# argparse and exit codes are tested too), then assert a battery of invariants
# on every produced archive. Also re-run under several locales to prove the
# Python version is locale-independent (a weakness of the Bash original).
#
# Any failure prints a clear message and makes the process exit non-zero.
# =============================================================================

import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "fix_zip_file_with_filename_too_long.py")
MAXLEN = 250  # must match the script default used in the runs below

# ---- tiny assertion framework ----------------------------------------------
PASSED = 0
FAILED = 0
FAILURES = []


def check(cond, msg):
    global PASSED, FAILED
    if cond:
        PASSED += 1
    else:
        FAILED += 1
        FAILURES.append(msg)
        print(f"  FAIL: {msg}")


# ---- helpers to build archives ---------------------------------------------

def add(zf, name, data=b"", date_time=(2021, 1, 2, 3, 4, 6), mode=0o100644, is_dir=False):
    """Add one entry with explicit metadata."""
    zi = zipfile.ZipInfo(name, date_time=date_time)
    zi.compress_type = zipfile.ZIP_DEFLATED
    if is_dir:
        # directory: set the directory external-attr bits + a marker low bit
        zi.external_attr = (mode << 16) | 0x10
        zf.writestr(zi, b"")
    else:
        zi.external_attr = mode << 16
        zf.writestr(zi, data)


def build_corpus(path):
    """A broad archive mixing nearly every normal and edge case."""
    with zipfile.ZipFile(path, "w") as z:
        add(z, "short.txt", b"root file")                        # n==1
        add(z, "a/file.txt", b"n2")                              # n==2
        add(z, "a/b/file.txt", b"n3 no middle")                  # n==3
        add(z, "a/b/c/file.txt", b"n4 one middle")               # n==4
        add(z, "a/b/c/d/e/deep.txt", b"n6 several middle")       # n==6
        add(z, ("x" * 300) + "/file.txt", b"long first ascii")   # long component
        add(z, "dir/" + ("\u00e9" * 200) + "/f.txt", b"long multibyte")  # 400 bytes
        add(z, ".bashrc", b"dotfile a")                          # dotfile at root
        add(z, "cfg/.env", b"dotfile nested")
        add(z, "arch/backup.tar.gz", b"multi ext")
        add(z, "docs/README", b"no ext")
        add(z, "wd/name.", b"trailing dot name")                 # ext == '.'
        add(z, "ctl/na\x01me.txt", b"control char")              # control -> hashed comp
        add(z, "rep/bad\ufffd.txt", b"replacement char")         # U+FFFD -> hashed comp
        add(z, "zwj/emoji\u200dx.txt", b"zero width joiner")     # format char -> hashed
        add(z, "\U0001F4C1/\U0001F4C4.txt", b"emoji dir/file")   # emoji (printable, kept)
        add(z, "caf\u00e9/na\u00efve.txt", b"accents kept")      # accents (kept)
        add(z, "my dir/my file.txt", b"spaces kept")
        add(z, ("b" * 250) + "/f.txt", b"exactly at limit")     # 250 bytes -> KEPT
        add(z, ("c" * 251) + "/g.txt", b"one over limit")        # 251 bytes -> HASHED
        add(z, "ext/huge." + ("z" * 300), b"pathological ext")   # ext dropped
        add(z, "empty/zero.bin", b"")                            # empty file
        add(z, "big/data.bin", os.urandom(2 * 1024 * 1024))      # streaming
        add(z, "emptydir/", is_dir=True, mode=0o040755)          # kept empty dir
        add(z, "a/", is_dir=True, mode=0o040700)                 # redundant dir -> dropped
        add(z, "a/b/", is_dir=True)                              # redundant dir -> dropped
        add(z, ("L" * 300) + "/", is_dir=True)                   # long empty-dir name -> hashed
        add(z, "norm//double.txt", b"double slash")              # normalization
        add(z, "./lead.txt", b"leading dot-slash")               # normalization
        add(z, "/abs.txt", b"absolute -> relative")              # normalization


def build_traversal(path):
    with zipfile.ZipFile(path, "w") as z:
        add(z, "../../evil.txt", b"escape up")
        add(z, "a/../../b.txt", b"escape mid")
        add(z, "/etc/passwd.txt", b"absolute")
        add(z, "ok/../still.txt", b"single up")


def build_duplicates(path):
    # A ZIP may legally hold duplicate names; building such an input triggers a
    # harmless UserWarning from the stdlib, which we silence here (it concerns
    # the INPUT we craft, not the script's output).
    import warnings
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        with zipfile.ZipFile(path, "w") as z:
            add(z, "dup.txt", b"first copy")
            add(z, "dup.txt", b"second copy")     # legal duplicate
            add(z, "d/same.txt", b"nested first")
            add(z, "d/same.txt", b"nested second")


def build_collide_by_norm(path):
    with zipfile.ZipFile(path, "w") as z:
        add(z, "p/q/f.txt", b"plain")
        add(z, "p//q/f.txt", b"double slash same target")


def build_empty(path):
    with zipfile.ZipFile(path, "w"):
        pass


# ---- validation of a produced archive --------------------------------------

def kept_sequence(infos):
    """Replicate the script's drop rule to align input->output positionally.

    A directory entry that is a prefix of any FILE entry is dropped; a name
    that normalises to nothing is dropped. Everything else is kept, in order.
    """
    file_names = [i.filename for i in infos if not i.is_dir()]
    out = []
    for info in infos:
        if info.is_dir() and any(fn.startswith(info.filename) for fn in file_names):
            continue
        # replicate "empty after normalization" skip
        p = info.filename.lstrip("/")
        if p.startswith("./"):
            p = p[2:]
        parts = [s for s in p.split("/") if s not in ("", ".")]
        if not parts:
            continue
        out.append(info)
    return out


def component_bytes_ok(path):
    for comp in path.rstrip("/").split("/"):
        if len(comp.encode("utf-8", "surrogatepass")) > MAXLEN:
            return False
    return True


def validate(src_path, out_zip, out_json, label):
    print(f"[validate] {label}")
    with zipfile.ZipFile(src_path, "r") as zin, zipfile.ZipFile(out_zip, "r") as zout:
        src_infos = zin.infolist()
        out_infos = zout.infolist()

        # 1. Integrity of the produced archive.
        check(zout.testzip() is None, f"{label}: output archive fails CRC testzip()")

        # 2. Positional alignment input(kept) -> output.
        expected = kept_sequence(src_infos)
        check(len(expected) == len(out_infos),
              f"{label}: entry count kept={len(expected)} out={len(out_infos)}")

        n = min(len(expected), len(out_infos))
        seen_targets = set()
        for i in range(n):
            si = expected[i]
            oi = out_infos[i]

            # 3. is_dir preserved.
            check(si.is_dir() == oi.is_dir(),
                  f"{label}: is_dir mismatch at {i}: {si.filename!r} -> {oi.filename!r}")

            # 4. Payload preserved (files only).
            if not si.is_dir():
                check(zin.read(si) == zout.read(oi),
                      f"{label}: payload differs for {si.filename!r} -> {oi.filename!r}")

            # 5. Timestamp preserved.
            check(si.date_time == oi.date_time,
                  f"{label}: date_time differs for {si.filename!r}")

            # 6. Permissions/attrs preserved.
            check(si.external_attr == oi.external_attr,
                  f"{label}: external_attr differs for {si.filename!r} "
                  f"(0x{si.external_attr:x} -> 0x{oi.external_attr:x})")

            # 7. No path traversal, not absolute, no empty/./.. components.
            t = oi.filename
            check(not t.startswith("/"), f"{label}: absolute target {t!r}")
            segs = t.rstrip("/").split("/")
            check(all(s not in ("", ".", "..") for s in segs),
                  f"{label}: illegal component in target {t!r}")

            # 8. Per-component byte length within the limit.
            check(component_bytes_ok(t), f"{label}: component too long in {t!r}")

            # 9. Uniqueness (dirs tracked without trailing slash).
            key = t.rstrip("/") if oi.is_dir() else t
            check(key not in seen_targets, f"{label}: duplicate target {t!r}")
            seen_targets.add(key)

    # 10. JSON mapping is valid and complete.
    with open(out_json, "r", encoding="utf-8") as fh:
        mapping = json.load(fh)
    if isinstance(mapping, dict):
        check(len(mapping) == len(out_infos),
              f"{label}: JSON object size {len(mapping)} != output {len(out_infos)}")
        # every mapped target must exist in the output archive
        out_names = {i.filename for i in out_infos}
        for _, new in mapping.items():
            check(new in out_names or (new + "/") in out_names,
                  f"{label}: JSON target {new!r} absent from output")
    else:
        check(len(mapping) == len(out_infos),
              f"{label}: JSON list size {len(mapping)} != output {len(out_infos)}")

    # 11. Extraction stays contained (no file escapes the extraction root).
    tmp = tempfile.mkdtemp(prefix="extract_")
    try:
        with zipfile.ZipFile(out_zip, "r") as zout:
            zout.extractall(tmp)
        root = os.path.realpath(tmp)
        for dirpath, _dirs, files in os.walk(tmp):
            for f in files:
                real = os.path.realpath(os.path.join(dirpath, f))
                check(real.startswith(root + os.sep),
                      f"{label}: extracted file escaped root: {real}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# ---- run helper -------------------------------------------------------------

def run(args, env=None, cwd=None):
    return subprocess.run(
        [sys.executable, SCRIPT] + args,
        capture_output=True, text=True, env=env, cwd=cwd,
    )


# ---- the actual tests -------------------------------------------------------

def main():
    work = tempfile.mkdtemp(prefix="ziptests_")
    print(f"work dir: {work}\n")

    # Build all archives.
    corpus = os.path.join(work, "corpus.zip")
    traversal = os.path.join(work, "traversal.zip")
    dups = os.path.join(work, "dups.zip")
    collnorm = os.path.join(work, "collnorm.zip")
    empty = os.path.join(work, "empty.zip")
    build_corpus(corpus)
    build_traversal(traversal)
    build_duplicates(dups)
    build_collide_by_norm(collnorm)
    build_empty(empty)

    # --- functional runs on each archive ---
    for src, name in [(corpus, "corpus"), (traversal, "traversal"),
                      (dups, "dups"), (collnorm, "collnorm")]:
        r = run([src, "-o", os.path.join(work, name + "-out.zip"),
                 "--json", os.path.join(work, name + "-out.json")])
        check(r.returncode == 0, f"{name}: exit code {r.returncode}\n{r.stderr}")
        validate(src, os.path.join(work, name + "-out.zip"),
                 os.path.join(work, name + "-out.json"), name)

    # --- dotfile correctness: '.bashrc' must hash the whole name, no empty hash ---
    import hashlib
    expect_bashrc = hashlib.md5(".bashrc".encode()).hexdigest()
    empty_hash = hashlib.md5(b"").hexdigest()
    with open(os.path.join(work, "corpus-out.json"), encoding="utf-8") as fh:
        cmap = json.load(fh)
    got = cmap.get(".bashrc")
    check(got == expect_bashrc,
          f"dotfile: '.bashrc' -> {got!r}, expected {expect_bashrc!r}")
    check(got != empty_hash and not str(got).startswith(empty_hash),
          f"dotfile: '.bashrc' collapsed to empty-hash bug: {got!r}")

    # --- boundary: 250-byte component kept verbatim, 251-byte component hashed ---
    kept250 = cmap.get(("b" * 250) + "/f.txt")
    check(kept250 is not None and kept250.startswith(("b" * 250) + "/"),
          f"boundary: 250-byte component should be kept verbatim, got {kept250!r:.60}")
    hashed251 = cmap.get(("c" * 251) + "/g.txt")
    first_comp = hashed251.split("/", 1)[0] if hashed251 else ""
    check(len(first_comp) == 32 and set(first_comp) != {"c"},
          f"boundary: 251-byte component should be hashed, got {first_comp!r:.60}")

    # --- pathological extension: base hashed, huge extension dropped ---
    huge = cmap.get("ext/huge." + ("z" * 300))
    huge_name = huge.rsplit("/", 1)[-1] if huge else ""
    check(len(huge_name) == 32 and "z" not in huge_name,
          f"huge ext: expected 32-char hashed name with no extension, got {huge_name!r:.60}")

    # --- duplicates: JSON must be a list, both payloads distinct and present ---
    with open(os.path.join(work, "dups-out.json"), encoding="utf-8") as fh:
        dmap = json.load(fh)
    check(isinstance(dmap, list), "dups: JSON should be a list when names duplicate")
    with zipfile.ZipFile(os.path.join(work, "dups-out.zip")) as z:
        payloads = {z.read(i) for i in z.infolist()}
    check({b"first copy", b"second copy", b"nested first", b"nested second"} <= payloads,
          "dups: not all distinct payloads survived")

    # --- collision-by-normalization: two entries, two distinct targets ---
    with zipfile.ZipFile(os.path.join(work, "collnorm-out.zip")) as z:
        names = [i.filename for i in z.infolist()]
    check(len(names) == 2 and len(set(names)) == 2,
          f"collnorm: expected 2 distinct targets, got {names}")

    # --- dry-run must not create files and must exit 0 ---
    dr_out = os.path.join(work, "dryrun-out.zip")
    dr_json = os.path.join(work, "dryrun-out.json")
    r = run([corpus, "-o", dr_out, "--json", dr_json, "--dry-run"])
    check(r.returncode == 0, f"dry-run: exit {r.returncode}")
    check(not os.path.exists(dr_out) and not os.path.exists(dr_json),
          "dry-run: must not create output files")
    check("original -> nouveau" in r.stdout or "original" in r.stdout,
          "dry-run: expected mapping printout")

    # --- error handling: missing file -> exit 2 ---
    r = run([os.path.join(work, "nope.zip")])
    check(r.returncode == 2, f"missing file: expected exit 2, got {r.returncode}")

    # --- error handling: existing output without --force -> exit 2 ---
    r = run([corpus, "-o", os.path.join(work, "corpus-out.zip"),
             "--json", os.path.join(work, "corpus-out.json")])
    check(r.returncode == 2, f"clobber guard: expected exit 2, got {r.returncode}")
    # ... and with --force it succeeds
    r = run([corpus, "-o", os.path.join(work, "corpus-out.zip"),
             "--json", os.path.join(work, "corpus-out.json"), "--force"])
    check(r.returncode == 0, f"--force: expected exit 0, got {r.returncode}")

    # --- error handling: not a zip -> exit 1 ---
    notzip = os.path.join(work, "notzip.zip")
    with open(notzip, "w") as fh:
        fh.write("this is definitely not a zip archive")
    r = run([notzip])
    check(r.returncode == 1, f"bad zip: expected exit 1, got {r.returncode}")

    # --- empty archive -> exit 0, valid empty output ---
    r = run([empty, "-o", os.path.join(work, "empty-out.zip"),
             "--json", os.path.join(work, "empty-out.json")])
    check(r.returncode == 0, f"empty archive: exit {r.returncode}")
    with zipfile.ZipFile(os.path.join(work, "empty-out.zip")) as z:
        check(len(z.infolist()) == 0, "empty archive: output should be empty")

    # --- LOCALE INDEPENDENCE: identical output names across locale settings ---
    # Only locales actually installed here (C.utf8 / POSIX), plus a run that
    # forces a NON-UTF-8 default filesystem encoding via PYTHONUTF8=0 + LANG=C.
    # The Bash original was sensitive to LC_ALL (iconv, ${#var}); the Python
    # version reads names from the ZIP central directory and encodes explicitly,
    # so every configuration must yield byte-identical output names.
    reference_names = None
    scenarios = [
        {"LC_ALL": "C", "LANG": "C"},
        {"LC_ALL": "POSIX", "LANG": "POSIX"},
        {"LC_ALL": "C.utf8", "LANG": "C.utf8"},
        {"LC_ALL": "C", "LANG": "C", "PYTHONUTF8": "0"},
    ]
    for idx, overrides in enumerate(scenarios):
        env = dict(os.environ)
        env.update(overrides)
        outp = os.path.join(work, f"loc-{idx}.zip")
        jsonp = os.path.join(work, f"loc-{idx}.json")
        r = run([corpus, "-o", outp, "--json", jsonp, "--force"], env=env)
        check(r.returncode == 0, f"locale {overrides}: exit {r.returncode}\n{r.stderr}")
        if r.returncode != 0:
            continue
        with zipfile.ZipFile(outp) as z:
            names = [i.filename for i in z.infolist()]
        if reference_names is None:
            reference_names = names
        else:
            check(names == reference_names,
                  f"locale {overrides}: output names differ from reference")

    # --- summary ---
    print(f"\n==== {PASSED} passed, {FAILED} failed ====")
    if FAILED:
        print("\nFailures:")
        for m in FAILURES:
            print("  -", m)
    shutil.rmtree(work, ignore_errors=True)
    return 1 if FAILED else 0


if __name__ == "__main__":
    sys.exit(main())
