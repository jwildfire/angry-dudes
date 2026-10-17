#!/usr/bin/env python3
"""Angry Dudes pack exporter.

The battle packs live in js/packs/*.js as JavaScript object literals, which is
handy for the HTML prototype but not for the iPhone app. This script reads each
pack file, parses the object literal (a small parser for the subset of
JavaScript the packs use: objects, arrays, strings, numbers, true/false/null
and comments) and writes it out as plain JSON.

Usage (from the project folder): python3 tools/export_packs.py
  Writes assets/packs/<id>.json for every pack index.html loads, plus
  assets/packs/index.json with the pack ids in the same order.
"""
import json
import os
import re
import sys


class ParseError(Exception):
    pass


class Parser:
    def __init__(self, text, name):
        self.s, self.i, self.name = text, 0, name

    def fail(self, msg):
        line = self.s.count("\n", 0, self.i) + 1
        raise ParseError(f"{self.name}:{line}: {msg}")

    def skip(self):
        s = self.s
        while self.i < len(s):
            c = s[self.i]
            if c in " \t\r\n":
                self.i += 1
            elif s.startswith("//", self.i):
                end = s.find("\n", self.i)
                self.i = len(s) if end < 0 else end
            elif s.startswith("/*", self.i):
                end = s.find("*/", self.i)
                if end < 0:
                    self.fail("unclosed comment")
                self.i = end + 2
            else:
                break

    def peek(self):
        self.skip()
        return self.s[self.i] if self.i < len(self.s) else ""

    def expect(self, c):
        if self.peek() != c:
            self.fail(f"expected {c!r}, found {self.peek()!r}")
        self.i += 1

    def value(self):
        c = self.peek()
        if c == "{":
            return self.obj()
        if c == "[":
            return self.arr()
        if c in "\"'":
            return self.string()
        if c == "-" or c == "." or c.isdigit():
            return self.number()
        word = self.ident()
        if word == "true":
            return True
        if word == "false":
            return False
        if word == "null":
            return None
        self.fail(f"unexpected {word!r}")

    def obj(self):
        self.expect("{")
        out = {}
        while self.peek() != "}":
            c = self.peek()
            key = self.string() if c in "\"'" else self.ident()
            self.expect(":")
            out[key] = self.value()
            if self.peek() == ",":
                self.i += 1
            elif self.peek() != "}":
                self.fail("expected , or }")
        self.i += 1
        return out

    def arr(self):
        self.expect("[")
        out = []
        while self.peek() != "]":
            out.append(self.value())
            if self.peek() == ",":
                self.i += 1
            elif self.peek() != "]":
                self.fail("expected , or ]")
        self.i += 1
        return out

    def ident(self):
        self.skip()
        m = re.compile(r"[A-Za-z_$][A-Za-z0-9_$]*").match(self.s, self.i)
        if not m:
            self.fail(f"unexpected {self.s[self.i:self.i + 12]!r}")
        self.i = m.end()
        return m.group(0)

    def number(self):
        self.skip()
        m = re.compile(r"-?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?").match(self.s, self.i)
        if not m:
            self.fail("bad number")
        self.i = m.end()
        t = m.group(0)
        return float(t) if any(ch in t for ch in ".eE") else int(t)

    def string(self):
        q = self.s[self.i]
        self.i += 1
        out = []
        escapes = {"n": "\n", "t": "\t", "r": "\r", "b": "\b", "f": "\f", "v": "\v", "0": "\0"}
        while True:
            if self.i >= len(self.s):
                self.fail("unclosed string")
            c = self.s[self.i]
            if c == q:
                self.i += 1
                return "".join(out)
            if c == "\\":
                e = self.s[self.i + 1]
                if e == "u":
                    out.append(chr(int(self.s[self.i + 2:self.i + 6], 16)))
                    self.i += 6
                    continue
                if e == "x":
                    out.append(chr(int(self.s[self.i + 2:self.i + 4], 16)))
                    self.i += 4
                    continue
                out.append(escapes.get(e, e))
                self.i += 2
                continue
            out.append(c)
            self.i += 1


def read_pack(path):
    text = open(path, encoding="utf-8").read()
    m = re.search(r"\.push\(", text)
    if not m:
        raise ParseError(f"{path}: no ANGRY_PACKS.push(...) found")
    p = Parser(text, os.path.basename(path))
    p.i = m.end()
    pack = p.value()
    p.expect(")")
    return pack


def pack_files(root):
    # the packs index.html loads, in the same order; a pack file it doesn't load yet is
    # still being made, so it is skipped (with a note)
    files = re.findall(r'src="(js/packs/[^"]+\.js)"', open(os.path.join(root, "index.html"), encoding="utf-8").read())
    folder = os.path.join(root, "js", "packs")
    for f in sorted(os.listdir(folder)):
        if f.endswith(".js") and "js/packs/" + f not in files:
            print(f"skipping js/packs/{f}: index.html doesn't load it yet")
    return [os.path.join(root, f) for f in files]


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(root, "assets", "packs")
    os.makedirs(out_dir, exist_ok=True)
    ids = []
    for path in pack_files(root):
        try:
            pack = read_pack(path)
        except ParseError as err:
            sys.exit(str(err))
        ids.append(pack["id"])
        with open(os.path.join(out_dir, pack["id"] + ".json"), "w", encoding="utf-8") as f:
            json.dump(pack, f, ensure_ascii=False, indent=1)
            f.write("\n")
        print(f"{pack['id']}: {len(pack['units'])} units, {len(pack['levels'])} levels")
    with open(os.path.join(out_dir, "index.json"), "w", encoding="utf-8") as f:
        json.dump({"packs": ids}, f, indent=1)
        f.write("\n")


if __name__ == "__main__":
    main()
