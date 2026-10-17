"""Sprites for battle pack 1: World War II (U.S. Army vs. German Army, 1944)."""
from spritekit import *  # noqa: F401,F403


# ---------------------------------------------------------------- people parts
US_HELMET = [               # M1 helmet with camouflage netting
    ".....kkkkkk.....",
    "...kkTLTTtTkk...",
    "..kTLLTtTTtTTk..",
    "..kTLTtTTtTTtk..",
    ".kTtTTtTTtTTtTk.",
    ".kkkkkkkkkkkkkk.",
]
ENG_HELMET = [              # Engineer Special Brigade: white arc on the front
    ".....kkkkkk.....",
    "...kkTLTTtTkk...",
    "..kTLLwwwwtTTk..",
    "..kTLwtTTtwTtk..",
    ".kTtwTtTTtTwtTk.",
    ".kkkkkkkkkkkkkk.",
]
DE_HELMET = [               # M35 Stahlhelm, flared over the ears
    ".....kkkkkk.....",
    "...kkTLTTTTkk...",
    "..kTLLTTTTTTTk..",
    "..kTLTTTTTTTTk..",
    ".kTTTTTTTTTTTTk.",
    "kTTkkkkkkkkkkTTk",
]
SNIPER_HELMET = [           # Stahlhelm stuffed with leaves
    "....jkkkkkkj....",
    "...kkjLTjTTkk...",
    "..kTjLTTjTTjTk..",
    "..kjLTTjTTjTTk..",
    ".kTTjTTTjTTTjTk.",
    "kTjkkkkkkkkkkjTk",
]
OFFICER_CAP = [             # peaked service cap
    "....kkkkkkkk....",
    "..kkTTTTTTTTkk..",
    ".kTTLTTTTTTTTTk.",
    ".kTTTTTllTTTTTk.",
    "..kttttttttttk..",
    ".kkkkkkkkkkkkkk.",
]



US_BODY = [                 # wool shirt, web belt, canvas leggings
    "...kTTTTTTTTk...",
    "..kskTTTTTTksk..",
    "...kcCccccCck...",
    "...kcck..kcck...",
    "..kBBBk..kBBBk..",
]
PARA_BODY = [               # jump suit and brown jump boots
    "...kTTTTTTTTk...",
    "..kskTTTTTTksk..",
    "...kcCccccCck...",
    "...kttk..kttk...",
    "..kBBBk..kBBBk..",
]
ENG_BODY = [                # satchel charge across the chest
    "...kTTTTTTTTk...",
    "..kskcCrrCcksk..",
    "...kcCccccCck...",
    "...kcck..kcck...",
    "..kBBBk..kBBBk..",
]
DE_BODY = [                 # field gray tunic, black belt, jackboots
    "...kTTTTTTTTk...",
    "..kskTTTTTTksk..",
    "...kxxxggxxxk...",
    "...kttk..kttk...",
    "..kxxxk..kxxxk..",
]
SNIPER_BODY = [             # camouflage smock
    "...kTjTTJTTjk...",
    "..kskJTjTTjksk..",
    "...kxxxggxxxk...",
    "...kttk..kttk...",
    "..kxxxk..kxxxk..",
]
OFFICER_BODY = [            # greatcoat, binoculars
    "...kTTTTTTTTk...",
    "..kTsxxxxxxsTk..",
    "..kTTxGxxGxTTk..",
    "..kxxxxggxxxxk..",
    "..kTTTTTTTTTTk..",
    "..kTTTTkkTTTTk..",
    "..kxxxk..kxxxk..",
]

US_STAR = ["..w..", "wwwww", ".www.", ".w.w."]
BALKENKREUZ = [
    "..www..",
    "..wkw..",
    "wwwkwww",
    "wkkkkkw",
    "wwwkwww",
    "..wkw..",
    "..www..",
]

