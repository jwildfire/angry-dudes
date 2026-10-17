"""Sprites for battle pack: World War I (U.S. Army vs. German Army, 1918)."""
from spritekit import *  # noqa: F401,F403
from sprites_ww2 import DE_HELMET, OFFICER_BODY, US_HELMET  # noqa: F401

BRODIE = [                  # the flat "soup bowl" helmet Americans wore in 1918
    "................",
    "................",
    "....kkkkkkkk....",
    "...kTLTTTTTTk...",
    "kkkTTTTTTTTTTkkk",
    ".kkkkkkkkkkkkkk.",
]
PICKELHAUBE = [             # spiked leather helmet with a brass plate
    ".......kk.......",
    "......kyyk......",
    ".....kkyykk.....",
    "...kkxxyyxxkk...",
    "..kxxxyyyyxxxk..",
    ".kkkkkkkkkkkkkk.",
]
DOUGHBOY = [                # wool tunic, cartridge belt, wrapped puttees
    "...kTTTTTTTTk...",
    "..kskTTyTTTksk..",
    "...kcCccccCck...",
    "...ktak..katk...",
    "..kBBBk..kBBBk..",
]
LANDSER = [                 # German field-gray tunic and jackboots
    "...kTTTTTTTTk...",
    "..kskTgTTgTksk..",
    "...kxxxggxxxk...",
    "...kttk..kttk...",
    "..kxxxk..kxxxk..",
]


