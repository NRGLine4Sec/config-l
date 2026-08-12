#!/usr/bin/env python3
"""
kvm-inventory.py - list the KVM virtual machines currently live on this host,
and identify which VMM runs each of them.

Detection order, cheapest first:

  1. debugfs (/sys/kernel/debug/kvm/<pid>-<vmfd>): the kernel already keeps one
     directory per VM. Cost is O(number of VMs), not O(number of open fds).
  2. procfs fallback (/proc/<pid>/fd): only used when debugfs is unavailable, or
     when --full is given. Single process, one readlink() per fd, no subprocess.

VMM identification never trusts the process name. It uses, in order:

  a. mapped shared objects (/proc/<pid>/maps): catches library VMMs such as
     libkrun, where the hypervisor lives inside the caller's own process and no
     separate hypervisor process exists at all.
  b. the resolved executable (/proc/<pid>/exe): survives wrappers, symlinks and
     nix store paths.
  c. argv[0] as a last resort when exe is unreadable.

Usage:
    sudo ./kvm-inventory.py            # debugfs, fall back to procfs if needed
    sudo ./kvm-inventory.py --full     # force the procfs scan as well
    sudo ./kvm-inventory.py --json

Environment overrides PROC and DEBUGFS allow testing against a synthetic tree.
"""

import argparse
import json
import os
import re
import stat
import sys
import time

PROC = os.environ.get("PROC", "/proc")
DEBUGFS = os.environ.get("DEBUGFS", "/sys/kernel/debug/kvm")

VM_LINK = "anon_inode:kvm-vm"
VCPU_PREFIX = "anon_inode:kvm-vcpu"
KVM_DEV = "/dev/kvm"

# Library VMMs: the hypervisor is linked into the host process, so there is no
# VMM process to find. Matched against the basenames of mapped files, in this
# order, so that the VMM library wins over the guest-kernel payload library and
# the reported version is stable across runs.
LIB_SIGNATURES = (
    ("libkrun.so", "libkrun"),
    ("libkrun-", "libkrun"),
    ("libkrunfw", "libkrun"),
    ("libwhp", "WHP"),
)

# Standalone VMM binaries, matched as substrings of the executable basename.
# Order matters: the most specific patterns come first.
EXE_SIGNATURES = (
    ("qemu-system", "QEMU"),
    ("qemu-kvm", "QEMU"),
    ("cloud-hypervisor", "Cloud Hypervisor"),
    ("ch-remote", "Cloud Hypervisor"),
    ("firecracker", "Firecracker"),
    ("jailer", "Firecracker"),
    ("crosvm", "crosvm"),
    ("kvmtool", "kvmtool"),
    ("lkvm", "kvmtool"),
    ("vmm-reference", "rust-vmm"),
    ("libkrun", "libkrun"),
)

NIX_STORE_RE = re.compile(r"/nix/store/[a-z0-9]{32}-(?P<name>.+?)(?:-(?P<ver>[0-9][^/]*))?/")
SO_VERSION_RE = re.compile(r"\.so(?:\.(?P<ver>[0-9][0-9.]*))?$")

# State directory layouts used by VMM front-ends, e.g.
# ~/.cache/smolvm/vms/<id>/boot-config.json
VM_ID_PATH_RE = re.compile(r"/(?:vms|machines|instances|sandboxes)/(?P<id>[^/]+)/")

# Keys worth trying when a VMM is handed a JSON configuration file. The schema
# is not standardised, so this is best effort and the path-derived id remains
# the guaranteed identifier.
CONFIG_NAME_KEYS = ("name", "vm_name", "machine_name", "vmName", "hostname",
                    "host_name", "id", "vm_id")


def read_bytes(path, limit=None):
    try:
        with open(path, "rb") as fh:
            return fh.read() if limit is None else fh.read(limit)
    except OSError:
        return b""


