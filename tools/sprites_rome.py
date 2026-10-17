"""Sprites for battle pack: Romans vs. Gauls (52 BC)."""
from spritekit import *  # noqa: F401,F403

# ---------------------------------------------------------------- Romans
GALEA = [                   # bronze legionary helmet with cheek guards
    "......kVVk......",
    "....kkVyVVkk....",
    "..kkVyyVVVVVkk..",
    "..kVyVVVVVVVVk..",
    ".kWVVVVVVVVVVWk.",
    "kWWkkkkkkkkkkWWk",
]
CENTURION_HELMET = [        # sideways red crest: the centurion's badge of rank
    "..kkkkkkkkkkkk..",
    ".krrrrrrrrrrrrk.",
    ".kRrRrRrRrRrRrk.",
    "...kkVyVVVVkk...",
    "..kVyVVVVVVVVk..",
    ".kWVVVVVVVVVVWk.",
    "kWWkkkkkkkkkkWWk",
]
ARCHER_HAT = [              # conical helmet of an eastern auxiliary archer
    ".......kk.......",
    "......kGgk......",
    ".....kGgggk.....",
    "....kGggggGk....",
    "...kGgggggggk...",
    ".kkkkkkkkkkkkkk.",
]
LEGION_BODY = [             # segmented armor over a red tunic, bare legs, sandals
    "...kgGgGgGgGk...",
    "..kskgGgGgGksk..",
    "...kTkTkTkTkk...",
    "...kssk..kssk...",
    "..kBBBk..kBBBk..",
]
CENTURION_BODY = [          # mail shirt with phalerae (bravery medals)
    "...kGyGyGyGGk...",
    "..kskGgGgGgksk..",
    "...kTkTkTkTkk...",
    "...kssk..kssk...",
    "..kBBBk..kBBBk..",
]
ARCHER_BODY = [
    "...kTTTTTTTTk...",
    "..kskTTTTTTksk..",
    "...kBBBBBBBBk...",
    "...kssk..kssk...",
    "..kBBBk..kBBBk..",
]

# ----------------------------------------------------------------- Gauls
SPIKY_HAIR = [              # Gauls spiked their hair with lime wash
    "...k..k..k..k...",
    "..k6kk6kk6kk6k..",
    "..k6666666666k..",
    ".k666666666666k.",
    ".k666666666666k.",
    ".k66kkkkkkkk66k.",
]
DRUID_HOOD = [
    ".....kkkkkk.....",
    "...kk111111kk...",
    "..k1111j11111k..",
    "..k1111111111k..",
    ".k111111111111k.",
    ".k11kkkkkkkk11k.",
]
WINGED_HELMET = [           # Vercingetorix
    "w....kkkkkk....w",
    "ww.kkVyVVVVkk.ww",
    "wwkVyyVVVVVVVkww",
    ".wkVyVVVVVVVVkw.",
    ".kVVVVVVVVVVVVk.",
    ".k66kkkkkkkk66k.",
]
GAUL_BODY = [               # gold torc, checked tunic and trousers
    "...kTyyyyyyTk...",
    "..kskTLTLTLksk..",
    "...kBBBBBBBBk...",
    "...kLTk..kTLk...",
    "..kBBBk..kBBBk..",
]
DRUID_BODY = [
    "...k11888811k...",
    "..ksk111111kyk..",
    "...k11111111k...",
    "...k11111111k...",
    "..kkBBkkkkBBkk..",
]
CHIEF_BODY = [              # red cloak and a big gold torc
    "..kryyyyyyyyrk..",
    ".krskTLTLTLksrk.",
    ".krkBBBBBBBBkrk.",
    "..rkLTk..kTLkr..",
    "..kBBBk..kBBBk..",
]


def legionary():
    g = person("legionary", GALEA, LEGION_BODY, "romans", flare="W")
    g.rect(0, 9, 4, 9, "T")                 # scutum
    g.rect(0, 9, 4, 1, "y")
    g.rect(0, 17, 4, 1, "y")
    g.rect(1, 12, 2, 2, "y")
    return g.outline()


def centurion():
    g = person("centurion", CENTURION_HELMET, CENTURION_BODY, "romans", flare="W", mustache=True)
    for y in range(10, 18):
        g.px(14, y, "b")                    # vine staff
    g.px(15, 10, "b")
    return g.outline()