def doughboy():
    g = person("doughboy", BRODIE, DOUGHBOY, "doughboys")
    for y in range(3, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.px(15, 15, "b")
    g.px(15, 16, "b")
    g.rect(14, 0, 1, 3, "g")                # bayonet
    return g.outline()


def marine():
    g = Grid(20, 18)
    g.stamp(BRODIE + face(mouth="shout") + DOUGHBOY, 0, 0)
    g.line(8, 15, 16, 9, "b")
    g.line(16, 9, 19, 7, "g")
    return g.outline()


def bomber():
    g = Grid(18, 18)
    g.stamp(BRODIE + face(mouth="shout") + DOUGHBOY, 0, 0)
    g.line(13, 13, 15, 5, "s")
    g.line(14, 13, 16, 6, "s")
    g.stamp(["kGk", "GgG", "GGG", "kGk"], 14, 1)
    return g.outline()


def tunneler():
    g = person("tunneler", BRODIE, DOUGHBOY, "doughboys", eyes="squint")
    for y in range(6, 16):
        g.px(14, y, "b")
    g.rect(13, 15, 3, 3, "g")               # shovel blade
    g.rect(1, 12, 2, 3, "y")                # lamp
    g.px(1, 11, "x")
    return g.outline()


def french75():
    g = Grid(40, 22)
    g.line(12, 14, 0, 20, "b", 2)
    g.rect(10, 9, 12, 3, "G")
    g.rect(16, 3, 3, 13, "G")
    g.rect(16, 3, 3, 1, "g")
    g.line(18, 9, 38, 7, "x", 2)
    g.rect(37, 6, 2, 3, "x")
    g.disc(14, 15, 6, "B")
    for dx, dy in ((0, -5), (0, 5), (-5, 0), (5, 0), (4, 4), (-4, -4), (4, -4), (-4, 4)):
        g.px(14 + dx, 15 + dy, "b")
    g.disc(14, 15, 1, "X")
    return g.outline()


def renault():
    """Renault FT, the first tank with a turret that turned all the way around."""
    g = Grid(42, 26)
    g.rect(4, 17, 32, 6, "x")
    g.disc(34, 18, 4, "x")
    g.disc(34, 18, 2, "G")
    for cx in (9, 15, 21, 27):
        g.disc(cx, 21, 1, "G")
    g.rect(4, 17, 30, 1, "G")
    g.rect(6, 10, 26, 7, "a")
    g.line(31, 10, 37, 15, "a", 2)
    g.rect(6, 10, 26, 1, "e")
    g.line(0, 21, 5, 17, "A", 2)            # tail skid for crossing trenches
    g.rect(15, 3, 11, 7, "a")
    g.rect(16, 2, 9, 1, "a")
    g.rect(16, 3, 9, 1, "e")
    g.rect(19, 5, 5, 1, "k")                # vision slit
    g.rect(26, 6, 8, 2, "x")
    g.stamp(["..w..", "wwwww", ".www.", ".w.w."], 9, 12)
    return g.outline()


def spad():
    """SPAD XIII biplane with the 1918 U.S. roundel and rudder stripes."""
    g = Grid(40, 18)
    g.ellipse(18, 9, 15, 3, "c")
    g.rect(3, 6, 4, 7, "c")
    g.rect(1, 4, 3, 3, "w")
    g.rect(1, 4, 1, 3, "U")
    g.rect(3, 4, 1, 3, "r")
    g.rect(9, 3, 22, 2, "e")                # upper wing
    g.rect(11, 13, 18, 2, "e")              # lower wing
    for x in (13, 26):
        g.rect(x, 5, 1, 8, "B")
    g.disc(20, 9, 2, "r")
    g.disc(20, 9, 1, "U")
    g.px(20, 9, "w")
    g.rect(24, 5, 3, 2, "B")                # pilot
    g.px(25, 5, "s")
    g.rect(33, 7, 2, 4, "x")
    g.outline()
    for y in range(1, 17, 2):
        g.px(37, y, "G")
    return g


def york():
    """Sgt. Alvin York: a crack shot from the Tennessee hills, with a red mustache."""
    g = person("york", BRODIE, DOUGHBOY, "doughboys", mustache="7", eyes="squint")
    for y in range(1, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.px(15, 15, "b")
    g.px(15, 16, "b")
    return g.outline()


def rock():
    g = Grid(16, 16)
    g.ellipse(8, 9, 7, 6, "p")
    g.rect(2, 9, 12, 6, "p")
    g.ellipse(6, 7, 3, 2, "i")
    for x, y in ((10, 11), (11, 12), (4, 13), (12, 8)):
        g.px(x, y, "P")
    g.rect(1, 14, 14, 1, "P")
    return g.outline()


def landser():
    hat = [r for r in DE_HELMET]
    g = from_rows("landser", hat + face(stahl=True) + LANDSER)
    g.px(1, 4, "g")
    g.px(14, 4, "g")                        # helmet lugs
    for y in range(4, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.rect(14, 1, 1, 3, "g")
    return g.outline()


def mg08():
    """Water-cooled Maxim machine gun on a sled, behind sandbags."""
    g = Grid(30, 16)
    g.stamp(DE_HELMET + face(stahl=True), 2, 0)
    g.rect(0, 9, 30, 7, ".")
    for course, y in enumerate((9, 13)):
        off = 0 if course == 0 else 4
        for bx in range(-8, 30, 8):
            x = bx + off
            g.rect(x + 1, y, 6, 2, "c")
            g.rect(x + 1, y + 2, 6, 1, "C")
    g.rect(14, 7, 5, 3, "x")
    g.rect(19, 6, 8, 3, "G")                # fat water jacket
    g.rect(19, 6, 8, 1, "g")
    g.rect(27, 7, 3, 1, "x")
    g.px(12, 9, "s")
    return g.outline().mirror()


def balloon():
    """Drachen observation balloon with an observer in the basket."""
    g = Grid(36, 26)
    g.ellipse(19, 7, 15, 6, "c")
    for x in range(8, 32, 5):
        g.recolor(x, 0, 1, 14, "c", "C")
    g.ellipse(6, 10, 4, 3, "C")             # tail lobe
    g.rect(13, 1, 12, 1, "2")
    g.line(12, 13, 16, 19, "x")
    g.line(26, 13, 22, 19, "x")
    g.rect(15, 19, 8, 5, "b")
    g.rect(15, 19, 8, 1, "c")
    g.stamp(MINI_HEAD, 15, 13)
    return g.outline().mirror()


def minenwerfer():
    g = Grid(24, 16)
    g.rect(2, 11, 18, 3, "b")
    g.disc(6, 13, 3, "B")
    g.disc(16, 13, 3, "B")
    g.line(9, 11, 15, 3, "X", 4)
    g.rect(14, 1, 5, 3, "x")
    g.stamp(MINI_HEAD, 0, 4)
    return g.outline().mirror()


def kaiser_officer():
    g = person("kaiser_officer", PICKELHAUBE, OFFICER_BODY, "kaiser", mustache=True)
    g.px(3, 8, "h")
    g.px(12, 8, "h")                        # waxed, turned-up mustache tips
    return g.outline()


def tin():
    """Corrugated iron, used for dugout roofs."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    for x in range(1, 15):
        g.rect(x, 1, 1, 14, "lgGg"[x % 4])
    g.rect(1, 14, 14, 1, "W")
    return g


def shellcrate():
    g = Grid(16, 16)
    g.rect(0, 2, 16, 14, "k")
    g.rect(1, 3, 14, 12, "b")
    g.rect(1, 3, 14, 1, "c")
    for x in (3, 7, 11):
        g.rect(x, 0, 2, 5, "V")
        g.rect(x, 0, 2, 1, "y")
    g.rect(1, 9, 14, 1, "B")
    g.rect(5, 11, 6, 2, "r")
    return g


def build():
    add("doughboy", doughboy(), "doughboys")
    add("marine", marine(), "doughboys")
    add("bomber", bomber(), "doughboys")
    add("tunneler", tunneler(), "doughboys")
    add("french75", french75(), "doughboys")
    add("renault", renault(), "doughboys")
    add("spad", spad(), "doughboys")
    add("york", york(), "doughboys")
    add("rock", rock())
    add("landser", landser(), "kaiser")
    add("mg08", mg08(), "kaiser")
    add("balloon", balloon(), "kaiser")
    add("minenwerfer", minenwerfer(), "kaiser")
    add("kaiser_officer", kaiser_officer(), "kaiser")
    add("tin", tin())
    add("shellcrate", shellcrate())
