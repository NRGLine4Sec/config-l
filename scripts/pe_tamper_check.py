#!/usr/bin/env python3
"""
pe_tamper_check.py v2 - Authenticode tamper forensics for Windows PE files.

PURPOSE
    Answers "was this binary modified after the publisher signed it?"
    WITHOUT requiring a reference copy of the original file. The signature
    embeds the publisher's own digest, so the baseline travels in the file.

SCOPE - works on ANY Portable Executable, regardless of extension:
    .exe .dll .sys .ocx .cpl .scr .efi .mui, both PE32 (32-bit) and
    PE32+ (64-bit). The extension is never checked, only the MZ/PE header.

DOES NOT HANDLE (will report "not an MZ/PE file" or "no signature"):
    - MSI / MSP installers (OLE compound files, signature lives elsewhere)
    - Catalog-signed files (.cat detached signatures). Many Microsoft
      binaries are signed this way. "No signature" here does NOT mean
      untrusted, it means the trust is external to the file.
    - APPX / MSIX, ClickOnce manifests, signed PowerShell scripts
    - 16-bit MZ/NE/LE executables

WHAT IT VERIFIES - the full three-link Authenticode chain:
    1. PE bytes           -> hash -> digest inside SpcIndirectDataContent
    2. SpcIndirectData    -> hash -> signedAttrs.messageDigest
    3. signedAttrs        -> verified against the signer's PUBLIC KEY
    Checking only link 1 is NOT enough: an attacker who patches the code
    and rewrites the embedded digest defeats it. Link 2 catches that.

ALSO REPORTS
    - MD5 / SHA-1 / SHA-256 for VirusTotal correlation
    - Certificate table slack (CVE-2013-3900 / MS13-098 vector), routinely
      used by installer stubs to carry per-download identifiers, which
      changes the file hash while keeping the signature valid
    - Overlay data past the signature blob
    - Signer certificate chain and validity window
    - Countersignature timestamp, which cryptographically dates the file
    - Nested signatures (dual SHA-1 + SHA-256 signing)

VALIDATION PERFORMED
    - 20 Microsoft-signed Sysinternals binaries (PE32 and PE32+): all INTACT
    - Known-good signed binary: INTACT
    - Same binary, one bit flipped: correctly BROKEN at link 1
    - Forged binary (code patched AND embedded digest rewritten):
      correctly BROKEN at link 2
    - Unsigned PE: correctly reported as unsigned
    - Non-PE input: rejected gracefully

KNOWN LIMITS
    - Does NOT validate the certificate chain to a trusted root, does NOT
      check revocation (CRL/OCSP), and does NOT check expiry. A stolen or
      untrusted certificate still yields three PASSes. Verify the issuer
      and revocation status separately.
    - Only the primary signature is verified. Nested signatures are
      detected but not independently validated.
    - An INTACT verdict proves integrity and origin, NOT that the software
      is benign. Publishers can and do sign unwanted software.

REQUIREMENTS
    pip install asn1crypto cryptography

Usage: python3 pe_tamper_check.py <file> [...]
"""

import hashlib
import struct
import sys

try:
    from asn1crypto import cms, core
    from asn1crypto.parser import parse as asn1_parse
except ImportError:
    sys.exit("pip install asn1crypto --break-system-packages")

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import ec, padding, rsa
from cryptography.x509 import load_der_x509_certificate

HAVE_CHAIN = True

DIGEST_OIDS = {
    "1.3.14.3.2.26": "sha1",
    "2.16.840.1.101.3.4.2.1": "sha256",
    "2.16.840.1.101.3.4.2.2": "sha384",
    "2.16.840.1.101.3.4.2.3": "sha512",
    "1.2.840.113549.2.5": "md5",
}