def proc_info(pid):
    """Collect the descriptive fields for one pid. Cheap: a few small reads."""
    info = {"pid": int(pid), "ppid": None, "uid": None, "rss_kb": None,
            "comm": None, "cmdline": None, "argv": [], "threads": None,
            "exe": None}

    status = read_bytes(f"{PROC}/{pid}/status").decode("utf-8", "replace")
    for line in status.splitlines():
        if line.startswith("PPid:"):
            info["ppid"] = int(line.split()[1])
        elif line.startswith("Uid:"):
            info["uid"] = int(line.split()[1])
        elif line.startswith("VmRSS:"):
            info["rss_kb"] = int(line.split()[1])
        elif line.startswith("Threads:"):
            info["threads"] = int(line.split()[1])

    info["comm"] = read_bytes(f"{PROC}/{pid}/comm").decode(
        "utf-8", "replace").strip() or None

    raw = read_bytes(f"{PROC}/{pid}/cmdline")
    argv = [a for a in raw.decode("utf-8", "replace").split("\x00") if a]
    info["argv"] = argv
    info["cmdline"] = " ".join(argv) or None

    try:
        info["exe"] = os.readlink(f"{PROC}/{pid}/exe")
    except OSError:
        info["exe"] = None

    return info


def mapped_files(pid, max_lines=20000):
    """Unique file paths mapped by the process, from /proc/<pid>/maps."""
    paths = set()
    try:
        with open(f"{PROC}/{pid}/maps", "r", errors="replace") as fh:
            for n, line in enumerate(fh):
                if n > max_lines:
                    break
                parts = line.rstrip("\n").split(None, 5)
                if len(parts) == 6 and parts[5].startswith("/"):
                    paths.add(parts[5])
    except OSError:
        pass
    return paths


def nix_package(path):
    """Return (derivation_name, version) for a nix store path, else (None, None).

    Note that the derivation the file lives in is not necessarily the project
    the file belongs to. A vendored library sits in its parent's store path, so
    the caller must check the name before trusting the version.
    """
    if not path:
        return None, None
    m = NIX_STORE_RE.search(path if path.endswith("/") else path + "/")
    if not m:
        return None, None
    return m.group("name"), m.group("ver")


def soname_version(basename):
    """Version carried by the soname itself, e.g. libkrun.so.5.5.0 -> 5.5.0."""
    m = SO_VERSION_RE.search(basename)
    return m.group("ver") if m and m.group("ver") else None


def fit(value, width):
    """Pad to width, truncating with an ellipsis so columns never overflow."""
    s = "-" if value in (None, "") else str(value)
    if len(s) >= width:
        s = s[:max(1, width - 2)] + "~"
    return s.ljust(width)


def state_dir_from_argv(argv):
    """Locate the VM state directory referenced on the command line.

    The file passed as an argument may already be gone (smolvm deletes its
    boot config once the guest is up), so the directory is derived from the
    path string and only then checked on disk.
    """
    for arg in argv:
        if not arg.startswith("/"):
            continue
        m = VM_ID_PATH_RE.search(arg)
        if m:
            end = m.end()
            return arg[:end].rstrip("/"), m.group("id")
    for arg in argv:
        if arg.startswith("/") and arg.endswith(".json"):
            d = os.path.dirname(arg)
            return d, os.path.basename(d)
    return None, None


def read_small(path, limit=4096):
    """Read a small regular file, or return None. Never blocks on a fifo."""
    try:
        st = os.stat(path)
        if not stat.S_ISREG(st.st_mode) or st.st_size > limit:
            return None
        with open(path, "rb") as fh:
            return fh.read(limit).decode("utf-8", "replace").strip() or None
    except OSError:
        return None


