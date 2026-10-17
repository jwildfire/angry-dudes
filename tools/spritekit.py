"""Angry Dudes sprite toolkit: palette, team colors, a tiny pixel-drawing grid,
shared body parts and the sprite registry. Each battle pack has its own
sprites_<pack>.py that draws with these tools."""
import json
import math


PALETTE = {
    "k": "#1d1a2b", "w": "#ffffff", "s": "#f2b386", "S": "#c8805b", "h": "#3d2414",
    "b": "#a8693a", "B": "#5e3a1d", "g": "#a9b2bf", "G": "#646d7b", "l": "#e3e9f0",
    "y": "#ffd23f", "o": "#ff8c1a", "r": "#e0412c", "R": "#9e2417", "x": "#3a3546",
    "c": "#d9bc80", "C": "#a9884f",
    "p": "#9a9ea3", "P": "#74787e", "i": "#c4c7cb",           # concrete
    "a": "#5f6b34", "A": "#414a22", "e": "#808d4c",           # US olive drab
    "d": "#c9b46c", "D": "#9b864b", "E": "#e2d396",           # German dark yellow
    "j": "#5e6e3c", "J": "#7b5a36",                           # camo green / brown
    "v": "#a9dcff", "U": "#2c4f96",                           # glass, US roundel blue
    "n": "#a39b8b", "N": "#6f685d", "m": "#cbc4b4",           # castle and Gallic stone
    "f": "#d9b44a", "F": "#9c7a2c",                           # straw, thatch
    "z": "#7a5634", "Z": "#553a21",                           # earth
    "V": "#c98d3c", "W": "#8c5a22",                           # bronze
    "1": "#efe9d8", "2": "#dcc58f",                           # linen, buff
    "6": "#edcf6a", "7": "#b4532a", "8": "#e8e8e8",           # blond, ginger, white hair
    "9": "#ff6a00", "X": "#26282e",                           # fire, black iron
    "q": "#b9533a", "Q": "#7d3424", "u": "#d9c4aa",           # brick, dark brick, mortar
    "3": "#39ff88", "4": "#3ee6ff", "5": "#ff4fd8",           # neon green, laser cyan, magenta
}
TEAMS = {
    "allies": {"T": "#6b7a3a", "t": "#4a5428", "L": "#97a65c"},   # olive drab wool
    "axis":   {"T": "#6d7871", "t": "#4a534e", "L": "#9aa49d"},   # field gray
    "romans":      {"T": "#b8322a", "t": "#7d1f1a", "L": "#e05a48"},   # red tunics and shields
    "gauls":       {"T": "#3f7a3c", "t": "#2a5229", "L": "#c9a43c"},   # green and yellow check
    "english":     {"T": "#c22a2a", "t": "#861b1b", "L": "#efe9d8"},   # St George's cross on white
    "scots":       {"T": "#2d5aa8", "t": "#1d3c74", "L": "#efe9d8"},   # St Andrew's saltire blue
    "continental": {"T": "#2b4a8c", "t": "#1b3264", "L": "#dcc58f"},   # blue coats, buff facings
    "redcoats":    {"T": "#c4302b", "t": "#85201c", "L": "#efe9d8"},   # red coats, white belts
    "doughboys":   {"T": "#7b7a45", "t": "#555530", "L": "#a3a26a"},   # 1918 olive drab wool
    "kaiser":      {"T": "#7d8270", "t": "#565b4c", "L": "#a3a896"},   # 1918 German field gray
    "vikings":     {"T": "#9a3b2a", "t": "#64261b", "L": "#c96b4a"},   # madder-red wool tunics
    "franks":      {"T": "#3d6a8a", "t": "#294a62", "L": "#e6d5a8"},   # Frankish blue
    "tokugawa":    {"T": "#2f3f6a", "t": "#1e2a48", "L": "#d9c38a"},   # indigo lacquer, gold trim
    "toyotomi":    {"T": "#b0302a", "t": "#7a1f1a", "L": "#e8c45a"},   # red armor of the Sanada
    "french":      {"T": "#2b4fa0", "t": "#1b3270", "L": "#efe9d8"},   # French imperial blue
    "greeks":      {"T": "#2f5fa8", "t": "#1f3f72", "L": "#e8dcb8"},   # Syracusan blue cloaks
    "pirates":     {"T": "#a3262a", "t": "#6e1a1d", "L": "#efe9d8"},   # red bandanas and coats
    "spanish":     {"T": "#b58a4a", "t": "#7f5f30", "L": "#c4302b"},   # buff leather, red sash
    "navy":        {"T": "#2b3f7a", "t": "#1b2a54", "L": "#efe9d8"},   # Royal Navy blue
    "marines":     {"T": "#e8e8e8", "t": "#a9b2bf", "L": "#ff8c1a"},   # white space suits, orange stripes
    "robots":      {"T": "#8a94a3", "t": "#5a6270", "L": "#e0412c"},   # gunmetal, red lights
}


