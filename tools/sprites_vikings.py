"""Sprites for battle pack: Vikings (Rochester 885, the Siege of Paris 885-886).
Real Viking helmets were round with a nose guard. The horns are a 1800s invention."""
from spritekit import *  # noqa: F401,F403

VIKING_HELMET = [
    ".....kkkkkk.....",
    "...kkgllggGkk...",
    "..kglllgggggGk..",
    "..kgllgggggGGk..",
    ".kGGGGGGGGGGGGk.",
    ".kkkkkkgGkkkkkk.",
]
BEAR_HOOD = [               # a berserker wearing a bear's head
    "..kk........kk..",
    ".kBbk......kbBk.",
    ".kBbbkkkkkkbbBk.",
    ".kBbbbbbbbbbbBk.",
    ".kBwkbbbbbbkwBk.",
    "kBBkkkkkkkkkkBBk",
]
FRANK_HELMET = [            # Frankish conical helmet
    ".......kk.......",
    "......kglk......",
    ".....kgllGk.....",
    "....kgllggGk....",
    "...kGGGGGGGGk...",
    ".kkkkkkkkkkkkkk.",
]
CIRCLET = [                 # Count Odo's gold circlet
    "................",
    "................",
    "...k.k.kk.k.k...",
    "..kykykyykykyk..",
    "..kyyyyyyyyyyk..",
    ".kkkkkkkkkkkkkk.",
]
FLAT_CAP = [
    "................",
    "................",
    ".....kkkkkk.....",
    "...kkbbbbbbkk...",
    "..kbbbbbbbbbbk..",
    ".kkkkkkkkkkkkkk.",
]
VIKING_BODY = [
    "...kTTTTTTTTk...",
    "..kskTTTTTTksk..",
    "...kBBBgBBBBk...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]
PELT_BODY = [
    "...kBbBbBbBBk...",
    "..kskbBbBbBksk..",
    "...kBBBgBBBBk...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]
FRANK_BODY = [              # mail shirt over a blue tunic
    "...kGgGgGgGgk...",
    "..kskTTTTTTksk..",
    "...kBBByBBBBk...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]
COUNT_BODY = [              # red cloak and a sword belt
    "..krTTTTTTTTrk..",
    ".krskTyTTyTksrk.",
    ".krkBBByBBBBkrk.",
    "..rkttk..kttkr..",
    "..kBBBk..kBBBk..",
]
TOWNS_BODY = [
    "...k22222222k...",
    "..ksk222222ksk..",
    "...kBBBBBBBBk...",
    "...kbbk..kbbk...",
    "..kBBBk..kBBBk..",
]


def nasal(g):
    for y in (6, 7, 8):
        g.px(7, y, "G")
        g.px(8, y, "g")


def round_shield(g, cx, cy):
    g.disc(cx, cy, 3, "y")
    for dy in range(-3, 4):
        g.px(cx, cy + dy, "T")
    g.rect(cx - 3, cy, 7, 1, "T")
    g.px(cx, cy, "g")


def raider():
    g = person("raider", VIKING_HELMET, VIKING_BODY, "vikings", beard="6")
    nasal(g)
    round_shield(g, 3, 14)
    return g.outline()


def berserker():
    g = person("berserker", BEAR_HOOD, PELT_BODY, "vikings", flare="B", beard="7", mouth="shout")
    for y in range(9, 17):
        g.px(14, y, "b")
    g.rect(13, 7, 3, 3, "g")
    g.px(15, 10, "g")
    return g.outline()


def axe_thrower():
    g = Grid(18, 18)
    g.stamp(VIKING_HELMET + face(beard="6", mouth="shout") + VIKING_BODY, 0, 0)
    nasal(g)
    g.line(13, 13, 15, 6, "s")
    g.line(15, 6, 15, 1, "b")
    g.rect(15, 0, 3, 3, "g")
    return g.outline()


def proj_axe():
    g = Grid(11, 11)
    g.line(1, 9, 7, 3, "b")
    g.rect(6, 1, 3, 4, "g")
    g.px(9, 2, "g")
    g.px(9, 3, "G")
    g.px(5, 1, "G")
    return g.outline()


def longship(fire=False):
    """A dragon-prowed longship on log rollers, hauled over land like at Paris."""
    g = Grid(56, 30)
    for x in range(6, 50):
        depth = 6 if 12 < x < 44 else 4 if 8 < x < 48 else 2
        g.rect(x, 18, 1, depth, "b")
    g.rect(6, 18, 44, 1, "c")
    for x in range(8, 48, 6):
        g.rect(x, 21, 4, 1, "B")
    g.line(49, 19, 54, 9, "b", 2)            # prow
    g.rect(52, 6, 4, 4, "y")                 # dragon head
    g.px(55, 7, "k")
    g.line(6, 19, 2, 11, "b", 2)             # stern curl
    g.px(2, 10, "y")
    for i, x in enumerate(range(11, 46, 6)):
        g.disc(x, 16, 2, "y" if i % 2 else "T")
        g.px(x, 16, "g")
    g.rect(27, 2, 2, 14, "B")                # mast with furled sail
    g.rect(21, 3, 14, 2, "r")
    g.rect(21, 3, 14, 1, "w")
    for x in (14, 28, 42):
        g.disc(x, 26, 3, "b")
        g.px(x, 26, "c")
    if fire:
        for x, y, c in ((16, 12, "9"), (17, 10, "y"), (20, 13, "9"), (31, 11, "9"), (32, 9, "y"), (36, 12, "9"),
                        (40, 10, "y"), (41, 12, "9"), (24, 10, "9"), (25, 8, "y"), (44, 13, "9")):
            g.px(x, y, c)
            g.px(x, y + 1, "9")
    return g.outline()


def frank():
    g = person("frank", FRANK_HELMET, FRANK_BODY, "franks", mustache=True)
    for y in range(2, 17):
        g.px(14, y, "b")
    g.rect(14, 0, 1, 2, "g")
    g.px(13, 1, "g")
    g.px(15, 1, "g")
    return g.outline()


def frank_archer():
    g = Grid(18, 18)
    g.stamp(FRANK_HELMET + face(eyes="squint") + FRANK_BODY, 0, 0)
    for x, y in ((14, 4), (15, 5), (16, 6), (16, 7), (16, 8), (16, 9), (16, 10), (16, 11), (15, 12), (14, 13)):
        g.px(x, y, "b")
    for y in range(5, 13):
        g.px(14, y, "l")
    return g.outline().mirror()


def shieldman():
    g = Grid(16, 17)
    g.stamp(FRANK_HELMET + face(), 0, 0)
    g.rect(0, 7, 16, 10, ".")
    g.disc(8, 12, 6, "T")
    g.disc(8, 12, 5, "L")
    g.disc(8, 12, 3, "T")
    g.disc(8, 12, 1, "g")
    g.px(0, 12, "s")
    g.px(15, 12, "s")
    return g.outline()


def count_odo():
    g = person("count_odo", CIRCLET, COUNT_BODY, "franks", beard="h")
    for y in range(9, 17):
        g.px(14, y, "g")
    g.rect(13, 13, 3, 1, "y")
    return g.outline()


def townsman():
    g = person("townsman", FLAT_CAP, TOWNS_BODY, "franks", mouth="shout")
    for y in range(2, 17):
        g.px(14, y, "b")
    for x in (13, 15):
        g.rect(x, 0, 1, 3, "g")
    g.px(14, 2, "g")
    return g.outline()


def build():
    add("raider", raider(), "vikings")
    add("berserker", berserker(), "vikings")
    add("axe_thrower", axe_thrower(), "vikings")
    add("proj_axe", proj_axe())
    add("longship", longship(), "vikings")
    add("fireship", longship(fire=True), "vikings")
    add("frank", frank(), "franks")
    add("frank_archer", frank_archer(), "franks")
    add("shieldman", shieldman(), "franks")
    add("count_odo", count_odo(), "franks")
    add("townsman", townsman(), "franks")
