"""Sprites for battle pack: American Revolution (Yorktown, 1781)."""
from spritekit import *  # noqa: F401,F403

TRICORNE = [
    "................",
    "................",
    "......kkkk......",
    "..kkkkxxxxkkkk..",
    ".kxxxxxxxxxxxxk.",
    "kxxxkkkkkkkkxxxk",
]
GOLD_TRICORNE = [           # an officer's hat edged in gold lace
    "................",
    "................",
    "......kkkk......",
    "..kkkkxxxxkkkk..",
    ".kyyyyyyyyyyyyk.",
    "kxxykkkkkkkkyxxk",
]
ROUND_HAT = [               # frontier rifleman's slouch hat
    "................",
    ".....kkkkkk.....",
    "....kBBBBBBk....",
    "....kBbBBBBk....",
    ".kBBBBBBBBBBBBk.",
    ".kkkkkkkkkkkkkk.",
]
BEARSKIN = [                # tall fur cap of a British grenadier
    "....kkkkkkkk....",
    "...kxxXxxxXxk...",
    "..kxXxxxXxxxXk..",
    "..kxxxXxxxXxxk..",
    "..kxxxxyyxxxxk..",
    "..kxxxyyyyxxxk..",
    "..kxxxxyyxxxxk..",
    ".kkkkkkkkkkkkkk.",
]
CONTINENTAL = [             # blue coat, buff lapels, white waistcoat and breeches
    "...kTL1111LTk...",
    "..kskTL11LTksk..",
    "...kT111111Tk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]
HUNTING_SHIRT = [           # fringed linen hunting shirt
    "...k22222222k...",
    "..ksk212212ksk..",
    "...k2B2222B2k...",
    "...kBBk..kBBk...",
    "..kBBBk..kBBBk..",
]
REDCOAT = [                 # red coat with white crossbelts
    "...k1TTTTTT1k...",
    "..kskT1TT1Tksk..",
    "...kTTT11TTTk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]
GENERAL = [                 # gold epaulettes and buttons
    ".yyk1TTTTTT1kyy.",
    "..kskT1yy1Tksk..",
    "...kTTT11TTTk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]


def musket(g, x=14, top=2, bayonet=False):
    for y in range(top, 13):
        g.px(x, y, "x")
    for y in range(13, 17):
        g.px(x, y, "b")
    g.px(x + 1, 15, "b")
    g.px(x + 1, 16, "b")
    if bayonet:
        g.rect(x, top - 3, 1, 3, "g")


def minuteman():
    g = person("minuteman", TRICORNE, CONTINENTAL, "continental")
    musket(g)
    return g.outline()


def light_infantry():
    g = Grid(20, 18)
    g.stamp(TRICORNE + face(mouth="shout") + CONTINENTAL, 0, 0)
    g.line(8, 15, 16, 9, "b")
    g.line(16, 9, 19, 7, "g")
    return g.outline()


def frontiersman():
    g = person("frontiersman", ROUND_HAT, HUNTING_SHIRT, "continental", eyes="squint")
    musket(g, top=0)
    return g.outline()


def cannon(barrel="V", ring="W"):
    g = Grid(32, 18)
    g.line(10, 13, 0, 17, "b", 2)
    g.rect(6, 8, 14, 4, "b")
    g.rect(8, 5, 21, 4, barrel)
    g.rect(8, 5, 21, 1, "y" if barrel == "V" else "G")
    g.rect(28, 4, 2, 6, ring)
    g.rect(6, 6, 2, 2, ring)
    g.disc(12, 12, 5, "B")
    for dx, dy in ((0, -4), (0, 4), (-4, 0), (4, 0), (3, 3), (-3, -3), (3, -3), (-3, 3)):
        g.px(12 + dx, 12 + dy, "b")
    g.disc(12, 12, 1, "X")
    return g.outline()


def british_cannon():
    g = cannon("X", "G")
    g.stamp(MINI_HEAD, 2, 0)
    return g.mirror()


def mortar_1781():
    g = Grid(20, 16)
    g.rect(1, 10, 16, 4, "b")
    g.rect(1, 10, 16, 1, "c")
    g.line(5, 11, 11, 4, "V", 4)
    g.rect(10, 2, 5, 3, "X")
    g.disc(17, 12, 2, "X")
    g.px(18, 9, "y")
    g.px(19, 8, "9")
    return g.outline()


def powder_wagon():
    g = Grid(40, 24)
    g.rect(2, 13, 34, 3, "b")
    g.rect(2, 13, 34, 1, "c")
    g.line(36, 14, 39, 16, "b")
    for i, bx in enumerate((5, 15, 25)):
        g.rect(bx, 3, 9, 10, "b")
        g.rect(bx - 1, 5, 11, 6, "b")
        for y in (4, 7, 10):
            g.rect(bx - 1, y, 11, 1, "X")
        g.rect(bx + 2, 6, 5, 1, "w")
    g.rect(16, 0, 1, 3, "c")
    g.px(16, 0, "y")
    g.px(17, 0, "9")
    for cx in (9, 29):
        g.disc(cx, 19, 4, "B")
        for dx, dy in ((0, -3), (0, 3), (-3, 0), (3, 0)):
            g.px(cx + dx, 19 + dy, "b")
        g.px(cx, 19, "X")
    return g.outline()


def redcoat():
    g = person("redcoat", TRICORNE, REDCOAT, "redcoats")
    musket(g, bayonet=True)
    return g.outline()


def grenadier_1781():
    g = from_rows("grenadier_1781", BEARSKIN + face() + REDCOAT)
    for y in range(4, 15):
        g.px(14, y, "x")
    for y in range(15, 19):
        g.px(14, y, "b")
    g.rect(14, 1, 1, 3, "g")
    return g.outline()


def cornwallis():
    g = person("cornwallis", GOLD_TRICORNE, GENERAL, "redcoats", flare="l")
    for y in range(9, 17):
        g.px(14, y, "g")
    g.rect(13, 13, 3, 1, "y")
    return g.outline()


def proj_cannonball():
    g = Grid(8, 8)
    g.disc(4, 4, 2, "X")
    g.px(3, 3, "G")
    return g.outline()


def proj_mortarshell():
    g = Grid(10, 10)
    g.disc(5, 6, 3, "X")
    g.px(4, 5, "G")
    g.px(5, 2, "c")
    g.px(5, 1, "y")
    g.px(6, 0, "9")
    return g.outline()


def proj_rifleball():
    g = Grid(8, 3)
    g.rect(0, 1, 5, 1, "l")
    g.rect(5, 0, 2, 3, "G")
    return g


def earth():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "z")
    g.rect(1, 1, 14, 3, "a")
    g.rect(1, 1, 14, 1, "e")
    for x, y in ((3, 7), (9, 6), (12, 10), (5, 12), (8, 9), (2, 11)):
        g.rect(x, y, 2, 1, "Z")
    return g


def gabion():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "b")
    for y in range(2, 15, 2):
        for x in range(1, 15):
            if (x + y // 2) % 3 == 0:
                g.px(x, y, "B")
    for x in range(2, 15, 3):
        g.rect(x, 1, 1, 14, "B")
    g.rect(1, 1, 14, 2, "z")
    return g


def fascine():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    for y in range(1, 15):
        g.rect(1, y, 14, 1, "b" if y % 2 else "F")
    for x in (4, 11):
        g.rect(x, 1, 1, 14, "c")
    return g


def abatis():
    g = Grid(16, 14)
    g.line(15, 13, 1, 3, "b", 2)
    g.line(15, 9, 3, 1, "b", 2)
    g.line(14, 13, 6, 9, "B", 2)
    for x, y in ((0, 2), (2, 0), (5, 8)):
        g.px(x, y, "c")
    return g.outline()


def keg():
    g = Grid(16, 16)
    g.rect(3, 3, 10, 12, "b")
    g.rect(2, 5, 12, 8, "b")
    g.rect(3, 3, 10, 1, "c")
    for y in (5, 12):
        g.rect(2, y, 12, 1, "X")
    g.rect(5, 7, 6, 4, "1")
    g.px(7, 8, "x")
    g.px(8, 8, "x")
    g.px(7, 9, "x")
    g.px(8, 9, "x")
    g.rect(7, 1, 1, 2, "c")
    g.px(7, 0, "9")
    return g.outline()


def build():
    add("minuteman", minuteman(), "continental", pal={"T": "#7a5634", "t": "#553a21", "L": "#dcc58f"})
    add("light_infantry", light_infantry(), "continental")
    add("frontiersman", frontiersman(), "continental")
    add("cannon", cannon(), "continental")
    add("british_cannon", british_cannon(), "redcoats")
    add("mortar_1781", mortar_1781(), "continental")
    add("powder_wagon", powder_wagon(), "continental")
    add("redcoat", redcoat(), "redcoats")
    add("grenadier_1781", grenadier_1781(), "redcoats")
    add("cornwallis", cornwallis(), "redcoats")
    add("proj_cannonball", proj_cannonball())
    add("proj_mortarshell", proj_mortarshell())
    add("proj_rifleball", proj_rifleball())
    add("earth", earth())
    add("gabion", gabion())
    add("fascine", fascine())
    add("abatis", abatis())
    add("keg", keg())