# ------------------------------------------------------------------ Allies
def rifleman():
    g = from_rows("rifleman", US_HELMET + face() + US_BODY)
    for y in range(1, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    g.px(15, 15, "b")
    g.px(15, 16, "b")
    return g.outline()


def paratrooper():
    g = Grid(24, 32)
    g.ellipse(12, 8, 11, 7, "e", top_only=True)
    for x in range(24):
        if (x // 3) % 2:
            g.recolor(x, 0, 1, 9, "e", "a")
    for x in range(2, 23, 4):
        g.px(x, 9, "e")
    g.line(3, 9, 7, 27, "k")
    g.line(21, 9, 16, 27, "k")
    g.stamp(US_HELMET + face("shout") + PARA_BODY, 4, 14)
    return g.outline()


def engineer():
    return from_rows("engineer", ENG_HELMET + face() + ENG_BODY).outline()


def sarge():
    rows = [
        "......kkkkkkkk......",
        "....kkTLTTtTTTkk....",
        "...kTLLTtTTTtTTTk...",
        "..kTLTTtTTTtTTTtTk..",
        ".kTtTTTtTTTtTTTtTTk.",
        ".kkkkkkkkkkkkkkkkkk.",
        "...kskssssssssksk...",
        "...ksskkksskkkssk...",
        "...kssswksskwsssk...",
        "...ksssssSSsssssk...",
        "...ksshhhhhhhhssk...",
        "...kshhskkkkshhsk...",
        "...kSssssssssssSk...",
        "....kkkkkkkkkkkk....",
        ".kkkTTTTTTTTTTTTkkk.",
        "kTTTTTTTTTTTTTTTTTTk",
        "kTsbbbbxxxxxxxxxxxxx",
        "kTTkTTTTxxTTTTsTkTTk",
        ".kccCccccccccccCcck.",
        "..kBBBBk....kBBBBk..",
    ]
    return from_rows("sarge", rows).outline()


def grenade_gi():
    g = Grid(18, 18)
    g.stamp(US_HELMET + face("shout") + US_BODY, 0, 0)
    g.line(13, 13, 15, 5, "s")
    g.line(14, 13, 16, 6, "s")
    g.stamp(["gx.", "aAa", "AaA", "aAa"], 14, 1)
    return g.outline()


def bazooka_gi():
    g = Grid(28, 18)
    g.stamp(US_HELMET + face() + US_BODY, 6, 0)
    g.rect(1, 12, 26, 2, "a")
    g.rect(1, 12, 26, 1, "e")
    g.rect(0, 11, 3, 4, "A")
    g.rect(25, 11, 3, 4, "A")
    return g.outline()


def mortar():
    g = Grid(18, 16)
    g.rect(1, 13, 11, 2, "A")
    g.line(4, 12, 11, 1, "a", 2)
    g.rect(11, 0, 3, 2, "A")
    g.line(10, 6, 15, 13, "x")
    g.line(9, 7, 12, 13, "x")
    g.rect(6, 7, 2, 2, "G")
    return g.outline()


def howitzer():
    g = Grid(40, 20)
    g.line(2, 17, 14, 13, "A", 2)
    g.rect(9, 9, 13, 3, "A")
    for y in range(3, 15):
        g.rect(17 + (y < 5), y, 3, 1, "a")
    g.line(19, 9, 37, 2, "a", 2)
    g.rect(36, 1, 3, 3, "A")
    g.disc(14, 14, 4, "x")
    g.disc(14, 14, 2, "G")
    g.px(14, 14, "g")
    return g.outline()


def jeep():
    g = Grid(38, 20)
    g.disc(3, 10, 2, "x")
    g.rect(4, 9, 30, 4, "a")
    g.rect(22, 8, 12, 1, "a")
    g.rect(4, 9, 18, 1, "e")
    g.rect(22, 8, 12, 1, "e")
    g.rect(34, 8, 1, 5, "A")
    g.px(34, 9, "y")
    g.rect(21, 2, 1, 7, "A")
    g.rect(35, 0, 1, 9, "G")
    g.px(34, 0, "G")
    g.stamp(MINI_HEAD, 11, 2)
    g.stamp(US_STAR, 25, 9)
    for cx in (10, 28):
        g.disc(cx, 15, 4, "x")
        g.disc(cx, 15, 1, "G")
    return g.outline()


def sherman():
    g = Grid(46, 28)
    g.rect(4, 21, 38, 6, "x")
    g.rect(3, 22, 1, 4, "x")
    g.rect(42, 22, 1, 4, "x")
    g.rect(4, 21, 38, 1, "G")
    for cx in (8, 14, 20, 26, 32, 38):
        g.disc(cx, 24, 2, "G")
        g.px(cx, 24, "g")
    for y in range(14, 21):
        g.rect(5, y, 33 + (y - 14), 1, "a")
    g.rect(5, 14, 33, 1, "e")
    g.rect(5, 20, 39, 1, "A")
    g.ellipse(21, 11, 9, 4, "a")
    g.top_highlight(13, 29, "a", "e")
    g.rect(30, 9, 3, 5, "A")
    g.rect(33, 10, 10, 2, "A")
    g.rect(43, 9, 1, 4, "x")
    g.stamp(MINI_HEAD, 16, 1)
    g.stamp(US_STAR, 12, 15)
    return g.outline()


def mustang():
    g = Grid(38, 16)
    for y in range(0, 7):
        g.rect(3, y, 3 + y // 2, 1, "g")
    g.ellipse(18, 8, 14, 3, "g")
    g.top_highlight(6, 31, "g", "l")
    g.rect(1, 8, 9, 1, "G")
    for x, c in ((9, "w"), (10, "k"), (11, "w"), (12, "k"), (13, "w")):
        g.recolor(x, 0, 1, 16, "gl", c)
    g.ellipse(20, 4, 3, 2, "v")
    g.px(19, 3, "w")
    g.px(21, 4, "s")
    g.rect(13, 10, 11, 1, "G")
    g.rect(15, 11, 7, 2, "G")
    g.rect(32, 7, 2, 3, "y")
    g.px(34, 8, "y")
    g.disc(25, 8, 2, "U")
    g.stamp(["w", "www", ".w.w"][0:1], 25, 7)
    g.rect(24, 8, 3, 1, "w")
    g.px(24, 9, "w")
    g.px(26, 9, "w")
    g.outline()
    for y in range(1, 16, 2):
        g.px(36, y, "G")
    return g


def flying_fortress():
    g = Grid(56, 22)
    for y in range(0, 10):
        g.rect(3, y, 3 + y, 1, "g")
    g.rect(5, 8, 40, 5, "g")
    g.ellipse(45, 10, 5, 2, "g")
    g.top_highlight(5, 48, "g", "l")
    g.rect(48, 8, 3, 4, "v")
    g.px(49, 8, "w")
    g.rect(1, 11, 10, 2, "G")
    g.rect(19, 12, 18, 2, "G")
    g.rect(26, 10, 7, 4, "x")
    g.rect(36, 10, 6, 4, "x")
    g.ellipse(36, 7, 2, 1, "v")
    g.disc(28, 15, 1, "v")
    for x in (12, 15, 18):
        g.px(x, 9, "x")
    g.disc(15, 11, 2, "U")
    g.rect(14, 11, 3, 1, "w")
    g.px(15, 10, "w")
    g.outline()
    for x in (34, 43):
        for y in range(6, 18, 2):
            g.px(x, y, "G")
    return g


# -------------------------------------------------------------------- Axis
def grenadier():
    g = from_rows("grenadier", DE_HELMET + face(stahl=True) + DE_BODY)
    for y in range(7, 13):
        g.px(1, y, "x")
    for y in range(13, 17):
        g.px(1, y, "b")
    g.px(0, 16, "b")
    return g.outline()


def sniper():
    g = from_rows("sniper", SNIPER_HELMET + face(eyes="squint", stahl=True) + SNIPER_BODY)
    for y in range(1, 13):
        g.px(14, y, "x")
    for y in range(13, 17):
        g.px(14, y, "b")
    for y in range(6, 10):
        g.px(15, y, "G")
    return g.outline()


def officer():
    return from_rows("officer", OFFICER_CAP + face(mustache=True) + OFFICER_BODY).outline()


def mg42_nest():
    g = Grid(28, 16)
    g.stamp(DE_HELMET + face(stahl=True), 2, 0)
    g.rect(0, 9, 28, 7, ".")
    for course, y in enumerate((9, 13)):
        off = 0 if course == 0 else 4
        for bx in range(-8, 28, 8):
            x = bx + off
            g.rect(x + 1, y, 6, 2, "c")
            g.rect(x + 1, y + 2, 6, 1, "C")
    g.rect(14, 8, 5, 2, "x")
    g.rect(19, 8, 7, 1, "G")
    for x in range(20, 26, 2):
        g.px(x, 8, "x")
    g.rect(26, 8, 2, 1, "x")
    g.px(12, 9, "s")
    return g.outline().mirror()


def flak88():
    g = Grid(48, 26)
    g.rect(4, 22, 38, 2, "D")
    g.rect(2, 24, 5, 1, "D")
    g.rect(39, 24, 5, 1, "D")
    g.rect(18, 16, 8, 6, "D")
    g.rect(12, 12, 18, 5, "d")
    g.rect(12, 12, 18, 1, "E")
    for y in range(4, 18):
        g.rect(26 + (y - 4) // 5, y, 2, 1, "d")
    g.line(20, 10, 32, 5, "D", 2)
    g.line(24, 12, 44, 2, "d", 2)
    g.rect(43, 0, 3, 4, "x")
    g.stamp(MINI_HEAD, 14, 5)
    return g.outline().mirror()


def tiger():
    oy = 3
    g = Grid(58, 30)
    g.rect(4, 21 + oy, 44, 6, "x")
    g.rect(3, 22 + oy, 1, 4, "x")
    g.rect(48, 22 + oy, 1, 4, "x")
    for cx in (8, 14, 20, 26, 32, 38, 44):
        g.disc(cx, 24 + oy, 3, "D")
    for cx in (11, 17, 23, 29, 35, 41):
        g.disc(cx, 24 + oy, 2, "d")
    for cx in (8, 14, 20, 26, 32, 38, 44):
        g.px(cx, 24 + oy, "x")
    g.rect(3, 13 + oy, 46, 8, "d")
    g.rect(44, 11 + oy, 6, 10, "d")
    g.rect(3, 13 + oy, 41, 1, "E")
    g.rect(44, 11 + oy, 6, 1, "E")
    g.rect(47, 13 + oy, 2, 1, "x")
    g.rect(15, 5 + oy, 22, 8, "d")
    g.px(15, 5 + oy, ".")
    g.px(36, 5 + oy, ".")
    g.rect(16, 5 + oy, 20, 1, "E")
    g.rect(37, 6 + oy, 4, 6, "D")
    g.rect(41, 8 + oy, 13, 2, "D")
    g.rect(54, 7 + oy, 3, 4, "x")
    g.rect(18, 3 + oy, 5, 2, "D")
    g.stamp(MINI_HEAD, 16, 0)
    for x0, y0, x1, y1, c in ((17, 6, 22, 12, "j"), (27, 5, 33, 12, "J"), (24, 13, 31, 20, "j"),
                              (35, 13, 41, 20, "J"), (5, 13, 9, 17, "J"), (44, 11, 49, 18, "j")):
        g.line(x0, y0 + oy, x1, y1 + oy, c, 1, only="dE")
    g.stamp(BALKENKREUZ, 9, 14 + oy)
    return g.outline().mirror()


# -------------------------------------------------------------- fort pieces
def concrete():
    g = Grid(16, 16)
    g.rect(0, 0, 16, 16, "k")
    g.rect(1, 1, 14, 14, "p")
    g.rect(1, 1, 14, 1, "i")
    g.rect(14, 2, 1, 13, "P")
    g.rect(1, 14, 14, 1, "P")
    for y in (5, 10):
        for x in range(1, 14):
            if x % 5 != 3:
                g.px(x, y, "P")
    g.line(9, 2, 11, 8, "P")
    for x, y in ((3, 3), (6, 8), (12, 12), (4, 12), (10, 6)):
        g.px(x, y, "P")
    return g


def hedgehog():
    g = Grid(16, 16)
    g.line(2, 13, 12, 2, "G", 2)
    g.line(2, 2, 12, 13, "x", 2)
    g.rect(1, 12, 14, 2, "G")
    g.line(3, 3, 7, 7, "g")
    return g.outline()


def barbed_wire():
    g = Grid(16, 12)
    for x in (1, 14):
        g.rect(x, 1, 1, 11, "b")
    for x in range(16):
        g.px(x, 5 + round(2 * math.sin(x * 1.1)), "G")
        g.px(x, 7 + round(2 * math.cos(x * 1.1)), "G")
    for x in range(1, 16, 3):
        g.px(x, 5 + round(2 * math.sin(x * 1.1)) - 1, "l")
    return g


def jerrycan():
    g = Grid(16, 16)
    g.rect(2, 3, 12, 12, "d")
    g.rect(2, 3, 12, 1, "E")
    g.rect(13, 4, 1, 11, "D")
    g.line(3, 5, 12, 13, "D")
    g.line(12, 5, 3, 13, "D")
    g.rect(5, 1, 6, 1, "x")
    g.rect(5, 2, 1, 1, "x")
    g.rect(7, 2, 1, 1, "x")
    g.rect(10, 2, 1, 1, "x")
    g.rect(2, 1, 2, 2, "G")
    return g.outline()


# ------------------------------------------------- things in flight (point right)
def paradude():
    return from_rows("paradude", US_HELMET + face("shout") + PARA_BODY).outline()


def proj_grenade():
    g = Grid(7, 8)
    g.rect(2, 2, 3, 5, "a")
    g.px(3, 3, "A")
    g.px(2, 5, "A")
    g.px(4, 5, "A")
    g.px(3, 1, "x")
    g.px(4, 1, "g")
    return g.outline()


def proj_rocket():
    g = Grid(15, 7)
    g.rect(3, 2, 8, 3, "a")
    g.rect(3, 2, 8, 1, "e")
    g.rect(11, 2, 2, 3, "A")
    g.px(13, 3, "A")
    g.rect(1, 1, 2, 5, "x")
    return g.outline()


def proj_shell():
    g = Grid(11, 7)
    g.rect(2, 2, 6, 3, "G")
    g.rect(2, 2, 6, 1, "g")
    g.rect(8, 2, 1, 3, "G")
    g.px(9, 3, "G")
    g.rect(1, 1, 1, 5, "x")
    return g.outline()


def proj_bomb():
    g = Grid(14, 8)
    g.rect(3, 2, 7, 4, "a")
    g.rect(3, 2, 7, 1, "e")
    g.rect(10, 3, 2, 2, "a")
    g.rect(10, 2, 1, 4, "a")
    g.rect(1, 1, 2, 6, "x")
    g.rect(6, 2, 1, 4, "y")
    return g.outline()


def proj_tankshell():
    g = Grid(8, 5)
    g.rect(1, 1, 4, 3, "o")
    g.rect(5, 1, 1, 3, "G")
    g.px(6, 2, "G")
    return g.outline()


def build():
    add("paradude", paradude(), "allies")
    add("proj_grenade", proj_grenade(), "allies")
    add("proj_rocket", proj_rocket(), "allies")
    add("proj_shell", proj_shell(), "allies")
    add("proj_bomb", proj_bomb(), "allies")
    add("proj_tankshell", proj_tankshell(), "allies")
    add("rifleman", rifleman(), "allies")
    add("para", paratrooper(), "allies", air=True)
    add("engineer", engineer(), "allies", pal={"s": "#a86b45", "S": "#7a4a2c"})
    add("sarge", sarge(), "allies")
    add("grenade", grenade_gi(), "allies")
    add("bazooka", bazooka_gi(), "allies")
    add("mortar", mortar(), "allies")
    add("howitzer", howitzer(), "allies")
    add("jeep", jeep(), "allies")
    add("sherman", sherman(), "allies")
    add("p51", mustang(), "allies", air=True)
    add("b17", flying_fortress(), "allies", air=True)

    add("grenadier", grenadier(), "axis")
    add("mg42", mg42_nest(), "axis")
    add("sniper", sniper(), "axis")
    add("officer", officer(), "axis")
    add("flak88", flak88(), "axis")
    add("tiger", tiger(), "axis")

    add("concrete", concrete())
    add("hedgehog", hedgehog())
    add("wire", barbed_wire())
    add("jerrycan", jerrycan())