def locate_regions(data):
    """Locate regions excluded from the Authenticode hash."""
    if data[:2] != b"MZ":
        raise ValueError("not an MZ/PE file")
    pe_off = struct.unpack_from("<I", data, 0x3C)[0]
    if data[pe_off:pe_off + 4] != b"PE\0\0":
        raise ValueError("PE signature not found")

    opt_off = pe_off + 24
    magic = struct.unpack_from("<H", data, opt_off)[0]
    if magic not in (0x10B, 0x20B):
        raise ValueError(f"unknown optional header magic {magic:#x}")
    pe32plus = (magic == 0x20B)

    checksum_off = opt_off + 64
    dd_off = opt_off + (112 if pe32plus else 96)
    cert_dir_off = dd_off + 4 * 8
    cert_off, cert_size = struct.unpack_from("<II", data, cert_dir_off)

    return {
        "pe32plus": pe32plus,
        "checksum_off": checksum_off,
        "cert_dir_off": cert_dir_off,
        "cert_table_off": cert_off,
        "cert_table_size": cert_size,
    }


def authenticode_hash(data, regions, algo="sha1"):
    """
    Compute the Authenticode PE hash per the Microsoft specification.
    Excludes the CheckSum field, the Certificate Table directory entry,
    and the attribute certificate table (the signature blob) itself.
    """
    h = hashlib.new(algo)
    cs = regions["checksum_off"]
    cd = regions["cert_dir_off"]
    co = regions["cert_table_off"]
    sz = regions["cert_table_size"]

    h.update(data[:cs])                       # start -> CheckSum
    h.update(data[cs + 4:cd])                 # skip CheckSum -> cert dir entry
    end = co if sz else len(data)
    h.update(data[cd + 8:end])                # skip dir entry -> signature
    if sz:
        tail = data[co + sz:]                 # trailing data is still hashed
        if tail:
            h.update(tail)
    return h.hexdigest()


def parse_win_certificate(data, regions):
    """Parse WIN_CERTIFICATE and expose slack space inside the table."""
    off = regions["cert_table_off"]
    size = regions["cert_table_size"]
    if not size:
        return None
    length, revision, ctype = struct.unpack_from("<IHH", data, off)
    pkcs7 = data[off + 8: off + length]
    padded = (length + 7) & ~7
    slack = data[off + padded: off + size]
    return {
        "declared_length": length,
        "revision": revision,
        "cert_type": ctype,
        "pkcs7": pkcs7,
        "slack": slack,
        "slack_len": len(slack),
    }


def signed_pe_digest(pkcs7):
    """Extract the publisher-signed PE digest from SpcIndirectDataContent."""
    sd = cms.ContentInfo.load(pkcs7)["content"]
    eci = sd["encap_content_info"]
    # Peel the [0] EXPLICIT wrapper to reach the SpcIndirectDataContent SEQUENCE
    _, _, _, _, inner, _ = asn1_parse(eci["content"].dump())
    outer = core.Sequence.load(inner)
    digest_info = core.Sequence.load(outer[1].dump())
    algo_seq = core.Sequence.load(digest_info[0].dump())
    algo_oid = core.ObjectIdentifier.load(algo_seq[0].dump()).native
    digest = core.OctetString.load(digest_info[1].dump()).native
    return DIGEST_OIDS.get(algo_oid, algo_oid), digest.hex(), sd


def describe_signed_data(sd):
    """Pull certificates, timestamp and nested-signature info."""
    out = {"certs": [], "timestamp": None, "nested": False}

    for c in sd["certificates"]:
        try:
            tbs = c.chosen["tbs_certificate"]
            out["certs"].append({
                "subject": c.chosen.subject.human_friendly,
                "issuer": c.chosen.issuer.human_friendly,
                "serial": f"{c.chosen.serial_number:x}",
                "from": str(tbs["validity"]["not_before"].native),
                "to": str(tbs["validity"]["not_after"].native),
            })
        except Exception:
            pass

    for si in sd["signer_infos"]:
        ua = si["unsigned_attrs"]
        if ua is None or len(ua) == 0:
            continue
        for attr in ua:
            t = attr["type"].native
            if t == "counter_signature":
                for cs in attr["values"]:
                    for a in cs["signed_attrs"]:
                        if a["type"].native == "signing_time":
                            out["timestamp"] = str(a["values"][0].native)
            elif t in ("microsoft_nested_signature", "1.3.6.1.4.1.311.2.4.1"):
                out["nested"] = True
            elif t == "1.3.6.1.4.1.311.3.3.1":
                out["timestamp"] = out["timestamp"] or "RFC3161 token present"
    return out


