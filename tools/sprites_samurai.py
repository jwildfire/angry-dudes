"""Sprites for battle pack: Samurai Japan (Odawara 1590, Osaka 1614-1615)."""
from spritekit import *  # noqa: F401,F403

JINGASA = [                 # conical lacquered hat of an ashigaru foot soldier
    "................",
    ".......kk.......",
    ".....kkxxkk.....",
    "...kkxxyyxxkk...",
    "kkkxxxxxxxxxxkkk",
    ".kkkkkkkkkkkkkk.",
]
KABUTO = [                  # samurai helmet with a gold crest
    "..yk........ky..",
    "...yk......ky...",
    "....ykkkkkky....",
    "...kTTTTTTTTk...",
    "..kTLTTTTTTTTk..",
    "kTTkkkkkkkkkkTTk",
]
SANADA_KABUTO = [           # red helmet with tall antler crest
    ".yk..........ky.",
    "..yk.k....k.ky..",
    "...yyk.kk.kyy...",
    "...kTTTyyTTTk...",
    "..kTLTTTTTTTTk..",
    "kTTkkkkkkkkkkTTk",
]
ASHIGARU_BODY = [           # lacquered chest armor with the clan's crest
    "...kTTTTTTTTk...",
    "..kskTTLLTTksk..",
    "...kTtTtTtTtk...",
    "...kssk..kssk...",
    "..kBBBk..kBBBk..",
]
SAMURAI_BODY = [
    "...kTLTTTTLTk...",
    "..kskTTyyTTksk..",
    "...kTtTtTtTtk...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]
SANADA_BODY = [             # six coins: the Sanada family crest
    "...kTyTyTyTTk...",
    "..kskTyTyTyksk..",
    "...kTtTtTtTtk...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]


def ashigaru():
    g = person("ashigaru", JINGASA, ASHIGARU_BODY, "tokugawa")
    for y in range(1, 17):
        g.px(14, y, "b")
    g.rect(14, 0, 1, 2, "g")
    return g.outline()


def samurai():
    g = Grid(20, 18)
    g.stamp(KABUTO + face(mustache=True, mouth="shout") + SAMURAI_BODY, 0, 0)
    g.line(12, 14, 19, 7, "l")              # katana
    g.line(12, 15, 13, 14, "x")
    return g.outline()


def teppo():
    """Ashigaru with a matchlock gun (tanegashima)."""
    g = person("teppo", JINGASA, ASHIGARU_BODY, "tokugawa", eyes="squint")
    for y in range(2, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.px(15, 2, "9")                         # glowing match cord
    return g.outline()


def bomb_thrower():
    g = Grid(18, 18)
    g.stamp(JINGASA + face(mouth="shout") + ASHIGARU_BODY, 0, 0)
    g.line(13, 13, 15, 5, "s")
    g.disc(16, 2, 2, "J")
    g.px(17, 0, "9")
    return g.outline()


def proj_firebomb():
    g = Grid(9, 10)
    g.disc(4, 6, 3, "J")
    g.px(3, 5, "c")
    g.px(4, 2, "c")
    g.px(4, 1, "y")
    g.px(5, 0, "9")
    return g.outline()


def turtle_cart():
    """Kikkosha: a shielded cart that lets soldiers walk right up to the walls."""
    g = Grid(44, 24)
    g.ellipse(21, 13, 19, 9, "b", top_only=True)
    for x in range(4, 40, 6):
        for y in range(6, 14, 4):
            if g.get(x, y) == "b":
                g.rect(x, y, 3, 2, "B")
    g.rect(2, 13, 39, 3, "B")
    g.rect(2, 13, 39, 1, "c")
    for x in (12, 16, 26, 30):
        g.rect(x, 16, 1, 3, "s")
        g.px(x, 19, "B")
    for cx in (8, 34):
        g.disc(cx, 19, 3, "B")
        g.px(cx, 19, "c")
    return g.outline()


def red_ashigaru():
    return ashigaru()


def sanada():
    g = person("sanada", SANADA_KABUTO, SANADA_BODY, "toyotomi", mustache=True)
    for y in range(9, 17):
        g.px(14, y, "l")
    g.rect(13, 13, 3, 1, "x")
    return g.outline()


def jp_cannon():
    g = Grid(32, 18)
    g.line(10, 13, 0, 17, "b", 2)
    g.rect(6, 8, 14, 4, "b")
    g.rect(8, 5, 21, 4, "X")
    g.rect(8, 5, 21, 1, "G")
    g.rect(28, 4, 2, 6, "G")
    g.disc(12, 12, 5, "B")
    g.disc(12, 12, 1, "X")
    g.stamp(["..kkkk..", ".kTLTTk.", "kTTTTTTk", "kkkkkkkk", "kskssksk", "ksskkssk", ".kkkkkk."], 1, 0)
    return g.outline().mirror()


def ishigaki():
    """Castle stone base: big, uneven stones fitted without mortar."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "p")
    for x0, y0, w, h in ((1, 1, 6, 4), (8, 1, 7, 5), (1, 6, 4, 4), (6, 7, 6, 3), (13, 7, 2, 4), (1, 11, 7, 4), (9, 11, 6, 4)):
        g.rect(x0, y0, w, 1, "i")
        g.rect(x0, y0 + h, w + 1, 1, "P")
        g.rect(x0 + w, y0, 1, h, "P")
    return g


def plaster():
    """White plaster castle wall with a dark lower panel."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "1")
    g.rect(1, 10, 14, 5, "x")
    for x in (4, 9, 13):
        g.rect(x, 10, 1, 5, "X")
    g.rect(6, 4, 4, 3, "x")                  # arrow slit
    g.rect(14, 1, 1, 9, "i")
    return g


def roof():
    """Dark clay roof tiles. Used as the long slab on top of buildings."""
    g = Grid(16, 16)
    g.rect(0, 0, 16, 8, "k")
    g.rect(0, 1, 16, 6, "G")
    for x in range(0, 16, 3):
        g.rect(x, 1, 1, 6, "X")
    g.rect(0, 1, 16, 1, "g")
    return g


def bamboo():
    g = Grid(16, 16)
    for i in range(4):
        x = i * 4
        g.rect(x + 1, 1, 2, 15, "e")
        g.rect(x + 1, 1, 1, 15, "a")
        for y in (4, 9, 13):
            g.rect(x + 1, y, 2, 1, "A")
    g.rect(0, 6, 16, 1, "C")
    g.rect(0, 11, 16, 1, "C")
    return g.outline()


def build():
    add("ashigaru", ashigaru(), "tokugawa")
    add("samurai", samurai(), "tokugawa")
    add("teppo", teppo(), "tokugawa")
    add("bomb_thrower", bomb_thrower(), "tokugawa")
    add("proj_firebomb", proj_firebomb())
    add("turtle_cart", turtle_cart(), "tokugawa")
    add("red_ashigaru", red_ashigaru(), "toyotomi")
    variant("red_teppo", "teppo", team="toyotomi", mirror=True)
    add("sanada", sanada(), "toyotomi")
    variant("hojo_lord", "sanada", team="tokugawa", pal={"T": "#3b6b4a", "t": "#264a32", "L": "#cfe0c0"})
    add("jp_cannon", jp_cannon(), "toyotomi")
    variant("toyo_general", "sanada", pal={"T": "#3a3546", "t": "#26282e", "L": "#e8c45a"})
    add("ishigaki", ishigaki())
    add("plaster", plaster())
    add("roof", roof())
    add("bamboo", bamboo())
