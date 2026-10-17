"""Sprites for battle pack: Napoleon (Ratisbon 1809, Waterloo 1815)."""
from spritekit import *  # noqa: F401,F403
from sprites_revolution import BEARSKIN  # noqa: F401

SHAKO = [                   # tall French shako with a brass plate and pompom
    "......kyyk......",
    ".....kkkkkk.....",
    "....kxxxxxxk....",
    "....kxxyyxxk....",
    "....kxxyyxxk....",
    "..kkkkkkkkkkkk..",
]
STOVEPIPE = [               # British 1815 shako with a raised front
    "....kkkkkkkk....",
    "...kxxxxxxxxk...",
    "...kxxxxxxxxk...",
    "...kxxxyyxxxk...",
    "...kxxxxxxxxk...",
    "..kkkkkkkkkkkk..",
]
BICORNE = [                 # officer's two-cornered hat
    "................",
    "................",
    "..kk........kk..",
    ".kxxkkkkkkkkxxk.",
    ".kxxxxxyyxxxxxk.",
    "..kkkkkkkkkkkk..",
]
HELMET_1809 = [             # Austrian leather helmet with a crest
    "......kkkk......",
    ".....kyyyyk.....",
    "....kxxxxxxk....",
    "...kxxxyyxxxk...",
    "...kxxxxxxxxk...",
    "..kkkkkkkkkkkk..",
]
CUIRASSIER_HELMET = [       # steel helmet with a horsehair crest
    "....kkkkk.......",
    "...kxxxxxkk.....",
    "....kgggglkk....",
    "...kglllgggGk...",
    "..kglggggggGGk..",
    ".kkkkkkkkkkkkkk.",
]
FRENCH_BODY = [             # blue coat, white lapels, white trousers
    "...kTL1111LTk...",
    "..kskTL11LTksk..",
    "...kT111111Tk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]
SAPPER_BODY = [             # sapper's white leather apron
    "...kTL1111LTk...",
    "..kskT1111Tksk..",
    "...kT111111Tk...",
    "...k11k..k11k...",
    "..kxxxk..kxxxk..",
]
REDCOAT_1815 = [
    "...k1TTTTTT1k...",
    "..kskT1TT1Tksk..",
    "...kTTT11TTTk...",
    "...kxxk..kxxk...",
    "..kxxxk..kxxxk..",
]
OFFICER_1815 = [
    ".yyk1TTTTTT1kyy.",
    "..kskT1yy1Tksk..",
    "...kTTT11TTTk...",
    "...kxxk..kxxk...",
    "..kxxxk..kxxxk..",
]


def voltigeur():
    g = person("voltigeur", SHAKO, FRENCH_BODY, "french", mustache=True)
    for y in range(2, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.rect(14, 0, 1, 2, "g")
    return g.outline()


def guard_grenadier():
    g = from_rows("guard_grenadier", BEARSKIN + face(mustache=True) + FRENCH_BODY)
    for y in range(4, 15):
        g.px(14, y, "x")
    for y in range(15, 19):
        g.px(14, y, "b")
    g.rect(14, 1, 1, 3, "g")
    g.rect(5, 4, 6, 3, "y")                  # brass plate on the bearskin
    return g.outline()


def sapper():
    """Sapeurs wore beards and leather aprons and carried axes, like Legros at Hougoumont."""
    g = Grid(18, 20)
    g.stamp(BEARSKIN + face(beard="h") + SAPPER_BODY, 0, 0)
    g.line(14, 18, 14, 6, "b")
    g.rect(13, 4, 4, 4, "g")
    g.px(17, 5, "g")
    return g.outline()


def cuirassier():
    """Heavy cavalry trooper in a steel breastplate."""
    g = Grid(40, 34)
    g.ellipse(20, 23, 13, 5, "b")            # horse body
    g.rect(31, 13, 5, 10, "b")               # neck
    g.rect(32, 10, 7, 5, "b")                # head
    g.rect(37, 12, 2, 2, "B")
    g.px(35, 11, "k")
    g.rect(30, 10, 2, 9, "B")                # mane
    for x in (10, 14, 26, 30):
        g.rect(x, 27, 2, 6, "b")
        g.rect(x, 32, 2, 1, "x")
    g.rect(5, 19, 3, 8, "B")                 # tail
    g.rect(15, 18, 10, 3, "T")               # saddle cloth
    g.stamp(CUIRASSIER_HELMET + face(mustache=True, mouth="shout"), 12, 0)
    g.rect(15, 13, 10, 4, "g")               # breastplate
    g.rect(15, 13, 10, 1, "l")
    g.line(26, 14, 34, 6, "l")               # sabre
    return g.outline()


def guardsman():
    g = person("guardsman", STOVEPIPE, REDCOAT_1815, "redcoats")
    for y in range(4, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.rect(14, 1, 1, 3, "g")
    return g.outline()


def green_rifleman():
    g = person("green_rifleman", STOVEPIPE, REDCOAT_1815, "redcoats", eyes="squint")
    for y in range(4, 17):
        g.px(1, y, "x")
    g.px(1, 3, "x")
    return g.outline().mirror()


def austrian():
    g = person("austrian", HELMET_1809, REDCOAT_1815, "redcoats")
    for y in range(4, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.rect(14, 1, 1, 3, "g")
    return g.outline()


def officer_1815():
    g = person("officer_1815", BICORNE, OFFICER_1815, "redcoats", mustache=True)
    for y in range(9, 17):
        g.px(14, y, "g")
    g.rect(13, 13, 3, 1, "y")
    return g.outline()


def brick():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "u")
    for row, y in enumerate(range(1, 15, 4)):
        off = 0 if row % 2 == 0 else -4
        for x in range(off, 16, 8):
            x0, x1 = max(1, x + 1), min(15, x + 7)
            if x1 > x0:
                g.rect(x0, y, x1 - x0, 2, "q")
                g.rect(x0, y + 2, x1 - x0, 1, "Q")
    g.rect(6, 6, 4, 2, "k")                  # loophole for firing through
    return g


def hedge():
    g = Grid(16, 16)
    g.ellipse(8, 9, 7, 6, "j")
    g.rect(1, 9, 14, 6, "j")
    for x, y in ((3, 6), (7, 4), (11, 6), (5, 10), (10, 11), (13, 9), (2, 12), (8, 8)):
        g.px(x, y, "e")
        g.px(x + 1, y + 1, "A")
    return g.outline()


def tiles():
    """Red clay roof tiles, used as the long slab on farm buildings."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 8, "k")
    g.rect(0, 1, 16, 6, "q")
    for x in range(0, 16, 4):
        g.rect(x, 1, 1, 6, "Q")
    g.rect(0, 1, 16, 1, "r")
    return g


def build():
    add("voltigeur", voltigeur(), "french")
    add("guard_grenadier", guard_grenadier(), "french")
    add("sapper", sapper(), "french")
    add("cuirassier", cuirassier(), "french")
    add("guardsman", guardsman(), "redcoats")
    add("green_rifleman", green_rifleman(), "redcoats", pal={"T": "#2f4a2a", "t": "#1f3320", "1": "#111111"})
    add("austrian", austrian(), "redcoats", pal={"T": "#efe9d8", "t": "#c9c3b2", "1": "#b8322a"})
    add("officer_1815", officer_1815(), "redcoats")
    variant("baring", "officer_1815", pal={"T": "#2f4a2a", "t": "#1f3320", "1": "#111111"})
    variant("austrian_general", "officer_1815", pal={"T": "#efe9d8", "t": "#c9c3b2", "1": "#b8322a"})
    add("brick", brick())
    add("hedge", hedge())
    add("tiles", tiles())