def archer():
    g = Grid(18, 18)
    g.stamp(ARCHER_HAT + face() + ARCHER_BODY, 0, 0)
    for x, y in ((14, 4), (15, 5), (16, 6), (16, 7), (16, 8), (16, 9), (16, 10), (16, 11), (15, 12), (14, 13)):
        g.px(x, y, "b")
    for y in range(5, 13):
        g.px(14, y, "l")
    return g.outline()


def pilum_thrower():
    g = Grid(20, 18)
    g.stamp(GALEA + face(flare="W", mouth="shout") + LEGION_BODY, 0, 0)
    g.line(13, 13, 15, 6, "s")
    g.line(9, 9, 17, 1, "b")
    g.line(17, 1, 19, 0, "G")
    g.px(18, 0, "g")
    return g.outline()


def gaul():
    g = person("gaul", SPIKY_HAIR, GAUL_BODY, "gauls", flare="6", mustache="6", droop="6")
    for y in range(11, 18):
        g.px(14, y, "g")
    g.rect(13, 11, 3, 1, "V")
    return g.outline()


def slinger():
    hair = [r.replace("6", "7") for r in SPIKY_HAIR]
    g = Grid(18, 18)
    g.stamp(hair + face(flare="7", mustache="7", droop="7", mouth="shout") + GAUL_BODY, 0, 0)
    g.line(13, 13, 15, 6, "s")
    g.line(15, 6, 16, 2, "b")
    g.rect(16, 0, 2, 2, "n")
    return g.outline()


def druid():
    g = person("druid", DRUID_HOOD, DRUID_BODY, "gauls", flare="1", beard="8")
    for x, y in ((14, 10), (15, 11), (15, 12), (15, 13)):
        g.px(x, y, "y")                     # golden sickle
    g.px(6, 2, "j")
    g.px(7, 1, "j")                         # mistletoe
    return g.outline()


def chief():
    return person("chief", WINGED_HELMET, CHIEF_BODY, "gauls", flare="6", mustache="6", droop="6").outline()


# --------------------------------------------------------- siege engines
def onager():
    g = Grid(34, 24)
    g.rect(1, 19, 31, 3, "b")
    g.rect(1, 19, 31, 1, "c")
    g.rect(19, 8, 3, 12, "b")
    g.rect(15, 7, 10, 2, "B")
    g.rect(15, 6, 9, 1, "c")
    g.rect(7, 15, 7, 4, "C")
    g.rect(7, 15, 7, 1, "c")
    g.line(10, 17, 3, 10, "B", 2)
    g.disc(3, 8, 2, "n")
    g.px(2, 7, "m")
    return g.outline()


def ballista():
    g = Grid(30, 20)
    g.line(14, 12, 8, 19, "B")
    g.line(16, 12, 22, 19, "B")
    g.rect(14, 10, 3, 4, "b")
    g.rect(3, 8, 25, 2, "b")
    g.rect(17, 4, 3, 10, "C")
    g.line(19, 4, 24, 0, "B")
    g.line(19, 13, 24, 17, "B")
    g.line(24, 0, 6, 8, "l")
    g.line(24, 17, 6, 9, "l")
    g.rect(22, 7, 6, 1, "G")
    g.px(28, 8, "G")
    return g.outline()


def ram():
    g = Grid(46, 22)
    g.rect(4, 6, 32, 9, "b")
    for x in range(6, 36, 5):
        g.rect(x, 6, 1, 9, "B")
    g.rect(2, 3, 36, 3, "C")
    g.rect(6, 1, 28, 2, "C")
    g.rect(6, 1, 28, 1, "c")
    g.rect(8, 11, 34, 3, "B")
    g.rect(39, 10, 5, 5, "V")
    g.px(42, 11, "k")
    for x in (15, 17, 23, 25):
        g.rect(x, 15, 1, 2, "s")
        g.px(x, 17, "B")
    for cx in (10, 32):
        g.disc(cx, 18, 3, "B")
        g.px(cx, 18, "c")
    return g.outline()


# ------------------------------------------------------------ projectiles
def proj_pilum():
    g = Grid(20, 5)
    g.rect(1, 2, 11, 1, "b")
    g.rect(12, 2, 5, 1, "g")
    g.px(17, 2, "G")
    g.px(16, 1, "G")
    g.px(16, 3, "G")
    return g.outline()