def state_identity(argv, max_json=262144, max_files=32):
    """Pull the readable name and the declared resources out of the VM state
    directory. The directory id is the guaranteed identifier, everything else
    is best effort and stays empty when unavailable.
    """
    out = {"guest_name": None, "guest_id": None, "guest_state_dir": None,
           "guest_name_source": None, "cfg_cpus": None, "cfg_mem_mib": None}

    sdir, vid = state_dir_from_argv(argv)
    out["guest_id"] = vid
    if not sdir or not os.path.isdir(sdir):
        return out
    out["guest_state_dir"] = sdir

    # 1. a plain text file holding the name, the cheapest and most reliable
    for candidate in ("name", "vm-name", "hostname"):
        val = read_small(os.path.join(sdir, candidate))
        if val and "\n" not in val:
            out["guest_name"], out["guest_name_source"] = val, candidate
            break

    # 2. any JSON in the directory, for the name and the declared resources
    try:
        entries = sorted(e for e in os.listdir(sdir) if e.endswith(".json"))
    except OSError:
        entries = []

    for entry in entries[:max_files]:
        path = os.path.join(sdir, entry)
        try:
            st = os.stat(path)
            if not stat.S_ISREG(st.st_mode) or st.st_size > max_json:
                continue
            with open(path, "rb") as fh:
                data = json.loads(fh.read(max_json).decode("utf-8", "replace"))
        except (OSError, ValueError):
            continue
        if not isinstance(data, dict):
            continue
        if out["guest_name"] is None:
            found = search_name(data)
            if found:
                out["guest_name"], out["guest_name_source"] = found, entry
        res = data.get("resources")
        if isinstance(res, dict):
            if out["cfg_cpus"] is None and isinstance(res.get("cpus"), int):
                out["cfg_cpus"] = res["cpus"]
            if out["cfg_mem_mib"] is None and isinstance(res.get("memory_mib"), int):
                out["cfg_mem_mib"] = res["memory_mib"]

    return out


def search_name(data, depth=0):
    """Look for a plausible name key at the top level, then one level down."""
    if not isinstance(data, dict) or depth > 1:
        return None
    for key in CONFIG_NAME_KEYS:
        val = data.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    for val in data.values():
        if isinstance(val, dict):
            found = search_name(val, depth + 1)
            if found:
                return found
    return None


def guest_name(argv, vmm):
    """Best-effort extraction of the guest / instance name from the argv."""
    if not argv:
        return None

    def value_after(flags):
        for i, a in enumerate(argv):
            if a in flags and i + 1 < len(argv):
                return argv[i + 1]
            for f in flags:
                if a.startswith(f + "="):
                    return a.split("=", 1)[1]
        return None

    if vmm == "QEMU":
        v = value_after(("-name", "--name"))
        if v:
            # forms: "myvm", "guest=myvm,debug-threads=on"
            v = v.split(",")[0]
            if v.startswith("guest="):
                v = v[len("guest="):]
            return v
    if vmm == "Firecracker":
        v = value_after(("--id",))
        if v:
            return v
    if vmm in ("Cloud Hypervisor", "crosvm"):
        # No instance name exists, the control socket is the usual identifier.
        v = value_after(("--api-socket", "--socket", "-s"))
        if v:
            return os.path.basename(v)
    v = value_after(("--name", "-name"))
    if v:
        return v.split(",")[0]
    return None


def machine_type(argv, vmm):
    """QEMU machine model, which distinguishes a microVM from a full board."""
    if vmm != "QEMU" or not argv:
        return None
    for i, a in enumerate(argv):
        if a in ("-M", "-machine", "--machine") and i + 1 < len(argv):
            return argv[i + 1].split(",")[0]
        if a.startswith("-machine="):
            return a.split("=", 1)[1].split(",")[0]
    return None


