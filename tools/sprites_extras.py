"""New troops, defenders and pieces for the original battle packs (WWII, Rome, Castle, Revolution)."""
from spritekit import *  # noqa: F401,F403
from sprites_ww2 import US_HELMET, US_BODY  # noqa: F401
from sprites_rome import GALEA  # noqa: F401
from sprites_castle import KETTLE_HAT, SURCOAT  # noqa: F401
from sprites_revolution import TRICORNE, CONTINENTAL  # noqa: F401


# ------------------------------------------------------------------ WWII
def halftrack():
    """M3 halftrack: wheels in front, tracks behind, GIs riding in the back."""
    g = Grid(48, 26)
    g.rect(4, 19, 26, 6, "x")
    for cx in (8, 14, 20, 26):
        g.disc(cx, 22, 2, "G")
    g.rect(4, 12, 40, 8, "a")
    g.rect(4, 12, 40, 1, "e")
    g.rect(32, 10, 12, 2, "a")               # hood
    g.rect(44, 12, 2, 7, "A")
    g.rect(30, 6, 2, 6, "A")                 # windshield frame
    g.disc(38, 22, 4, "x")
    g.disc(38, 22, 1, "G")
    for x in (6, 15, 22):
        g.stamp(MINI_HEAD, x, 5)
    g.stamp(["..w..", "wwwww", ".www.", ".w.w."], 17, 14)
    return g.outline()