def proj_boulder():
    g = Grid(12, 12)
    g.disc(6, 6, 4, "n")
    g.disc(5, 5, 2, "m")
    g.px(8, 8, "N")
    g.px(7, 9, "N")
    g.px(9, 7, "N")
    return g.outline()


def proj_bolt():
    g = Grid(17, 5)
    g.rect(1, 2, 11, 1, "b")
    g.rect(12, 1, 2, 3, "G")
    g.px(14, 2, "G")
    g.px(15, 2, "G")
    for x in (1, 2):
        g.px(x, 1, "w")
        g.px(x, 3, "w")
    return g.outline()


def proj_arrow():
    g = Grid(13, 5)
    g.rect(2, 2, 8, 1, "b")
    g.px(10, 2, "g")
    g.px(11, 2, "G")
    g.px(1, 1, "r")
    g.px(1, 3, "r")
    g.px(2, 1, "w")
    g.px(2, 3, "w")
    return g.outline()


# ------------------------------------------------------------ fort pieces
def rampart():
    """Murus gallicus: stone wall with the ends of timber beams showing."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "n")
    for y in (5, 10):
        g.rect(1, y, 14, 1, "N")
    for x, y0 in ((6, 1), (11, 1), (4, 11), (9, 11), (13, 11)):
        g.rect(x, y0, 1, 4, "N")
    for x0, y0 in ((1, 1), (7, 1), (12, 1), (1, 11), (5, 11), (10, 11)):
        g.rect(x0, y0, 2, 1, "m")
    g.rect(5, 6, 5, 4, "b")
    g.rect(6, 7, 3, 2, "B")
    return g


def turf():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "z")
    g.rect(1, 1, 14, 3, "a")
    g.rect(1, 1, 14, 1, "e")
    for y in (8, 12):
        g.rect(1, y, 14, 1, "Z")
    g.rect(1, 4, 14, 1, "a")
    return g


def log():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    for y in (1, 6, 11):
        g.rect(1, y, 14, 4, "b")
        g.rect(1, y + 3, 14, 1, "B")
        g.rect(1, y, 3, 4, "c")
        g.px(2, y + 1, "C")
        g.px(2, y + 2, "C")
    return g


def thatch():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "f")
    for x in range(1, 15, 3):
        g.line(x, 1, x + 2, 14, "F")
    g.rect(1, 13, 14, 2, "F")
    return g


def palisade():
    g = Grid(16, 16)
    for i in range(4):
        x = i * 4
        g.rect(x + 1, 3, 2, 13, "b")
        g.rect(x + 1, 2, 2, 1, "c")
        g.px(x + 1, 1, "c")
        g.rect(x + 2, 3, 1, 13, "B")
    return g.outline()


def pitchpot():
    g = Grid(16, 16)
    g.ellipse(8, 11, 6, 4, "X")
    g.rect(2, 7, 12, 2, "G")
    g.rect(3, 7, 10, 1, "x")
    for x, y, c in ((5, 5, "9"), (6, 4, "y"), (8, 3, "9"), (9, 2, "y"), (10, 5, "9"), (7, 6, "y"), (11, 4, "9")):
        g.px(x, y, c)
    g.px(4, 15, "X")
    g.px(11, 15, "X")
    return g.outline()


def build():
    add("legionary", legionary(), "romans")
    add("centurion", centurion(), "romans")
    add("archer", archer(), "romans")
    add("pilum_thrower", pilum_thrower(), "romans")
    add("onager", onager(), "romans")
    add("ballista", ballista(), "romans")
    add("ram", ram(), "romans")
    add("proj_pilum", proj_pilum())
    add("proj_boulder", proj_boulder())
    add("proj_bolt", proj_bolt())
    add("proj_arrow", proj_arrow())
    add("gaul", gaul(), "gauls")
    add("slinger", slinger(), "gauls")
    add("druid", druid(), "gauls")
    add("chief", chief(), "gauls")
    add("rampart", rampart())
    add("turf", turf())
    add("log", log())
    add("thatch", thatch())
    add("palisade", palisade())
    add("pitchpot", pitchpot())