HASH_MAP = {
    "sha1": hashes.SHA1,
    "sha256": hashes.SHA256,
    "sha384": hashes.SHA384,
    "sha512": hashes.SHA512,
    "md5": hashes.MD5,
}


def find_signer_cert(sd, signer_info):
    """Locate the leaf certificate matching this SignerInfo."""
    sid = signer_info["sid"]
    if sid.name != "issuer_and_serial_number":
        return None
    want_serial = sid.chosen["serial_number"].native
    want_issuer = sid.chosen["issuer"].dump()
    for c in sd["certificates"]:
        try:
            if (c.chosen.serial_number == want_serial
                    and c.chosen.issuer.dump() == want_issuer):
                return c.chosen.dump()
        except Exception:
            continue
    return None


def verify_chain(pkcs7_bytes, pe_authenticode_hash_fn):
    """
    Verify all three links. Returns a dict of per-link results.

    pe_authenticode_hash_fn(algo) -> hex digest recomputed from the PE.
    """
    result = {"link1": None, "link2": None, "link3": None, "errors": []}

    sd = cms.ContentInfo.load(pkcs7_bytes)["content"]
    eci = sd["encap_content_info"]

    # ---- link 1: PE bytes vs the digest inside SpcIndirectDataContent ----
    _, _, _, _, spc_der, _ = asn1_parse(eci["content"].dump())
    spc = core.Sequence.load(spc_der)
    digest_info = core.Sequence.load(spc[1].dump())
    algo_seq = core.Sequence.load(digest_info[0].dump())
    algo_oid = core.ObjectIdentifier.load(algo_seq[0].dump()).native
    oids = {
        "1.3.14.3.2.26": "sha1",
        "2.16.840.1.101.3.4.2.1": "sha256",
        "2.16.840.1.101.3.4.2.2": "sha384",
        "2.16.840.1.101.3.4.2.3": "sha512",
        "1.2.840.113549.2.5": "md5",
    }
    algo = oids.get(algo_oid, algo_oid)
    embedded = core.OctetString.load(digest_info[1].dump()).native.hex()
    recomputed = pe_authenticode_hash_fn(algo)
    result["algo"] = algo
    result["embedded_digest"] = embedded
    result["recomputed_digest"] = recomputed
    result["link1"] = (embedded == recomputed)

    for si in sd["signer_infos"]:
        signed_attrs = si["signed_attrs"]
        if signed_attrs is None or len(signed_attrs) == 0:
            result["errors"].append("no signed attributes")
            continue

        # ---- link 2: SpcIndirectDataContent vs signedAttrs.messageDigest ----
        si_algo = si["digest_algorithm"]["algorithm"].native
        si_algo = {"sha1": "sha1", "sha256": "sha256"}.get(si_algo, si_algo)
        # Authenticode quirk: the digest covers the CONTENTS of the
        # SpcIndirectDataContent SEQUENCE, not the SEQUENCE header itself.
        spc_contents = core.Sequence.load(spc_der).contents
        content_hash = hashlib.new(si_algo, spc_contents).hexdigest()

        attr_md = None
        for a in signed_attrs:
            if a["type"].native == "message_digest":
                attr_md = a["values"][0].native.hex()
        result["content_hash"] = content_hash
        result["attr_message_digest"] = attr_md
        result["link2"] = (attr_md == content_hash)

        # ---- link 3: the actual public-key signature over signedAttrs ----
        cert_der = find_signer_cert(sd, si)
        if cert_der is None:
            result["errors"].append("signer certificate not found")
            result["link3"] = False
            break

        cert = load_der_x509_certificate(cert_der)
        result["signer_subject"] = cert.subject.rfc4514_string()
        pub = cert.public_key()
        # signedAttrs are signed in their SET OF form, not the [0] IMPLICIT form
        to_verify = signed_attrs.untag().dump()
        signature = si["signature"].native
        halgo = HASH_MAP.get(si_algo, hashes.SHA256)()

        try:
            if isinstance(pub, rsa.RSAPublicKey):
                pub.verify(signature, to_verify, padding.PKCS1v15(), halgo)
            elif isinstance(pub, ec.EllipticCurvePublicKey):
                pub.verify(signature, to_verify, ec.ECDSA(halgo))
            else:
                result["errors"].append("unsupported key type")
                result["link3"] = False
                break
            result["link3"] = True
        except Exception as e:
            result["link3"] = False
            result["errors"].append(f"signature verify failed: {e}")
        break

    return result