def c47():
    """C-47 Skytrain transport plane, with D-Day invasion stripes."""
    g = Grid(60, 22)
    for y in range(0, 10):
        g.rect(3, y, 3 + y // 2, 1, "a")     # tail fin
    g.ellipse(30, 11, 26, 4, "a")
    g.top_highlight(6, 55, "a", "e")
    g.rect(1, 11, 11, 2, "A")
    g.rect(53, 9, 3, 2, "v")                 # cockpit windows
    for x in range(20, 46, 5):
        g.px(x, 10, "v")
    g.rect(14, 10, 3, 5, "A")                # door
    g.rect(28, 13, 18, 3, "A")               # wing
    for x, c in ((30, "w"), (32, "k"), (34, "w"), (36, "k"), (38, "w")):
        g.recolor(x, 12, 2, 4, "aA", c)
    g.rect(40, 9, 6, 6, "x")                 # engine
    g.disc(22, 11, 2, "U")
    g.rect(21, 11, 3, 1, "w")
    g.outline()
    for y in range(4, 20, 2):
        g.px(47, y, "G")
    return g


def battleship():
    g = Grid(52, 20)
    g.rect(2, 12, 48, 5, "G")
    g.rect(2, 12, 48, 1, "g")
    g.line(48, 12, 51, 10, "G")
    g.rect(18, 7, 12, 5, "g")                # superstructure
    g.rect(22, 2, 4, 5, "g")
    g.rect(23, 0, 2, 2, "G")
    for x, d in ((8, 1), (34, 1), (42, 1)):
        g.rect(x, 9, 6, 3, "G")
        g.rect(x + 6 * (d > 0), 10, 6, 1, "x")
    g.rect(2, 17, 48, 2, "U")
    return g.outline()


def thunderbolt():
    """P-47 Thunderbolt fighter-bomber: a huge round engine cowling and invasion stripes."""
    g = Grid(42, 18)
    for y in range(1, 8):
        g.rect(3, y, 2 + y // 2, 1, "a")    # tail fin
    g.ellipse(20, 9, 15, 4, "a")
    g.rect(33, 4, 5, 10, "a")                # fat radial-engine cowling
    g.rect(37, 5, 2, 8, "x")
    g.top_highlight(6, 38, "a", "e")
    g.rect(1, 9, 9, 1, "A")
    g.ellipse(24, 4, 3, 2, "v")
    g.px(23, 3, "w")
    g.rect(14, 11, 14, 2, "A")               # wing
    for x, c in ((15, "w"), (17, "k"), (19, "w"), (21, "k"), (23, "w")):
        g.recolor(x, 11, 2, 2, "aA", c)
    g.disc(12, 9, 2, "U")
    g.rect(11, 9, 3, 1, "w")
    g.rect(16, 13, 6, 2, "x")                # bomb under the wing
    g.outline()
    for y in range(2, 17, 2):
        g.px(40, y, "G")                     # spinning propeller
    return g


def marauder():
    """B-26 Marauder medium bomber: two engines and a glass nose."""
    g = Grid(58, 22)
    for y in range(0, 10):
        g.rect(3, y, 3 + y // 2, 1, "a")
    g.rect(5, 8, 42, 5, "a")
    g.ellipse(48, 10, 6, 2, "a")
    g.top_highlight(5, 52, "a", "e")
    g.rect(51, 8, 4, 4, "v")
    g.px(52, 8, "w")
    g.rect(1, 11, 10, 2, "A")
    g.rect(18, 12, 22, 2, "A")
    for cx in (24, 36):
        g.rect(cx - 3, 9, 8, 5, "A")         # engine nacelles
        g.rect(cx + 5, 9, 1, 5, "x")
    g.ellipse(40, 7, 3, 1, "v")
    g.disc(14, 10, 2, "U")
    g.rect(13, 10, 3, 1, "w")
    g.outline()
    for cx in (30, 42):
        for y in range(5, 18, 2):
            g.px(cx, y, "G")
    return g


def v1_ramp():
    """A V-1 'buzz bomb' sitting on its long launch ramp."""
    g = Grid(54, 20)
    g.line(2, 18, 52, 8, "G", 2)             # the ramp
    for x in range(6, 52, 8):
        y = 18 - (x - 2) // 5
        g.rect(x, y, 2, 19 - y, "x")         # supports
    g.rect(0, 18, 54, 2, "p")
    g.ellipse(30, 9, 10, 2, "g")             # the V-1's body
    g.rect(21, 8, 3, 3, "G")
    g.ellipse(40, 9, 2, 2, "g")              # rounded nose
    g.rect(26, 11, 8, 1, "G")                # stubby wings
    g.rect(18, 4, 11, 2, "x")                # pulse-jet engine on top
    g.px(17, 5, "9")
    g.px(16, 5, "o")
    g.rect(21, 6, 2, 2, "G")
    return g.outline().mirror()


# ------------------------------------------------------------------ Rome
CORINTHIAN = [
    "......rrrr......",
    "....rrrrrrrr....",
    "...kkVVVVVVkk...",
    "..kVyVVVVVVVVk..",
    "..kVyVVVVVVVVk..",
    ".kVVVVVVVVVVVVk.",
]
HOPLITE_BODY = [
    "...kVVWVVWVVk...",
    "..kskVVVVVVksk..",
    "...kTkTkTkTkk...",
    "...kssk..kssk...",
    "..kBBBk..kBBBk..",
]
BALD = [
    "................",
    "................",
    ".....kkkkkk.....",
    "...kksswsssks...",
    "..ksssssssssk...",
    ".k88kkkkkkkk88k.",
]
ROBE = [
    "...kTTTTTTTTk...",
    "..kskTTTTTTkgk..",
    "...kTTTTTTTTk...",
    "...kTTTTTTTTk...",
    "..kkBBkkkkBBkk..",
]


def testudo():
    """Legionaries locking shields into a 'tortoise'."""
    g = Grid(42, 24)
    for row, y in enumerate((2, 8, 14)):
        for i, x in enumerate(range(3 if row else 6, 38, 7)):
            g.rect(x, y, 6, 6, "T")
            g.rect(x, y, 6, 1, "y")
            g.px(x + 2, y + 3, "y")
            g.px(x + 3, y + 3, "y")
    for x in (8, 10, 17, 19, 26, 28, 35):
        g.rect(x, 20, 1, 3, "s")
        g.px(x, 23, "B")
    return g.outline()


def hoplite():
    g = person("hoplite", CORINTHIAN, HOPLITE_BODY, "greeks", flare="V")
    g.disc(3, 13, 3, "T")
    g.disc(3, 13, 1, "V")
    for y in range(2, 17):
        g.px(14, y, "b")
    g.rect(14, 0, 1, 2, "g")
    return g.outline()


def archimedes():
    g = person("archimedes", BALD, ROBE, "greeks", beard="8", flare="8")
    g.line(13, 8, 15, 13, "g")               # drawing compass
    g.line(15, 8, 13, 13, "g")
    return g.outline()


def claw():
    """Archimedes' claw: a crane that grabbed attackers' ships (here, siege machines)."""
    g = Grid(32, 34)
    g.rect(3, 6, 4, 28, "b")
    g.rect(3, 6, 1, 28, "c")
    g.rect(0, 30, 10, 4, "B")
    g.line(5, 9, 30, 2, "b", 2)
    g.line(30, 3, 30, 20, "c")
    g.rect(27, 20, 7, 2, "X")
    g.px(27, 22, "X")
    g.px(33, 22, "X")
    g.px(27, 23, "X")
    g.px(33, 23, "X")
    g.rect(6, 14, 6, 6, "B")                 # counterweight winch
    g.disc(9, 17, 2, "c")
    return g.outline().mirror()


# ---------------------------------------------------------------- Castle
def miner():
    g = person("miner", KETTLE_HAT, SURCOAT, "english", flare="G", eyes="squint")
    g.line(14, 16, 14, 6, "b")
    g.rect(11, 5, 6, 1, "g")
    g.px(11, 6, "g")
    g.px(16, 6, "g")
    return g.outline()


def xbow_english():
    g = Grid(20, 18)
    g.stamp(KETTLE_HAT + face(flare="G", eyes="squint") + SURCOAT, 0, 0)
    g.rect(10, 14, 10, 1, "b")
    g.rect(18, 12, 1, 5, "G")
    g.px(19, 12, "G")
    g.px(19, 16, "G")
    return g.outline()


def barge():
    g = Grid(50, 22)
    for x in range(4, 46):
        g.rect(x, 12, 1, 6 if 7 < x < 43 else 4, "b")
    g.rect(4, 12, 42, 1, "c")
    for x in range(8, 44, 7):
        g.rect(x, 15, 4, 1, "B")
    for x in (10, 22, 34):
        g.stamp(["..kkkk..", ".kglggk.", "kGGGGGGk", "kkkkkkkk", "kskssksk", "ksskkssk", ".kkkkkk."], x, 5)
    g.line(6, 14, 1, 20, "b")                # oars
    g.line(44, 14, 49, 20, "b")
    return g.outline()


# ------------------------------------------------------------ Revolution
def axeman():
    g = person("axeman", TRICORNE, CONTINENTAL, "continental", mouth="shout")
    g.line(14, 16, 14, 6, "b")
    g.rect(13, 4, 4, 4, "g")
    g.px(17, 5, "g") if g.w > 17 else None
    return g.outline()


def proj_grape():
    g = Grid(5, 5)
    g.disc(2, 2, 1, "X")
    return g.outline()


def build():
    add("halftrack", halftrack(), "allies")
    add("c47", c47(), "allies")
    add("battleship", battleship())
    add("p47", thunderbolt(), "allies")
    add("b26", marauder(), "allies")
    add("v1_ramp", v1_ramp())
    variant("howitzer_de", "howitzer", team="axis", pal={"a": "#6d7871", "A": "#4a534e", "e": "#9aa49d"}, mirror=True)
    add("testudo", testudo(), "romans")
    add("hoplite", hoplite(), "greeks")
    add("archimedes", archimedes(), "greeks")
    add("claw", claw(), "greeks")
    add("miner", miner(), "english")
    add("xbow_english", xbow_english(), "english")
    add("barge", barge(), "english")
    variant("mangonel", "onager", mirror=True)
    add("axeman", axeman(), "continental")
    add("proj_grape", proj_grape())
    variant("brunswicker", "redcoat", pal={"T": "#2b3f7a", "t": "#1b2a54"})
    variant("breymann", "cornwallis", pal={"T": "#2b3f7a", "t": "#1b2a54"})