def detect_vmm(pid, info):
    """Identify the VMM behind a live VM.

    Returns a dict. Version is only reported when it can be established from
    the soname, or from a nix derivation whose own name matches the library.
    A version read from an unrelated parent derivation would be a lie, so it
    is discarded rather than displayed.
    """
    out = {"vmm": "unknown", "version": None, "version_source": None,
           "embedded_in": None, "payload": None, "derivation": None,
           "evidence": None}

    # a. library VMM linked into the host process. Signature order is the
    # priority order, and paths are sorted, so the result is deterministic.
    paths = sorted(mapped_files(pid))
    primary = None
    for pattern, name in LIB_SIGNATURES:
        for path in paths:
            if os.path.basename(path).startswith(pattern):
                primary, out["vmm"] = path, name
                break
        if primary:
            break

    if primary:
        base = os.path.basename(primary)
        out["evidence"] = primary
        out["embedded_in"] = (os.path.basename(info.get("exe") or "")
                              or info.get("comm"))
        ver = soname_version(base)
        if ver:
            out["version"], out["version_source"] = ver, "soname"
        else:
            deriv, dver = nix_package(primary)
            out["derivation"] = deriv
            # Only trust the derivation version if the derivation is the
            # library itself, not a parent that merely vendors it.
            token = base.split(".so")[0]
            if deriv and dver and token.lower() in deriv.lower():
                out["version"], out["version_source"] = dver, "nix"

        # Guest kernel payload, informative but distinct from the VMM version.
        for path in paths:
            b = os.path.basename(path)
            if b.startswith("libkrunfw"):
                pv = soname_version(b)
                out["payload"] = f"libkrunfw {pv}" if pv else "libkrunfw"
                break
        return out

    # b. resolved executable
    exe = info.get("exe")
    if exe:
        base = os.path.basename(exe)
        for pattern, name in EXE_SIGNATURES:
            if pattern in base:
                deriv, dver = nix_package(exe)
                out.update(vmm=name, derivation=deriv, evidence=exe)
                if dver:
                    out["version"], out["version_source"] = dver, "nix"
                return out

    # c. argv[0], last resort
    argv0 = os.path.basename(info["argv"][0]) if info.get("argv") else ""
    for pattern, name in EXE_SIGNATURES:
        if pattern in argv0:
            out.update(vmm=name, evidence=f"argv[0]={argv0}")
            return out

    return out


def from_debugfs():
    """Enumerate VMs from the per-VM debugfs directories. O(number of VMs)."""
    vms = {}
    try:
        entries = os.listdir(DEBUGFS)
    except OSError as exc:
        return None, str(exc)

    for name in entries:
        path = os.path.join(DEBUGFS, name)
        if not os.path.isdir(path):
            continue
        # Directory name is "<pid>-<vm file descriptor>".
        pid, _, vmfd = name.partition("-")
        if not pid.isdigit():
            continue
        try:
            vcpus = len([d for d in os.listdir(path) if d.startswith("vcpu")])
        except OSError:
            vcpus = None
        rec = vms.setdefault(pid, {"vmfds": [], "vcpus": 0, "source": "debugfs"})
        rec["vmfds"].append(vmfd)
        if vcpus:
            rec["vcpus"] += vcpus
    return vms, None


def from_procfs():
    """Fallback: scan /proc/<pid>/fd for the KVM anon inodes.

    One readlink() per fd, in a single process. Counts the pids we could not
    read so an empty result is never mistaken for an absence of VMs.
    """
    vms = {}
    denied = 0
    scanned_fds = 0

    for pid in os.listdir(PROC):
        if not pid.isdigit():
            continue
        fddir = f"{PROC}/{pid}/fd"
        try:
            fds = os.listdir(fddir)
        except PermissionError:
            denied += 1
            continue
        except OSError:
            continue

        vmfds, vcpus, dev = [], 0, False
        for fd in fds:
            try:
                target = os.readlink(f"{fddir}/{fd}")
            except OSError:
                continue
            scanned_fds += 1
            if target == VM_LINK:
                vmfds.append(fd)
            elif target.startswith(VCPU_PREFIX):
                vcpus += 1
            elif target == KVM_DEV:
                dev = True

        if vmfds or dev:
            vms[pid] = {"vmfds": vmfds, "vcpus": vcpus,
                        "kvm_dev_open": dev, "source": "procfs"}

    return vms, denied, scanned_fds


def human_rss(kb):
    if kb is None:
        return "-"
    return f"{kb/1048576:.1f}G" if kb > 1048576 else f"{kb/1024:.0f}M"


