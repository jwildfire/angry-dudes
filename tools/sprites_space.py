"""Sprites for battle pack: Space Battle (the future: Star Marines vs. the Robot Legion)."""
from spritekit import *  # noqa: F401,F403

SPACE_HELMET = [
    ".....kkkkkk.....",
    "...kkTTTTTTkk...",
    "..kTTTTLLTTTTk..",
    ".kTTTTTTTTTTTTk.",
    ".kTvvvvvvvvvvTk.",
    "kTvkkkkkkkkkkvTk",
]
SUIT = [                    # white space suit with an orange chest stripe
    "..kTTTLLLLTTTk..",
    ".kTkTTTyyTTTkTk.",
    "..kTTTTTTTTTTk..",
    "...kTTk..kTTk...",
    "..kGGGk..kGGGk..",
]
ROBOT = [
    ".......kk.......",
    "......krrk......",
    "....kkkkkkkk....",
    "...kTTTTTTTTk...",
    "...kTkkkkkkTk...",
    "...kTkrrrrkTk...",
    "...kTkkkkkkTk...",
    "...kTTTTTTTTk...",
    "...kTtTtTtTTk...",
    "....kkkkkkkk....",
    "..kkTTTTTTTTkk..",
    ".kTkTTLLLLTTkTk.",
    ".kTkTTTTTTTTkTk.",
    ".kGkTTTTTTTTkGk.",
    "...kTTk..kTTk...",
    "...kTTk..kTTk...",
    "..kGGGk..kGGGk..",
    "..kkkkk..kkkkk..",
]


def spaceman(name, **opts):
    return person(name, SPACE_HELMET, SUIT, "marines", flare="T", **opts)


def marine():
    g = spaceman("marine", mouth="grin")
    g.rect(13, 13, 3, 2, "x")                # blaster
    g.px(15, 13, "4")
    return g.outline()


def jetpacker():
    g = Grid(19, 21)
    g.stamp(SPACE_HELMET + face(flare="T", mouth="shout") + SUIT, 3, 0)
    g.rect(0, 7, 4, 9, "G")                  # jetpack
    g.rect(1, 8, 1, 7, "g")
    g.rect(0, 16, 1, 2, "9")
    g.rect(2, 16, 1, 2, "9")
    g.px(0, 18, "o")
    g.px(2, 18, "y")
    g.px(1, 19, "o")
    return g.outline()


def power_suit():
    """A big armored power suit, heavy enough to stomp straight down."""
    g = Grid(22, 22)
    g.stamp(SPACE_HELMET + face(flare="T", mouth="shout"), 3, 0)
    g.rect(2, 13, 18, 6, "T")                # chest armor
    g.rect(0, 12, 5, 5, "L")                 # shoulder pads
    g.rect(17, 12, 5, 5, "L")
    g.rect(8, 14, 6, 2, "4")                 # power core
    g.rect(4, 19, 5, 3, "G")                 # big boots
    g.rect(13, 19, 5, 3, "G")
    g.rect(0, 17, 3, 3, "G")                 # fists
    g.rect(19, 17, 3, 3, "G")
    return g.outline()


def laser_gunner():
    g = Grid(26, 18)
    g.stamp(SPACE_HELMET + face(flare="T", eyes="squint") + SUIT, 0, 0)
    g.rect(10, 12, 13, 2, "G")               # laser rifle
    g.rect(12, 11, 5, 1, "x")
    g.rect(22, 12, 2, 2, "4")
    g.px(24, 12, "w")
    return g.outline()


def plasma_gunner():
    g = Grid(18, 18)
    g.stamp(SPACE_HELMET + face(flare="T", mouth="shout") + SUIT, 0, 0)
    g.line(13, 13, 15, 6, "T")
    g.disc(16, 4, 2, "3")
    g.px(16, 4, "w")
    return g.outline()


def proj_laser():
    g = Grid(14, 4)
    g.rect(0, 1, 14, 2, "4")
    g.rect(2, 1, 11, 1, "w")
    return g


def proj_plasma():
    g = Grid(9, 9)
    g.disc(4, 4, 3, "3")
    g.disc(4, 4, 1, "w")
    return g.outline("A")


def rover():
    """A six-wheeled moon rover with a laser turret."""
    g = Grid(46, 26)
    g.rect(4, 13, 38, 6, "T")
    g.rect(4, 13, 38, 1, "w")
    g.rect(4, 17, 38, 2, "L")
    g.ellipse(16, 12, 7, 5, "v", top_only=True)   # glass cockpit
    g.stamp(MINI_HEAD, 12, 7)
    g.rect(26, 8, 10, 5, "G")                # turret
    g.rect(36, 9, 8, 2, "x")
    g.rect(43, 9, 2, 2, "4")
    g.line(6, 13, 2, 2, "G")                 # antenna
    g.px(2, 1, "r")
    for cx in (9, 23, 37):
        g.disc(cx, 21, 4, "x")
        g.disc(cx, 21, 1, "G")
    return g.outline()