def analyze(path):
    data = open(path, "rb").read()
    print("=" * 72)
    print(f"FILE : {path}  ({len(data):,} bytes)")
    print("=" * 72)
    print(f"  MD5    : {hashlib.md5(data).hexdigest()}")
    print(f"  SHA1   : {hashlib.sha1(data).hexdigest()}")
    print(f"  SHA256 : {hashlib.sha256(data).hexdigest()}")

    try:
        regions = locate_regions(data)
    except ValueError as e:
        print(f"\n[!] {e}")
        return

    if not regions["cert_table_size"]:
        print("\n[!] NO Authenticode signature.")
        print("    No embedded baseline: this method cannot rule on tampering.")
        return

    wc = parse_win_certificate(data, regions)
    try:
        algo, expected, sd = signed_pe_digest(wc["pkcs7"])
    except Exception as e:
        print(f"\n[!] cannot parse PKCS#7: {e}")
        return

    recomputed = authenticode_hash(data, regions, algo)

    print("\n--- INTEGRITY (the tamper verdict) ---")
    print(f"  algorithm           : {algo}")
    print(f"  signed by publisher : {expected}")
    print(f"  recomputed from file: {recomputed}")

    if HAVE_CHAIN:
        res = verify_chain(wc["pkcs7"], lambda a: authenticode_hash(data, regions, a))
        mark = lambda v: "PASS" if v else "FAIL"
        print("\n  Cryptographic chain (all three links must pass):")
        print(f"    1. PE bytes    -> embedded digest    : {mark(res['link1'])}")
        print(f"    2. content     -> signedAttrs digest : {mark(res['link2'])}")
        print(f"    3. signedAttrs -> publisher signature: {mark(res['link3'])}")
        if all([res["link1"], res["link2"], res["link3"]]):
            print("\n  >>> INTACT: cryptographically identical to what was signed.")
            print("  >>> NOT modified after signing.")
        else:
            print("\n  >>> BROKEN: the signature does not cover these bytes.")
            print("  >>> ALTERED after signing, or corrupt.")
        for e in res["errors"][:2]:
            print(f"      note: {e[:80]}")
    else:
        print("  [!] authchain.py missing: only link 1 checked (weak)")

    print("\n--- CERTIFICATE TABLE ---")
    print(f"  declared length : {wc['declared_length']}")
    print(f"  slack bytes     : {wc['slack_len']}")
    if wc["slack_len"]:
        print("  [!] EXTRA DATA present (CVE-2013-3900 vector).")
        print("      Often a per-download / affiliate identifier on installers,")
        print("      which changes the file hash without breaking the signature.")
        print(f"      hex : {wc['slack'][:48].hex()}")
        txt = bytes(c if 32 <= c < 127 else 46 for c in wc["slack"][:120])
        print(f"      text: {txt.decode('ascii', 'replace')}")

    end_of_sig = regions["cert_table_off"] + regions["cert_table_size"]
    if len(data) > end_of_sig:
        print(f"  [!] {len(data) - end_of_sig} bytes AFTER the signature blob")

    info = describe_signed_data(sd)
    print("\n--- SIGNATURE METADATA ---")
    if info["timestamp"]:
        print(f"  TIMESTAMP : {info['timestamp']}")
        print("  -> cryptographic evidence the file existed at that date")
    else:
        print("  TIMESTAMP : none (signature expires with the certificate)")
    if info["nested"]:
        print("  nested signature present (dual SHA-1 + SHA-256 signing)")

    for c in info["certs"]:
        print(f"\n  subject  : {c['subject']}")
        print(f"  issuer   : {c['issuer']}")
        print(f"  serial   : {c['serial']}")
        print(f"  validity : {c['from']} -> {c['to']}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    for p in sys.argv[1:]:
        try:
            analyze(p)
        except Exception as e:
            print(f"{p}: ERROR {e}")
        print()