def mem_cell(r):
    """Resident memory, and the declared guest size when the config gives it.

    RSS is what the host has actually backed, not what the guest was promised,
    so the two numbers legitimately differ by a lot on a freshly booted VM.
    """
    rss = human_rss(r["rss_kb"])
    if r.get("cfg_mem_mib"):
        nominal = (f"{r['cfg_mem_mib']/1024:.0f}G" if r["cfg_mem_mib"] >= 1024
                   else f"{r['cfg_mem_mib']}M")
        return f"{rss}/{nominal}"
    return rss


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--full", action="store_true",
                    help="also run the procfs scan even if debugfs answered")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--wide", action="store_true",
                    help="show ppid, uid, thread count and full command line")
    args = ap.parse_args()

    started = time.time()
    result = {}
    notes = []

    dbg, err = from_debugfs()
    if dbg is None:
        notes.append(f"debugfs unavailable ({err}), falling back to procfs")
    else:
        notes.append(f"debugfs: {len(dbg)} process(es) holding a VM")
        result.update(dbg)

    if dbg is None or args.full:
        pf, denied, nfd = from_procfs()
        notes.append(f"procfs: {nfd} fds inspected, {denied} pid(s) unreadable")
        if denied and os.geteuid() != 0:
            notes.append("not running as root, results are incomplete")
        for pid, rec in pf.items():
            if pid in result:
                result[pid].update({k: v for k, v in rec.items()
                                    if k != "source"})
                result[pid]["source"] = "debugfs+procfs"
            else:
                result[pid] = rec

    rows = []
    for pid, rec in sorted(result.items(), key=lambda kv: int(kv[0])):
        info = proc_info(pid)
        info.update(rec)
        det = detect_vmm(pid, info)
        info["vmm"] = det["vmm"]
        info["vmm_version"] = det["version"]
        info["vmm_version_source"] = det["version_source"]
        info["vmm_embedded_in"] = det["embedded_in"]
        info["vmm_payload"] = det["payload"]
        info["vmm_derivation"] = det["derivation"]
        info["vmm_evidence"] = det["evidence"]
        info["machine"] = machine_type(info["argv"], det["vmm"])
        state = state_identity(info["argv"])
        info.update(state)
        argv_name = guest_name(info["argv"], det["vmm"])
        if argv_name:
            info["guest_name"] = argv_name
            info["guest_name_source"] = "argv"
        rows.append(info)

    elapsed = time.time() - started

    if args.json:
        print(json.dumps({"vms": rows, "notes": notes,
                          "elapsed_s": round(elapsed, 3)}, indent=2))
        return 0

    for note in notes:
        print(f"# {note}")
    print(f"# elapsed: {elapsed:.3f}s")
    print()

    if not rows:
        print("No live KVM virtual machine found on this host.")
        return 0

    def vmm_cell(r):
        cell = r["vmm"]
        if r["vmm_embedded_in"]:
            cell += f" in {r['vmm_embedded_in']}"
        return cell

    def detail_cell(r, wide=False):
        bits = []
        if r["vmm_version"]:
            bits.append(f"v{r['vmm_version']}")
        elif r["vmm_payload"]:
            # No VMM version available. Show the guest kernel payload instead,
            # explicitly labelled so it is not mistaken for the VMM version.
            bits.append(r["vmm_payload"])
        if wide and r["vmm_derivation"]:
            bits.append(f"[{r['vmm_derivation']}]")
        if r["machine"]:
            bits.append(f"-M {r['machine']}")
        return " ".join(bits) or "-"

    if args.wide:
        cols = [("PID", 9), ("PPID", 9), ("UID", 6), ("VMM", 26),
                ("DETAIL", 40), ("VCPU", 6), ("THR", 5), ("RSS/MEM", 12),
                ("GUEST", 24)]
        print("".join(h.ljust(w) for h, w in cols) + "COMMAND")
        for r in rows:
            print(fit(r["pid"], 9) + fit(r["ppid"], 9) + fit(r["uid"], 6)
                  + fit(vmm_cell(r), 26) + fit(detail_cell(r, True), 40)
                  + fit(r.get("vcpus", 0), 6) + fit(r["threads"], 5)
                  + fit(mem_cell(r), 12)
                  + fit(r["guest_name"] or r["guest_id"], 24)
                  + (r["cmdline"] or "-"))
    else:
        cols = [("PID", 9), ("VMM", 26), ("DETAIL", 28), ("VCPU", 6),
                ("RSS/MEM", 12)]
        print("".join(h.ljust(w) for h, w in cols) + "GUEST")
        for r in rows:
            print(fit(r["pid"], 9) + fit(vmm_cell(r), 26)
                  + fit(detail_cell(r), 28) + fit(r.get("vcpus", 0), 6)
                  + fit(mem_cell(r), 12)
                  + (r["guest_name"] or r["guest_id"] or "-"))
    return 0


if __name__ == "__main__":
    sys.exit(main())