"""Sprites for battle pack: Pirates vs. Navy (Portobelo 1668, Maracaibo 1669, Ocracoke 1718)."""
from spritekit import *  # noqa: F401,F403
from sprites_revolution import ROUND_HAT, GOLD_TRICORNE, musket  # noqa: F401

BANDANA = [
    "................",
    "................",
    "....kkkkkkkk....",
    "...kTTLTTTLTkkk.",
    "..kTTTTTTTTTkTTk",
    "..kkkkkkkkkkk.kk",
]
PIRATE_HAT = [              # a captain's black tricorne with a little white skull
    "................",
    "................",
    "......kkkk......",
    "..kkkkxxxxkkkk..",
    ".kxxxxxwwxxxxxk.",
    "kxxxkkkkkkkkxxxk",
]
MORION = [                  # Spanish crested steel helmet with an upturned brim
    "......kkkk......",
    ".....kglggk.....",
    "....kglllggk....",
    "kk..kgggggGk..kk",
    "kgkkgggggggGkkgk",
    ".kggkkkkkkkkggk.",
]
PLUMED_HAT = [              # a Spanish officer's wide hat with a red feather
    "..........rr....",
    "....kkkkkrrk....",
    "...kxxxxxxxk....",
    "...kxxxxxxxk....",
    ".kkxxxxxxxxxkk..",
    "kxxxxxxxxxxxxxxk",
]
SAILOR_CAP = [              # a knitted sailor's cap
    "................",
    "................",
    ".....kkkkkk.....",
    "....kTTTTTTk....",
    "...kTTTTTTTTk...",
    "..kkkkkkkkkkkk..",
]
PIRATE_BODY = [             # striped shirt, black belt, canvas trousers
    "...k1T1T1T1Tk...",
    "..ksk1T1T1Tksk..",
    "...kxxxyxxxxk...",
    "...k22k..k22k...",
    "..kBBBk..kBBBk..",
]
CAPTAIN_BODY = [            # long red coat with gold buttons
    "...kTy1111yTk...",
    "..kskT1111Tksk..",
    "...kTTxyxxTTk...",
    "...kTTk..kTTk...",
    "..kBBBk..kBBBk..",
]
SPANISH_BODY = [            # steel breastplate, buff sleeves, red sash
    "...kgllggggGk...",
    "..kskgLLLLgksk..",
    "...kTTTTTTTTk...",
    "...kTTk..kTTk...",
    "..kBBBk..kBBBk..",
]
DON_BODY = [                # black doublet with gold trim and a red sash
    "...kxyxxxxyxk...",
    "..kskxLLLLxksk..",
    "...kxyxxxxyxk...",
    "...kxxk..kxxk...",
    "..kBBBk..kBBBk..",
]
SAILOR_BODY = [             # short blue jacket, wide white trousers
    "...kTT1111TTk...",
    "..kskTT11TTksk..",
    "...kTTTTTTTTk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]
NAVY_OFFICER = [
    ".yyk1TTTTTT1kyy.",
    "..kskTyTTyTksk..",
    "...kTTTTTTTTk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]


def cutlass(g, x=14):
    g.line(x - 1, 14, x + 1, 7, "l")
    g.px(x - 2, 14, "y")
    g.px(x, 14, "y")


def pirate():
    g = person("pirate", BANDANA, PIRATE_BODY, "pirates", mustache=True, mouth="grin")
    cutlass(g)
    return g.outline()


def captain():
    g = person("captain", PIRATE_HAT, CAPTAIN_BODY, "pirates", beard="x", mouth="shout")
    for x, y, c in ((0, 2, "o"), (1, 1, "9"), (15, 2, "o"), (14, 1, "9")):
        g.px(x, y, c)                        # slow-burning fuses tucked under the hat
    g.rect(13, 13, 3, 1, "x")                # pistol
    g.px(13, 14, "B")
    return g.outline()


def buccaneer():
    g = person("buccaneer", ROUND_HAT, PIRATE_BODY, "pirates", eyes="squint", mustache=True)
    musket(g)
    return g.outline()


def grenado_thrower():
    g = Grid(18, 18)
    g.stamp(BANDANA + face(mouth="shout") + PIRATE_BODY, 0, 0)
    g.line(13, 13, 15, 6, "s")
    g.disc(16, 4, 2, "X")
    g.px(16, 1, "b")
    g.px(17, 0, "9")
    return g.outline()


def proj_grenado():
    g = Grid(7, 8)
    g.disc(3, 4, 2, "X")
    g.px(2, 3, "G")
    g.px(3, 1, "b")
    g.px(4, 0, "9")
    return g.outline()


def longboat():
    g = Grid(46, 20)
    for x in range(3, 43):
        depth = 6 if 8 < x < 38 else 4 if 5 < x < 41 else 2
        g.rect(x, 12, 1, depth, "b")
    g.rect(3, 12, 40, 1, "c")
    for x in range(6, 40, 6):
        g.rect(x, 14, 4, 1, "B")
    for x in (8, 19, 30):
        g.stamp(MINI_HEAD, x, 5)
    g.line(14, 13, 8, 19, "b")               # oars
    g.line(28, 13, 22, 19, "b")
    g.outline()
    return g


def sloop(fire=False):
    """A one-masted pirate sloop under a big sail, flying the skull and crossbones."""
    g = Grid(48, 40)
    for x in range(4, 46):
        top = 28 if x > 8 else 28 + (8 - x) // 2
        bottom = 36 if 10 < x < 42 else 34
        g.rect(x, top, 1, bottom - top, "B")
    g.rect(4, 28, 42, 1, "c")
    g.rect(6, 31, 38, 1, "y")
    for x in (14, 22, 30, 38):
        g.rect(x, 32, 3, 2, "x")             # gunports
    g.line(45, 29, 47, 24, "b")              # bowsprit
    g.rect(23, 2, 2, 26, "b")                # mast
    g.rect(13, 6, 22, 1, "b")                # yards
    g.rect(15, 16, 18, 1, "b")
    g.rect(14, 7, 20, 9, "1")                # sails
    g.rect(16, 17, 16, 10, "1")
    g.rect(14, 15, 20, 1, "2")
    g.rect(16, 26, 16, 1, "2")
    g.rect(25, 0, 8, 5, "x")                 # black flag
    g.rect(28, 1, 2, 2, "w")
    g.px(27, 3, "w")
    g.px(30, 3, "w")
    if fire:
        for x, y, c in ((15, 10, "9"), (17, 8, "y"), (20, 12, "o"), (26, 9, "9"), (29, 11, "y"), (31, 14, "9"), (18, 20, "o"),
                        (22, 22, "9"), (27, 19, "y"), (30, 23, "9"), (12, 26, "9"), (36, 25, "o"), (40, 27, "9")):
            g.rect(x, y, 2, 2, c)
            g.px(x, y - 1, "9")
    return g.outline()


def spanish_soldier():
    g = person("spanish_soldier", MORION, SPANISH_BODY, "spanish", mustache=True)
    for y in range(1, 17):
        g.px(14, y, "b")                     # halberd
    g.rect(13, 0, 3, 2, "g")
    g.px(12, 1, "g")
    return g.outline()


def spanish_musketeer():
    g = person("spanish_musketeer", MORION, SPANISH_BODY, "spanish", mustache=True, eyes="squint")
    for y in range(3, 17):
        g.px(1, y, "x")
    g.rect(0, 13, 2, 3, "b")
    return g.outline()


def spanish_captain():
    g = person("spanish_captain", PLUMED_HAT, DON_BODY, "spanish", mustache=True, droop="h")
    g.line(13, 14, 15, 6, "l")               # rapier
    g.rect(12, 14, 3, 1, "y")
    return g.outline()


def sailor():
    g = person("sailor", SAILOR_CAP, SAILOR_BODY, "navy")
    cutlass(g)
    return g.outline()


def navy_musket():
    g = person("navy_musket", SAILOR_CAP, SAILOR_BODY, "navy", eyes="squint")
    for y in range(3, 17):
        g.px(1, y, "x")
    g.rect(0, 13, 2, 3, "b")
    return g.outline()


def maynard():
    g = person("maynard", GOLD_TRICORNE, NAVY_OFFICER, "navy")
    g.line(13, 14, 15, 6, "l")
    g.rect(12, 14, 3, 1, "y")
    return g.outline()


HULL = [
    "kkkkkkkkkkkkkkkk",
    "cccccccccccccccc",
    "bbbbbbbbbbbbbbbb",
    "bbbbkkkkkkbbbbbb",
    "bbbbkXXXXkbbbbbb",
    "bbbbkXXXXkbbbbbb",
    "BBBBkkkkkkBBBBBB",
    "yyyyyyyyyyyyyyyy",
    "BBBBBBBBBBBBBBBB",
    "bbbbbbbbbbbbbbbb",
    "BBBBBBBBBBBBBBBB",
    "bbbbbbbbbbbbbbbb",
    "BBBBBBBBBBBBBBBB",
    "bbbbbbbbbbbbbbbb",
    "BBBBBBBBBBBBBBBB",
    "kkkkkkkkkkkkkkkk",
]


def hull_end(bow):
    """The pointed bow (left end) or the rounded stern (right end) of a ship's hull."""
    rows = [list(r) for r in HULL]
    for y in range(16):
        for x in range(4, 10):
            if rows[y][x] in "kX" and 2 < y < 7:
                rows[y][x] = "b" if y < 6 else "B"
        cut = int(max(0, y - 3) * (0.75 if bow else 0.45))
        for x in range(16):
            xx = x if bow else 15 - x
            if xx < cut:
                rows[y][x] = "."
            elif xx == cut:
                rows[y][x] = "k"
    return ["".join(r) for r in rows]


def sail():
    """One square sail on its yard, with the mast running through. Stack them for a tall mast."""
    g = Grid(16, 16)
    g.rect(1, 1, 14, 1, "b")                 # yard
    g.rect(2, 2, 12, 12, "1")
    g.rect(2, 12, 12, 2, "2")
    for y in range(3, 13, 3):
        g.rect(3, y, 10, 1, "8")             # canvas seams
    g.rect(7, 0, 2, 16, "b")                 # mast
    g.rect(7, 0, 1, 16, "c")
    g.outline()
    return g


def build():
    add("pirate", pirate(), "pirates")
    add("captain", captain(), "pirates")
    add("buccaneer", buccaneer(), "pirates")
    add("grenado_thrower", grenado_thrower(), "pirates")
    add("proj_grenado", proj_grenado())
    add("longboat", longboat(), "pirates")
    add("pirate_ship", sloop())
    add("pirate_fireship", sloop(fire=True))
    add("spanish_soldier", spanish_soldier(), "spanish")
    add("spanish_musketeer", spanish_musketeer(), "spanish")
    add("spanish_captain", spanish_captain(), "spanish")
    add("sailor", sailor(), "navy")
    add("navy_musket", navy_musket(), "navy")
    add("maynard", maynard(), "navy")
    add("hull", HULL)
    add("hull_bow", hull_end(True))
    add("hull_stern", hull_end(False))
    add("sail", sail())
