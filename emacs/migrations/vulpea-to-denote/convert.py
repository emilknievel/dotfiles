#!/usr/bin/env python3
"""Convert mixed vulpea/denote note vaults to denote.

Dry run (default) writes a mapping and a report and touches nothing:

    convert.py ROOT --mapping mapping.json

Apply replays a reviewed mapping and refuses to run if any source file
changed since the dry run:

    convert.py ROOT --mapping mapping.json --apply

ROOT holds notes/, work-notes/ and org/ (normally ~/Documents).
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import sys
import unicodedata

VAULTS = ["notes", "work-notes/mio"]
LINK_ONLY = ["org"]
EXCLUDED_DIRS = {"literature", "attachments", "data", "graphs", "ltximg"}
NOTE_EXTS = (".org", ".md")
LINK_EXTS = (".org", ".org_archive")
MECHANICAL_TAGS = {"todo"}

DENOTE_NAME = re.compile(r"^(\d{8}T\d{6})(?:==[^-_.]+)?--")
VULPEA_NAME = re.compile(r"^(\d{8})(\d{6})[_-](.*)$")
ID_LINK = re.compile(r"\[\[id:([^\]\[:]+)(?=[\]:])")
FILE_LINK = re.compile(r"\[\[file:([^\]\[]+?\.(?:org|md))(?=::|\])")
FILETAGS = re.compile(r"^(#\+filetags:[ \t]*)(.*?)([ \t]*)$", re.I | re.M)


# ---------------------------------------------------------------- io

def read_bytes(path):
    with open(path, "rb") as f:
        return f.read()


def decode(data):
    return data.decode("utf-8", errors="surrogateescape")


def encode(text):
    return text.encode("utf-8", errors="surrogateescape")


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def write_atomic(path, data):
    tmp = path + ".denote-tmp"
    with open(tmp, "wb") as f:
        f.write(data)
    st = os.stat(path) if os.path.exists(path) else None
    os.replace(tmp, path)
    if st:
        os.chmod(path, st.st_mode)


# ---------------------------------------------------------------- scanning

def excluded(rel):
    parts = rel.split(os.sep)
    return any(p.startswith(".") or p in EXCLUDED_DIRS for p in parts[:-1]) \
        or parts[-1].startswith(".") or parts[-1].endswith("~")


def walk(root, subdir, exts):
    base = os.path.join(root, subdir)
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames.sort()
        for name in sorted(filenames):
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            if name.endswith(exts) and not excluded(os.path.relpath(path, base)):
                yield rel


# ---------------------------------------------------------------- parsing

def keyword(text, key):
    m = re.search(rf"^#\+{key}:[ \t]*(.*?)[ \t]*$", text, re.M | re.I)
    return m.group(1) if m else None


def front_end(lines):
    """Index of the first line after the top drawer + keyword block."""
    i, in_drawer = 0, False
    while i < len(lines):
        s = lines[i].strip()
        if s == ":PROPERTIES:" and not in_drawer:
            in_drawer = True
        elif in_drawer:
            if s == ":END:":
                in_drawer = False
        elif not lines[i].startswith("#+"):
            break
        i += 1
    return i


def file_uuid(text):
    head = re.split(r"^\*", text, maxsplit=1, flags=re.M)[0]
    m = re.search(r"^[ \t]*:ID:[ \t]+(\S+)", head, re.M)
    return m.group(1) if m else None


def created(text):
    m = re.search(r"^[ \t]*:CREATED:[ \t]+\[(\d{4})-(\d\d)-(\d\d)(?:[^\]\d]*(\d\d):(\d\d))?[^\]]*\]",
                  text, re.M)
    if m:
        y, mo, d, hh, mm = m.groups()
        return f"{y}{mo}{d}T{hh or '00'}{mm or '00'}00", m.group(0).split(None, 1)[1].strip()
    return None, None


def sluggify(s):
    s = unicodedata.normalize("NFC", s).lower()
    s = re.sub(r"[^\w\s-]", "", s)
    return re.sub(r"[\s_-]+", "-", s).strip("-")


def sluggify_kw(s):
    return re.sub(r"[\W_]", "", unicodedata.normalize("NFC", s).lower())


def ts(ident):
    return datetime.datetime.strptime(ident, "%Y%m%dT%H%M%S")


def bump(ident):
    return (ts(ident) + datetime.timedelta(seconds=1)).strftime("%Y%m%dT%H%M%S")


def derive_id(root, rel, text):
    name = os.path.basename(rel)
    v = keyword(text, "identifier")
    if v and re.fullmatch(r"\d{8}T\d{6}", v):
        return v, "identifier"
    if m := DENOTE_NAME.match(name):
        return m.group(1), "denote-filename"
    if m := VULPEA_NAME.match(name):
        return f"{m.group(1)}T{m.group(2)}", "vulpea-filename"
    # A dated filename is the day the entry is about; CREATED can be a
    # later catch-up session.
    if m := re.match(r"^(\d{4})-(\d\d)-(\d\d)\.org$", name):
        return "%s%s%sT000000" % m.groups(), "journal-date"
    c, _ = created(text)
    if c:
        return c, "CREATED"
    v = keyword(text, "created")
    if v and (m := re.match(r"\[?(\d{4})-(\d\d)-(\d\d)", v)):
        return "%s%s%sT000000" % m.groups(), "#+created"
    if m := re.match(r"^(\d{4})-W(\d\d)\.org$", name):
        d = datetime.date.fromisocalendar(int(m.group(1)), int(m.group(2)), 1)
        return d.strftime("%Y%m%dT000000"), "iso-week"
    t = datetime.datetime.fromtimestamp(os.path.getmtime(os.path.join(root, rel)))
    return t.strftime("%Y%m%dT%H%M%S"), "mtime"


# ---------------------------------------------------------------- planning

def plan(root):
    notes = []
    for v in VAULTS:
        for rel in walk(root, v, NOTE_EXTS):
            data = read_bytes(os.path.join(root, rel))
            notes.append({"old": rel, "sha256": sha256(data), "text": decode(data)})

    used = set()
    # Denote-era files keep their identifier and name; reserve those first.
    for n in notes:
        name = os.path.basename(n["old"])
        if m := DENOTE_NAME.match(name):
            n["id"], n["id_source"], n["keep_name"] = m.group(1), "denote-filename", True
            used.add((m.group(1), os.path.splitext(name)[1]))

    org_twins = {}
    for n in sorted(notes, key=lambda n: (not n["old"].endswith(".org"), n["old"])):
        if n.get("keep_name"):
            continue
        name = os.path.basename(n["old"])
        stem, ext = os.path.splitext(name)
        twin_key = (os.path.dirname(n["old"]), stem)
        if ext == ".md" and twin_key in org_twins:
            # An export of an org note shares its identifier and name.
            twin = org_twins[twin_key]
            n["id"], n["id_source"] = twin["id"], "org-twin"
            n["new"] = os.path.splitext(twin["new"])[0] + ".md"
            continue
        ident, source = derive_id(root, n["old"], n["text"])
        while (ident, ext) in used or (ext == ".org" and (ident, ".md") in used):
            ident, source = bump(ident), source + "+bump"
        used.add((ident, ext))
        n["id"], n["id_source"] = ident, source
        if ext == ".org":
            title = keyword(n["text"], "title") or stem
            tags = [sluggify_kw(t) for t in (keyword(n["text"], "filetags") or "").split(":")]
            tags = [t for t in dict.fromkeys(tags) if t and t not in MECHANICAL_TAGS]
        else:
            m = VULPEA_NAME.match(name)
            title, tags = (m.group(3)[: -len(ext)] if m else stem), []
        newname = f"{ident}--{sluggify(title)}" + (f"__{'_'.join(tags)}" if tags else "") + ext
        n["new"] = os.path.join(os.path.dirname(n["old"]), newname)
        if ext == ".org":
            org_twins[twin_key] = n

    for n in notes:
        n.setdefault("new", n["old"])
        n["uuid"] = file_uuid(n["text"]) if n["old"].endswith(".org") else None

    news = [n["new"] for n in notes]
    dupes = {p for p in news if news.count(p) > 1}
    if dupes:
        sys.exit(f"refusing: duplicate target names {sorted(dupes)}")
    return notes


# ---------------------------------------------------------------- transforms

def rewrite_links(text, here_rel, uuid2id, old2new, stats):
    def id_sub(m):
        u = m.group(1)
        if u in uuid2id:
            stats["id->denote"] += 1
            return f"[[denote:{uuid2id[u]}"
        stats["id kept"] += 1
        return m.group(0)

    def file_sub(m):
        raw = m.group(1)
        here_dir = os.path.dirname(here_rel)
        if raw.startswith("~/Documents/"):
            target = raw[len("~/Documents/"):]
        elif raw.startswith("/"):
            target = None
            for prefix in (os.path.expanduser("~/Documents/"),):
                if raw.startswith(prefix):
                    target = raw[len(prefix):]
        else:
            target = os.path.normpath(os.path.join(here_dir, raw))
        if target is None or target not in old2new or old2new[target] == target:
            return m.group(0)
        new = old2new[target]
        stats["file link repointed"] += 1
        if raw.startswith("~/Documents/"):
            out = "~/Documents/" + new
        elif raw.startswith("/"):
            out = os.path.expanduser("~/Documents/") + new
        else:
            out = os.path.relpath(new, here_dir or ".")
        return f"[[file:{out}"

    text = ID_LINK.sub(id_sub, text)
    return FILE_LINK.sub(file_sub, text)


def drop_mechanical_tags(text):
    def sub(m):
        tags = [t for t in m.group(2).split(":") if t]
        kept = [t for t in tags if t.lower() not in MECHANICAL_TAGS]
        if kept == tags:
            return m.group(0)
        return f"{m.group(1)}:{':'.join(kept)}:{m.group(3)}" if kept else f"{m.group(1)}{m.group(3)}"
    return FILETAGS.sub(sub, text, count=1)


def add_front_matter(text, n):
    nl = "\r\n" if "\r\n" in text else "\n"
    lines = text.split(nl)
    i = front_end(lines)
    add = []
    if keyword(text, "date") is None:
        _, stamp = created(text)
        if not stamp:
            stamp = ts(n["id"]).strftime("[%Y-%m-%d %a %H:%M]")
        add.append(f"#+date:       {stamp}")
    if keyword(text, "identifier") is None:
        add.append(f"#+identifier: {n['id']}")
    elif keyword(text, "identifier") != n["id"]:
        sys.exit(f"refusing: {n['old']} has #+identifier {keyword(text, 'identifier')} != {n['id']}")
    out = nl.join(lines[:i] + add + lines[i:])
    # Appending at EOF to a file without a final newline: end it properly.
    return out + nl if add and i == len(lines) else out


def transform_all(root, notes):
    from collections import Counter
    stats = Counter()
    uuid2id = {n["uuid"]: n["id"] for n in notes if n["uuid"]}
    old2new = {n["old"]: n["new"] for n in notes}
    by_old = {n["old"]: n for n in notes}
    out = {}
    targets = [n["old"] for n in notes if n["old"].endswith(".org")]
    for sub in LINK_ONLY:
        targets += list(walk(root, sub, LINK_EXTS))
    for rel in targets:
        data = read_bytes(os.path.join(root, rel))
        text = decode(data)
        here = by_old[rel]["new"] if rel in by_old else rel
        new = rewrite_links(text, here, uuid2id, old2new, stats)
        if rel in by_old:
            new = drop_mechanical_tags(new)
            new = add_front_matter(new, by_old[rel])
        if new != text:
            out[rel] = encode(new)
    return out, stats


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("root")
    ap.add_argument("--mapping", required=True)
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()
    root = os.path.abspath(os.path.expanduser(args.root))

    if args.apply:
        with open(args.mapping) as f:
            saved = json.load(f)
        notes = plan(root)
        current = {n["old"]: n for n in notes}
        for s in saved["notes"]:
            c = current.get(s["old"])
            if c is None or c["sha256"] != s["sha256"]:
                sys.exit(f"refusing: {s['old']} changed or vanished since the dry run")
            if (c["id"], c["new"]) != (s["id"], s["new"]):
                sys.exit(f"refusing: {s['old']} would map differently than in the dry run")
        if len(saved["notes"]) != len(notes):
            sys.exit("refusing: the set of notes changed since the dry run")
        for rel, h in saved["link_only"].items():
            if sha256(read_bytes(os.path.join(root, rel))) != h:
                sys.exit(f"refusing: {rel} changed since the dry run")
    else:
        notes = plan(root)

    contents, stats = transform_all(root, notes)

    if not args.apply:
        link_only = {}
        for sub in LINK_ONLY:
            for rel in walk(root, sub, LINK_EXTS):
                link_only[rel] = sha256(read_bytes(os.path.join(root, rel)))
        mapping = {
            "root": root,
            "notes": [{k: n[k] for k in ("old", "new", "id", "id_source", "uuid", "sha256")}
                      for n in notes],
            "link_only": link_only,
        }
        with open(args.mapping, "w") as f:
            json.dump(mapping, f, ensure_ascii=False, indent=1)
        report(notes, contents, stats)
        print(f"\nDry run only. Mapping written to {args.mapping}")
        return

    # Rename first, then write content, so each step is a plain rename or edit.
    for n in notes:
        if n["new"] != n["old"]:
            dst = os.path.join(root, n["new"])
            if os.path.exists(dst):
                sys.exit(f"refusing: {n['new']} already exists")
            os.rename(os.path.join(root, n["old"]), dst)
    by_old = {n["old"]: n["new"] for n in notes}
    for rel, data in contents.items():
        write_atomic(os.path.join(root, by_old.get(rel, rel)), data)
    report(notes, contents, stats)
    print("\nApplied.")


def report(notes, contents, stats):
    from collections import Counter
    renamed = [n for n in notes if n["new"] != n["old"]]
    print(f"notes in scope:        {len(notes)}")
    print(f"renamed:               {len(renamed)}")
    print(f"files with edits:      {len(contents)}")
    print(f"identifier sources:    {dict(Counter(n['id_source'] for n in notes))}")
    print(f"links:                 {dict(stats)}")
    for n in notes:
        if "bump" in n["id_source"] or n["id_source"] == "mtime":
            print(f"  {n['id_source']:<22} {n['id']}  {n['old']}")


if __name__ == "__main__":
    main()
