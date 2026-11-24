#!/usr/bin/env python3
"""Verify a vulpea-to-denote conversion: verify.py BEFORE AFTER mapping.json

BEFORE and AFTER are roots holding notes/, work-notes/ and org/. Exits
non-zero if anything other than the whitelisted edits changed:

- renames listed in the mapping
- added `#+date:` / `#+identifier:` lines in a renamed note's front matter
- `[[id:UUID` -> `[[denote:ID` for file-level UUIDs in the mapping
- file: links re-pointed from an old note name to its new one
- the `todo` tag removed from a `#+filetags:` line
"""
import difflib
import json
import os
import re
import sys
from collections import Counter

TREES = ["notes", "work-notes", "org"]
ID_DRAWER = re.compile(rb"^[ \t]*:ID:[ \t]+(\S+)", re.M)
DENOTE_LINK = re.compile(r"\[\[denote:(\d{8}T\d{6})")
ID_LINK = re.compile(r"\[\[id:([^\]\[:]+)(?=[\]:])")
NAME_ID = re.compile(r"^(\d{8}T\d{6})")

failures = []


def fail(msg):
    failures.append(msg)


def inventory(root):
    out = {}
    for t in TREES:
        for dirpath, dirnames, filenames in os.walk(os.path.join(root, t)):
            if ".stfolder" in dirpath.split(os.sep):
                continue
            for name in filenames:
                p = os.path.join(dirpath, name)
                out[os.path.relpath(p, root)] = p
    return out


def read(p):
    with open(p, "rb") as f:
        return f.read()


def text(b):
    return b.decode("utf-8", errors="surrogateescape")


def note_files(inv):
    return {rel for rel in inv if rel.endswith((".org", ".md")) and not rel.endswith("~")}


def main(before, after, mapping_path):
    with open(mapping_path) as f:
        mapping = json.load(f)
    notes = mapping["notes"]
    old2new = {n["old"]: n["new"] for n in notes}
    uuid2id = {n["uuid"]: n["id"] for n in notes if n["uuid"]}
    renames = {os.path.basename(n["old"]): os.path.basename(n["new"])
               for n in notes if n["old"] != n["new"]}

    bi, ai = inventory(before), inventory(after)

    # 1. Inventory maps 1:1.
    expected = {old2new.get(rel, rel): rel for rel in bi}
    missing = set(expected) - set(ai)
    extra = set(ai) - set(expected)
    for rel in sorted(missing):
        fail(f"missing after conversion: {rel} (was {expected[rel]})")
    for rel in sorted(extra):
        fail(f"unexpected new file: {rel}")
    print(f"files before: {len(bi)}, after: {len(ai)}, renamed: {len(renames)}")

    # 2. Content: byte-identical or only whitelisted line changes.
    identical = edited = 0
    for new_rel, old_rel in sorted(expected.items()):
        if new_rel not in ai:
            continue
        b, a = read(bi[old_rel]), read(ai[new_rel])
        if a == b:
            identical += 1
            continue
        edited += 1
        if not new_rel.endswith((".org", ".org_archive")) or new_rel.endswith("~"):
            fail(f"non-org file changed: {new_rel}")
            continue
        check_lines(old_rel, new_rel, text(b), text(a), uuid2id, renames,
                    renamed_note=old_rel in old2new and old2new[old_rel] != old_rel)
    print(f"byte-identical: {identical}, edited: {edited}")

    # 3. Every :ID: UUID survives.
    def uuids(inv):
        c = Counter()
        for p in inv.values():
            if p.endswith((".org", ".org_archive", ".org~")):
                c.update(ID_DRAWER.findall(read(p)))
        return c
    ub, ua = uuids(bi), uuids(ai)
    if ub != ua:
        fail(f":ID: drawers differ: lost {sorted((ub - ua).elements())[:10]} "
             f"gained {sorted((ua - ub).elements())[:10]}")
    print(f":ID: drawers: {sum(ub.values())} before, {sum(ua.values())} after")

    # 4. Links: no new dead denote: or id: links.
    def dead(inv):
        ids = {m.group(1) for rel in inv
               if (m := NAME_ID.match(os.path.basename(rel)))}
        all_uuids = set(uuids(inv))
        dd, di = set(), set()
        for rel, p in inv.items():
            if not rel.endswith((".org", ".org_archive")) or rel.endswith("~"):
                continue
            t = text(read(p))
            dd |= {(i) for i in DENOTE_LINK.findall(t) if i not in ids}
            di |= {u for u in ID_LINK.findall(t) if u.encode() not in all_uuids}
        return dd, di
    dd_b, di_b = dead(bi)
    dd_a, di_a = dead(ai)
    for i in sorted(dd_a - dd_b):
        fail(f"new dead denote: link {i}")
    for u in sorted(di_a - di_b):
        fail(f"new dead id: link {u}")
    print(f"dead denote: links before {len(dd_b)}, after {len(dd_a)} "
          f"(pre-existing, fix by hand: {sorted(dd_a & dd_b)})")
    print(f"dead id: links before {len(di_b)}, after {len(di_a)}")

    # 5. Renamed org notes: identifier line matches the filename.
    for n in notes:
        if n["old"] != n["new"] and n["new"].endswith(".org") and n["new"] in ai:
            t = text(read(ai[n["new"]]))
            m = re.search(r"^#\+identifier:\s*(\S+)", t, re.M)
            if not m or m.group(1) != n["id"] or not os.path.basename(n["new"]).startswith(n["id"] + "--"):
                fail(f"identifier mismatch in {n['new']}")

    if failures:
        print(f"\nFAILED: {len(failures)} problem(s)")
        for f_ in failures[:100]:
            print("  " + f_)
        sys.exit(1)
    print("\nOK: only whitelisted changes")


def normalize(line, uuid2id, renames):
    line = ID_LINK.sub(lambda m: f"[[denote:{uuid2id[m.group(1)]}" if m.group(1) in uuid2id
                       else m.group(0), line)
    for old, new in renames.items():
        line = line.replace(old, new)
    if re.match(r"#\+filetags:", line, re.I):
        line = re.sub(r":todo(?=:)", "", line, flags=re.I)
        line = re.sub(r"(#\+filetags:[ \t]*):([ \t]*)$", r"\1\2", line, flags=re.I)
    return line


def check_lines(old_rel, new_rel, b, a, uuid2id, renames, renamed_note):
    bl, al = b.splitlines(keepends=True), a.splitlines(keepends=True)
    sm = difflib.SequenceMatcher(a=bl, b=al, autojunk=False)
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == "equal":
            continue
        if op == "insert" and renamed_note and j2 <= 40 and all(
                re.match(r"#\+(date|identifier):", l) for l in al[j1:j2]):
            continue
        if op == "replace":
            # Allow interleaved front-matter insertions inside a replace block.
            new_lines = [l for l in al[j1:j2]
                         if not (renamed_note and j1 < 40 and re.match(r"#\+(date|identifier):", l))]
            old_lines = bl[i1:i2]
            # At EOF, a last line without a newline may gain one.
            if i2 == len(bl) and old_lines and not old_lines[-1].endswith("\n"):
                old_lines = old_lines[:-1] + [old_lines[-1] + "\n"]
            if len(new_lines) == len(old_lines) and all(
                    normalize(o, uuid2id, renames) == n for o, n in zip(old_lines, new_lines)):
                continue
        fail(f"disallowed {op} in {new_rel} (was {old_rel}) lines {i1+1}-{i2}: "
             f"{''.join(bl[i1:i2])[:120]!r} -> {''.join(al[j1:j2])[:120]!r}")


if __name__ == "__main__":
    main(*sys.argv[1:4])
