"""Sprites for battle pack: Castle Siege (England vs. Scotland, 1300-1304)."""
from spritekit import *  # noqa: F401,F403

KETTLE_HAT = [              # wide-brimmed steel helmet
    ".....kkkkkk.....",
    "....kglggggk....",
    "...kgllggggGk...",
    "...kgggggggGk...",
    "kkkGGGGGGGGGGkkk",
    ".kkkkkkkkkkkkkk.",
]
GREAT_HELM = [              # flat-topped knight's helm, eyes peering through the slit
    "......krrk......",
    "....kkkkkkkk....",
    "...kgllggggGk...",
    "..kglgggggggGk..",
    "..kglgggggggGk..",
    "..kgggggggggGk..",
    "..kGGGGGGGGGGk..",
    "..kkkwkkkkwkkk..",
    "..kgggggggggGk..",
    "..kggkgkgkgkGk..",
    "..kgggggggggGk..",
    "..kgggggggggGk..",
    "...kgggggggGk...",
    "...kkkkkkkkkk...",
]
ARCHER_CAP = [
    "................",
    ".....kkkkkk.....",
    "....keeeeeek....",
    "...keeeeeeeek...",
    "...keeeeeeeekrk.",
    ".kkkkkkkkkkkkkk.",
]
COMMANDER_HAT = [           # blue cap with a white plume
    "..........kLk...",
    "....kkkkkkkLk...",
    "...kTTTTTTTTkk..",
    "..kTTLTTTTTTTk..",
    ".kTTTTTTTTTTTTk.",
    ".kkkkkkkkkkkkkk.",
]

SURCOAT = [                 # white surcoat with the red cross of St George
    "...kLLLTTLLLk...",
    "..kskTTTTTTksk..",
    "...kLLLTTLLLk...",
    "...kGGk..kGGk...",
    "..kBBBk..kBBBk..",
]
KNIGHT_SURCOAT = [
    "...kLLLTTLLLk...",
    "..kgkTTTTTTkgk..",
    "...kLLLTTLLLk...",
    "...kGGk..kGGk...",
    "..kBBBk..kBBBk..",
]
ARCHER_JERKIN = [
    "...kbbbTTbbbk...",
    "..kskTTTTTTksk..",
    "...kbbbTTbbbk...",
    "...kBBk..kBBk...",
    "..kBBBk..kBBBk..",
]
SALTIRE = [                 # blue tunic with the white saltire of St Andrew
    "...kLTTTTTTLk...",
    "..kskTLTTLTksk..",
    "...kTTTLLTTTk...",
    "...kGGk..kGGk...",
    "..kBBBk..kBBBk..",
]


def footman():
    g = person("footman", KETTLE_HAT, SURCOAT, "english", flare="G")
    for y in range(9, 17):
        g.px(14, y, "g")
    g.rect(13, 13, 3, 1, "B")
    return g.outline()


def knight():
    g = Grid(22, 19)
    g.stamp(GREAT_HELM + KNIGHT_SURCOAT, 0, 0)
    g.rect(9, 15, 11, 1, "b")              # lance
    g.rect(9, 14, 2, 3, "g")               # hand guard
    g.px(20, 15, "g")
    g.px(21, 15, "G")
    return g.outline()


def longbowman():
    g = Grid(18, 18)
    g.stamp(ARCHER_CAP + face() + ARCHER_JERKIN, 0, 0)
    for x, y in ((14, 0), (15, 1), (16, 2), (16, 3)):
        g.px(x, y, "b")
    for y in range(4, 14):
        g.px(16, y, "b")
    for x, y in ((16, 14), (15, 15), (14, 16)):
        g.px(x, y, "b")
    for y in range(1, 16):
        g.px(14, y, "l")
    return g.outline()


def warwolf():
    """The Warwolf, Edward I's giant trebuchet, cocked and ready."""
    g = Grid(38, 36)
    g.rect(0, 32, 36, 3, "b")
    g.rect(0, 32, 36, 1, "c")
    g.line(5, 32, 15, 8, "B", 2)
    g.line(26, 32, 16, 8, "B", 2)
    g.rect(11, 20, 10, 2, "b")
    g.line(16, 9, 4, 30, "b", 2)            # long throwing arm, pulled down
    g.line(16, 9, 24, 3, "b", 2)            # short arm up
    g.rect(21, 0, 9, 8, "B")                # counterweight box
    g.rect(21, 2, 9, 1, "X")
    g.rect(21, 5, 9, 1, "X")
    g.disc(16, 9, 1, "X")
    g.line(4, 30, 9, 31, "c")
    g.disc(10, 30, 2, "n")
    return g.outline()