class Grid:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = [["."] * w for _ in range(h)]

    def px(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y][x] = c

    def get(self, x, y):
        return self.p[y][x] if 0 <= x < self.w and 0 <= y < self.h else "."

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.px(xx, yy, c)

    def line(self, x0, y0, x1, y1, c, t=1, only=None):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            for a in range(t):
                for b in range(t):
                    if only is None or self.get(x0 + a, y0 + b) in only:
                        self.px(x0 + a, y0 + b, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def disc(self, cx, cy, r, c):
        for y in range(-r, r + 1):
            for x in range(-r, r + 1):
                if x * x + y * y <= r * r + r * 0.8:
                    self.px(cx + x, cy + y, c)

    def ellipse(self, cx, cy, rx, ry, c, top_only=False):
        for y in range(-ry, ry + 1):
            if top_only and y > 0:
                continue
            for x in range(-rx, rx + 1):
                if (x / (rx + 0.5)) ** 2 + (y / (ry + 0.5)) ** 2 <= 1:
                    self.px(cx + x, cy + y, c)

    def stamp(self, rows, x, y):
        for j, r in enumerate(rows):
            for i, ch in enumerate(r):
                if ch != ".":
                    self.px(x + i, y + j, ch)

    def recolor(self, x, y, w, h, frm, to):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if self.get(xx, yy) in frm:
                    self.px(xx, yy, to)

    def top_highlight(self, x0, x1, body, hi):
        for x in range(x0, x1 + 1):
            for y in range(self.h):
                if self.p[y][x] in body:
                    self.p[y][x] = hi
                    break

    def outline(self, c="k"):
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.p[y][x] != ".":
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if self.get(x + dx, y + dy) not in (".", "k"):
                        add.append((x, y))
                        break
        for x, y in add:
            self.p[y][x] = c
        return self

    def mirror(self):
        self.p = [r[::-1] for r in self.p]
        return self

    def rows(self):
        return ["".join(r) for r in self.p]


def check(name, rows):
    w = len(rows[0])
    for i, r in enumerate(rows):
        if len(r) != w:
            raise SystemExit(f"{name}: row {i} is {len(r)} wide, expected {w}: {r!r}")
    return rows


def from_rows(name, rows):
    check(name, rows)
    g = Grid(len(rows[0]), len(rows))
    g.stamp(rows, 0, 0)
    return g



def face(mouth="frown", eyes="normal", stahl=False, mustache=False, flare=None, droop=None, beard=None):
    """Rows 6-12 of a 16-wide dude: angry brows, eyes, mouth and chin.
    flare: a character for helmet cheek guards or hair at the sides of the face.
    mustache: True for brown, or a palette character. droop: mustache ends hang down.
    beard: a palette character for a full beard that covers the chin."""
    eye_row = {"normal": "sswksskwss", "squint": "sskksskwss"}[eyes]
    mouths = {
        "frown": ["ssskkkksss", "SskssssksS"],
        "grin":  ["sskwwwwkss", "SsskkkkssS"],
        "shout": ["ssskkkksss", "SsskrrkssS"],
    }[mouth]
    inner = ["skssssssks", "sskksskkss", eye_row, "ssssssssss"] + mouths
    m = "h" if mustache is True else mustache
    if m:
        inner[3] = "ss" + m * 6 + "ss"
    if droop:
        inner[4] = droop + inner[4][1:-1] + droop
    chin = "...kkkkkkkkkk..."
    if beard:
        inner[3] = "s" + beard * 8 + "s"
        inner[4] = beard * 3 + "kkkk" + beard * 3
        inner[5] = beard * 10
        chin = "...k" + beard * 8 + "k..."
    rows = ["..k" + r + "k.." for r in inner] + [chin]
    if stahl or flare:
        f = flare or "T"
        rows[0] = "k" + f + "k" + inner[0] + "k" + f + "k"
        rows[1] = ".kk" + inner[1] + "kk."
    return rows


def person(name, hat, body, team, **face_opts):
    """Stack a 6-row hat, a face and a 5+ row body into an outlined grid."""
    return from_rows(name, hat + face(**face_opts) + body)



MINI_HEAD = [               # crew member popping out of a hatch
    "..kkkk..",
    ".kTLTTk.",
    "kTTTTTTk",
    "kkkkkkkk",
    "kskssksk",
    "ksskkssk",
    ".kkkkkk.",
]

SANDBAG_ROWS = [
    ".kkkkkk..kkkkkk.",
    "kcccccckkcccccck",
    "kccccCckkccccCck",
    "kCCCCCCkkCCCCCCk",
    "kkkkkkkkkkkkkkkk",
    "cccckcccccckcccc",
    "cccckccccCckcccc",
    "CCCCkCCCCCCkCCCC",
    "kkkkkkkkkkkkkkkk",
    "kcccccckkcccccck",
    "kccccCckkccccCck",
    "kCCCCCCkkCCCCCCk",
    "kkkkkkkkkkkkkkkk",
    "cccckcccccckcccc",
    "CCCCkCCCCCCkCCCC",
    "kkkkkkkkkkkkkkkk",
]
WOOD_ROWS = [
    "kkkkkkkkkkkkkkkk",
    "kBBBBBBBBBBBBBBk",
    "kBbbbbbbbbbBBBBk",
    "kBbbbbbbbbBBbBBk",
    "kBbbbbbbbBBbbBBk",
    "kBbbbbbbBBbbbBBk",
    "kBbbbbbBBbbbbBBk",
    "kBbbbbBBbbbbbBBk",
    "kBbbbBBbbbbbbBBk",
    "kBbbBBbbbbbbbBBk",
    "kBbBBbbbbbbbbBBk",
    "kBBBbbbbbbbbbBBk",
    "kBBbbbbbbbbbbBBk",
    "kBbbbbbbbbbbbBBk",
    "kBBBBBBBBBBBBBBk",
    "kkkkkkkkkkkkkkkk",
]
SLINGSHOT_ROWS = [
    ".kkkk......kkkk.",
    ".kbbk......kbbk.",
    ".kbBk......kbBk.",
    ".kbbkBBBBBBkbbk.",
    ".kbBk......kbBk.",
    ".kbbk......kbbk.",
    ".kbbbk....kbbbk.",
    "..kbbbk..kbbbk..",
    "...kbbbkkbbbk...",
    "....kbbbbbbk....",
    ".....kbbbbk.....",
    ".....kcccck.....",
    ".....kCCCCk.....",
    ".....kbBbbk.....",
    ".....kbbBbk.....",
    ".....kbBbbk.....",
    ".....kbbbBk.....",
    ".....kbBbbk.....",
    ".....kbbBbk.....",
    ".....kbBbbk.....",
    ".....kbbbbk.....",
    "....kkbbbbkk....",
    "...kBBBBBBBBk...",
    "...kkkkkkkkkk...",
]

SPRITES = {}


def add(name, grid_or_rows, team=None, **extra):
    rows = grid_or_rows.rows() if isinstance(grid_or_rows, Grid) else grid_or_rows
    check(name, rows)
    entry = {"rows": rows}
    if team:
        entry["team"] = team
    entry.update(extra)
    SPRITES[name] = entry



def to_json(data):
    # one sprite row per line keeps the file readable and diffable
    out = ['{', '  "palette": ' + json.dumps(data["palette"]) + ',',
           '  "teams": ' + json.dumps(data["teams"]) + ',', '  "sprites": {']
    names = list(data["sprites"])
    for n, name in enumerate(names):
        s = data["sprites"][name]
        meta = {k: v for k, v in s.items() if k != "rows"}
        head = json.dumps(meta)[1:-1]
        out.append(f'    "{name}": {{' + (head + ", " if head else "") + '"rows": [')
        out += ['      ' + json.dumps(r) + (',' if i < len(s["rows"]) - 1 else '') for i, r in enumerate(s["rows"])]
        out.append('    ]}' + (',' if n < len(names) - 1 else ''))
    out += ['  }', '}']
    return "\n".join(out)



def variant(name, source, team=None, pal=None, mirror=False):
    """A recolored and/or mirrored copy of an already-registered sprite."""
    src = SPRITES[source]
    rows = [r[::-1] for r in src["rows"]] if mirror else list(src["rows"])
    entry = {"rows": rows}
    if team or src.get("team"):
        entry["team"] = team or src["team"]
    merged = dict(src.get("pal", {}))
    merged.update(pal or {})
    if merged:
        entry["pal"] = merged
    for k, v in src.items():
        if k not in ("rows", "team", "pal"):
            entry[k] = v
    SPRITES[name] = entry


def common():
    add("slingshot", SLINGSHOT_ROWS)
    add("sandbag", SANDBAG_ROWS)
    add("wood", WOOD_ROWS)