def dropship():
    g = Grid(56, 22)
    g.ellipse(26, 11, 22, 6, "T")
    g.rect(4, 6, 6, 10, "T")
    g.rect(0, 8, 4, 6, "G")                  # engine
    g.rect(0, 9, 1, 4, "9")
    g.rect(10, 11, 34, 2, "L")
    g.ellipse(44, 9, 4, 2, "v")
    g.rect(18, 16, 14, 3, "G")               # landing skid
    for x in range(14, 40, 6):
        g.rect(x, 7, 3, 2, "v")
    return g.outline()


def starship():
    g = Grid(44, 20)
    for y in range(0, 20):
        w = 40 - abs(y - 10) * 4
        if w > 0:
            g.rect(2, y, w, 1, "g")
    g.rect(2, 8, 30, 4, "G")
    g.rect(30, 9, 6, 2, "4")
    g.rect(0, 7, 3, 6, "9")
    g.rect(14, 4, 8, 2, "v")
    return g.outline()


def robot():
    g = from_rows("robot", ROBOT)
    g.rect(0, 12, 2, 3, "G")
    return g


def laser_turret():
    g = Grid(24, 18)
    g.rect(8, 12, 10, 6, "G")                # pedestal
    g.rect(6, 16, 14, 2, "x")
    g.ellipse(13, 9, 7, 5, "T")              # dome
    g.rect(10, 7, 5, 2, "r")
    g.rect(0, 8, 8, 3, "x")                  # barrel pointing left
    g.rect(0, 9, 2, 1, "4")
    return g.outline()


def repair_bot():
    g = Grid(18, 16)
    g.disc(9, 7, 6, "T")
    g.rect(6, 6, 7, 2, "3")                  # green repair light
    g.rect(8, 4, 3, 6, "3")
    g.rect(3, 13, 12, 2, "G")                # hover pad
    g.rect(4, 15, 2, 1, "4")
    g.rect(12, 15, 2, 1, "4")
    g.line(15, 9, 17, 3, "G")                # wrench arm
    g.rect(16, 1, 2, 2, "g")
    return g.outline()


def robot_cannon():
    g = Grid(32, 18)
    g.rect(6, 13, 22, 5, "x")                # treads
    for x in range(8, 28, 4):
        g.rect(x, 14, 2, 3, "G")
    g.rect(10, 6, 16, 7, "T")
    g.rect(12, 8, 3, 2, "r")
    g.rect(0, 7, 11, 4, "G")                 # plasma cannon pointing left
    g.rect(0, 8, 2, 2, "3")
    return g.outline()


def mega_bot():
    """The boss: a giant robot with a red eye and a cannon arm."""
    g = Grid(26, 32)
    g.rect(7, 0, 12, 10, "T")                # head
    g.rect(9, 3, 8, 3, "x")
    g.rect(11, 4, 4, 1, "r")
    g.rect(12, 0, 2, 0 + 1, "r")
    g.rect(4, 11, 18, 11, "T")               # body
    g.rect(9, 13, 8, 5, "x")
    g.rect(10, 14, 6, 3, "r")
    g.rect(0, 11, 4, 12, "G")                # cannon arm (left)
    g.rect(0, 22, 4, 2, "3")
    g.rect(22, 11, 4, 9, "G")                # claw arm (right)
    g.rect(21, 20, 6, 3, "x")
    g.rect(6, 23, 5, 7, "G")                 # legs
    g.rect(15, 23, 5, 7, "G")
    g.rect(4, 30, 8, 2, "x")
    g.rect(14, 30, 8, 2, "x")
    return g.outline()


def metal():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "g")
    g.rect(1, 1, 14, 1, "l")
    g.rect(1, 14, 14, 1, "G")
    g.rect(14, 1, 1, 14, "G")
    for x, y in ((3, 3), (12, 3), (3, 12), (12, 12)):
        g.px(x, y, "x")
    g.rect(5, 7, 6, 2, "G")
    return g


def glass():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "G")
    g.rect(1, 1, 14, 14, "v")
    g.line(3, 10, 9, 3, "w")
    g.line(5, 12, 11, 5, "w")
    return g


def cell():
    g = Grid(16, 16)
    g.rect(2, 0, 12, 16, "k")
    g.rect(3, 1, 10, 14, "G")
    for y in (3, 7, 11):
        g.rect(4, y, 8, 2, "3")
    g.rect(6, 0, 4, 1, "y")
    return g


def girder():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 8, "k")
    g.rect(0, 1, 16, 1, "g")
    g.rect(0, 6, 16, 1, "g")
    g.line(1, 5, 5, 2, "G")
    g.line(6, 2, 10, 5, "G")
    g.line(11, 5, 15, 2, "G")
    return g


def build():
    add("marine", marine(), "marines")
    add("jetpacker", jetpacker(), "marines")
    add("power_suit", power_suit(), "marines")
    add("laser_gunner", laser_gunner(), "marines")
    add("plasma_gunner", plasma_gunner(), "marines")
    add("proj_laser", proj_laser())
    add("proj_plasma", proj_plasma())
    add("rover", rover(), "marines")
    add("dropship", dropship(), "marines")
    add("starship", starship())
    add("robot", robot(), "robots")
    add("laser_turret", laser_turret(), "robots")
    add("repair_bot", repair_bot(), "robots")
    add("robot_cannon", robot_cannon(), "robots")
    add("mega_bot", mega_bot(), "robots")
    add("metal", metal())
    add("glass", glass())
    add("cell", cell())
    add("girder", girder())