def siege_tower():
    """Tall enough to look over the castle walls."""
    g = Grid(30, 66)
    g.rect(3, 6, 22, 55, "b")
    for y in range(12, 61, 6):
        g.rect(3, y, 22, 1, "B")
    g.rect(3, 6, 22, 11, "C")
    g.rect(3, 6, 22, 1, "c")
    for x in range(3, 25, 4):
        g.rect(x, 3, 2, 3, "b")
    g.rect(24, 2, 3, 16, "B")               # drawbridge, folded up
    g.rect(25, 3, 1, 14, "b")
    for wy in (22, 36, 48):
        g.rect(9, wy, 10, 4, "x")
        g.px(12, wy + 2, "w")
        g.px(16, wy + 2, "w")
    for cx in (8, 20):
        g.disc(cx, 62, 3, "B")
        g.px(cx, 62, "c")
    return g.outline()


def spearman():
    g = person("spearman", KETTLE_HAT, SALTIRE, "scots", flare="G")
    for y in range(2, 17):
        g.px(14, y, "b")
    g.rect(14, 0, 1, 2, "g")
    g.px(13, 1, "g")
    g.px(15, 1, "g")
    return g.outline()


def crossbowman():
    g = Grid(18, 18)
    g.stamp(KETTLE_HAT + face(flare="G", eyes="squint") + SALTIRE, 2, 0)
    g.rect(0, 14, 8, 1, "b")
    g.rect(1, 12, 1, 5, "G")
    g.px(0, 12, "G")
    g.px(0, 16, "G")
    return g.outline()


def cauldron():
    g = Grid(18, 16)
    g.line(3, 15, 6, 8, "X")
    g.line(14, 15, 11, 8, "X")
    g.ellipse(9, 8, 6, 4, "X")
    g.rect(3, 5, 12, 2, "G")
    g.rect(4, 5, 10, 1, "o")
    for x, y, c in ((6, 3, "l"), (9, 2, "l"), (12, 3, "l"), (7, 1, "l"), (11, 0, "l")):
        g.px(x, y, c)
    for x, y, c in ((7, 13, "9"), (9, 12, "y"), (11, 13, "9"), (8, 14, "y"), (10, 14, "9")):
        g.px(x, y, c)
    return g.outline()


def commander():
    g = person("commander", COMMANDER_HAT, SALTIRE, "scots", mustache=True)
    for y in range(9, 17):
        g.px(14, y, "g")
    g.rect(13, 13, 3, 1, "y")
    return g.outline()


def stone():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "n")
    for y in (5, 10):
        g.rect(1, y, 14, 1, "N")
    for x, y0 in ((8, 1), (4, 6), (12, 6), (8, 11)):
        g.rect(x, y0, 1, 4, "N")
    for x0, y0 in ((1, 1), (9, 1), (1, 6), (5, 6), (13, 6), (1, 11), (9, 11)):
        g.rect(x0, y0, 3, 1, "m")
    g.rect(14, 1, 1, 14, "N")
    return g


def merlon():
    g = stone()
    g.rect(5, 0, 6, 6, ".")
    g.rect(4, 0, 1, 6, "k")
    g.rect(11, 0, 1, 6, "k")
    g.rect(5, 6, 6, 1, "k")
    return g


def door():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "b")
    for x in (4, 8, 12):
        g.rect(x, 1, 1, 14, "B")
    for y in (3, 11):
        g.rect(1, y, 14, 2, "X")
        for x in (3, 7, 11):
            g.px(x, y, "G")
    g.px(10, 8, "G")
    g.px(10, 7, "X")
    return g


def portcullis():
    g = Grid(16, 16)
    for x in (1, 5, 9, 13):
        g.rect(x, 0, 2, 14, "X")
        g.px(x, 14, "X")
    for y in (2, 7, 12):
        g.rect(0, y, 16, 2, "X")
    for x in (2, 6, 10, 14):
        g.rect(x - 1, 15, 2, 1, "G")
    g.rect(0, 0, 16, 1, "G")
    return g.outline()


def barrel():
    g = Grid(16, 16)
    g.rect(3, 1, 10, 14, "b")
    g.rect(2, 3, 12, 10, "b")
    g.rect(3, 1, 10, 1, "c")
    for y in (3, 7, 12):
        g.rect(2, y, 12, 1, "X")
    g.rect(6, 5, 4, 1, "B")
    g.rect(6, 9, 4, 1, "B")
    return g.outline()


def build():
    add("footman", footman(), "english")
    add("knight", knight(), "english")
    add("longbowman", longbowman(), "english")
    add("warwolf", warwolf(), "english")
    add("siege_tower", siege_tower(), "english")
    add("spearman", spearman(), "scots")
    add("crossbowman", crossbowman(), "scots")
    add("cauldron", cauldron(), "scots")
    add("commander", commander(), "scots")
    add("stone", stone())
    add("merlon", merlon())
    add("door", door())
    add("portcullis", portcullis())
    add("barrel", barrel())
