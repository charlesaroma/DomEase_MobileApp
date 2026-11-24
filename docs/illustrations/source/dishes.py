"""DomEase dish spot illustrations. One 96 x 96 box each, flat shapes, light
from the top left, soft ground shadow, colours from the brand's warm range.
Each layer: (path d, fill hex, opacity) or ('S', d, stroke hex, width, opacity)."""
import math
from xf import rot

# Food palette: warm, slightly muted so it sits beside Terracotta and Sage.
P = dict(
    ink="#2D2520", white="#FFFFFF", cream="#FBF7F4", plateRim="#E6DFDA", plateWell="#F2ECE8",
    clay="#874628", clay600="#A85E3D", clay400="#D99679", clay200="#EEC6B5", clay100="#F9E0D6",
    sage="#53815F", sage800="#3C6548", sage400="#8CB496", sage200="#C0D7C5",
    stew="#B4652E", stewLight="#CD8547", nut="#EBC58E",
    matoke="#E8CF78", matokeShade="#C9AC4F", matokeLight="#F5E5A6", bean="#6B2E22",
    sauce="#C2703B",
    chapati="#E6B46C", chapatiShade="#C98F4A", spot="#B5763A", egg="#F1C548", eggLight="#FBE7A1",
    tomato="#D0503A", tomatoLight="#E98670", cabbage="#A7C88C",
    fish="#8A5E42", fishDark="#6A4330", fishLight="#A97C5A", lemon="#EFD25C", lemonRind="#D2B13A",
    rice="#C89558", riceLight="#DDB179", grain="#F0D7A8", beef="#6C3122", beefLight="#8F4B34",
    dough="#D99A4E", doughShade="#B5722F", doughLight="#EDBB72", sugar="#FFF8EE",
)


def E(cx, cy, rx, ry):
    return (f"M{cx - rx:.2f} {cy:.2f} A{rx:.2f} {ry:.2f} 0 1 0 {cx + rx:.2f} {cy:.2f} "
            f"A{rx:.2f} {ry:.2f} 0 1 0 {cx - rx:.2f} {cy:.2f} Z")


def rtri(a, b, c, t=0.22):
    """Triangle with soft, puffy corners (dough, pastry)."""
    pts = [a, b, c]
    d = ""
    for i in range(3):
        v, prv, nxt = pts[i], pts[i - 1], pts[(i + 1) % 3]
        pin = (v[0] + (prv[0] - v[0]) * t, v[1] + (prv[1] - v[1]) * t)
        pout = (v[0] + (nxt[0] - v[0]) * t, v[1] + (nxt[1] - v[1]) * t)
        d += ("M" if i == 0 else "L") + f"{pin[0]:.2f} {pin[1]:.2f} Q{v[0]:.2f} {v[1]:.2f} {pout[0]:.2f} {pout[1]:.2f} "
    return d + "Z"


def puff(pts, t=0.26, bulge=0.10):
    """Polygon with soft corners and gently swollen sides: dough, beef, bread."""
    n = len(pts)
    cx = sum(p[0] for p in pts) / n
    cy = sum(p[1] for p in pts) / n
    seg = []
    for i in range(n):
        v, prv, nxt = pts[i], pts[i - 1], pts[(i + 1) % n]
        seg.append(((v[0] + (prv[0] - v[0]) * t, v[1] + (prv[1] - v[1]) * t), v,
                    (v[0] + (nxt[0] - v[0]) * t, v[1] + (nxt[1] - v[1]) * t)))
    d = f"M{seg[0][0][0]:.2f} {seg[0][0][1]:.2f} "
    for i in range(n):
        pin, v, pout = seg[i]
        d += f"Q{v[0]:.2f} {v[1]:.2f} {pout[0]:.2f} {pout[1]:.2f} "
        nin = seg[(i + 1) % n][0]
        mx, my = (pout[0] + nin[0]) / 2, (pout[1] + nin[1]) / 2
        ex, ey = nin[0] - pout[0], nin[1] - pout[1]
        ln = math.hypot(ex, ey) or 1
        nx, ny = ey / ln, -ex / ln
        if (mx - cx) * nx + (my - cy) * ny < 0:
            nx, ny = -nx, -ny
        k = bulge * ln
        d += f"Q{mx + nx * k:.2f} {my + ny * k:.2f} {nin[0]:.2f} {nin[1]:.2f} "
    return d + "Z"


def shift(pts, dx, dy):
    return [(x + dx, y + dy) for x, y in pts]


def F(d, c, o=1.0):
    return ("F", d, P[c], o)


def S(d, c, w, o=1.0):
    return ("S", d, P[c], w, o)


def shadow(cx=48, cy=80, rx=32, ry=4.5):
    return F(E(cx, cy, rx, ry), "ink", 0.10)


# ── Groundnut stew: a clay bowl, peanut sauce, greens, a little steam ──
def groundnut_stew():
    L = [shadow(48, 81, 30)]
    L += [S("M37 36 C33 30 41 26 37 18", "line", 2.6), S("M48 33 C44 27 52 23 48 15", "line", 2.6),
          S("M59 36 C55 30 63 26 59 18", "line", 2.6)]
    L += [F("M16 50 C16 70 30 82 48 82 C66 82 80 70 80 50 Z", "clay600"),
          F("M19 62 C25 75 36 82 48 82 C60 82 71 75 77 62 C68 70 28 70 19 62 Z", "clay"),
          S("M23 58 C25 64 28 68 32 71", "white", 2.4, 0.35),
          F(E(48, 50, 32, 10), "clay"),
          F(E(48, 50, 28.5, 8), "stew"),
          F(E(43, 48.5, 15, 4), "stewLight")]
    for cx, cy in [(36, 50), (55, 53), (50, 47), (62, 49), (42, 53)]:
        L.append(F(E(cx, cy, 2.4, 1.6), "nut"))
    L += [F("M57 46 C60 42 66 42 68 45 C65 47 60 48 57 46 Z", "sage"),
          F("M30 50 C32 46 38 46 40 48 C37 51 33 51 30 50 Z", "sage400")]
    return L


# ── Matoke katogo: on a banana leaf, matoke pieces in sauce with beans ──
def matoke_katogo():
    L = [shadow(48, 80, 40)]
    L += [F("M3 64 C14 47 52 43 93 52 C82 70 40 79 3 64 Z", "sage"),
          F("M3 64 C30 60 62 56 93 52 C82 70 40 79 3 64 Z", "sage800", 0.35),
          S("M7 63 C36 58 64 55 90 52.5", "sage400", 1.4)]
    for x in (18, 30, 70, 82):
        L.append(S(f"M{x} {60 - (x - 48) * 0.09:.1f} L{x - 5} {52 - (x - 48) * 0.06:.1f}", "sage400", 1, 0.8))
    L += [F(E(48, 65, 33, 12.5), "plateRim"), F(E(48, 62, 33, 12), "white"), F(E(48, 62, 25, 8.4), "plateWell"),
          F(E(48, 61.5, 23, 7.2), "sauce")]
    for cx, cy in [(37, 56), (51, 53), (61, 58.5), (43, 62), (55, 63.5)]:
        L += [F(E(cx, cy + 1.8, 8, 5), "matokeShade"), F(E(cx, cy, 8, 4.8), "matoke"),
              F(E(cx - 2.4, cy - 1.5, 3.4, 1.3), "matokeLight")]
    for cx, cy in [(29, 62), (67, 63), (47, 58), (34, 65.5), (64, 55)]:
        L.append(F(E(cx, cy, 2, 1.4), "bean"))
    L += [F("M48 48 C50 45 55 45 57 47.5 C54 49.5 51 49.5 48 48 Z", "sage400")]
    return L


# ── Rolex: chapati rolled round an egg omelette, half in paper ──
def rolex():
    L = [shadow(48, 78, 34)]
    R = []
    R += [F("M20 37 H76 A6 15 0 0 1 76 67 H20 Z", "chapati")]
    for cx, cy in [(28, 44), (36, 51), (31, 60), (44, 42), (45, 57), (40, 63)]:
        R.append(F(E(cx, cy, 2.2, 1.3), "spot", 0.8))
    R += [F("M20 61 H80.8 A6 15 0 0 1 76 67 H20 Z", "chapatiShade"),
          S("M27 41 H48", "white", 2, 0.35)]
    R += [F("M51 34 H77 A7.5 18 0 0 1 77 70 H51 Z", "white"),
          F("M51 34 L57 52 L51 70 Z", "plateWell"),
          F("M51 62 H83.6 A7.5 18 0 0 1 77 70 H51 Z", "plateRim", 0.7),
          S("M62 34 L63.5 70", "line", 1.1), S("M71 34.2 L72 69.8", "line", 1.1)]
    R += [F("M12 44 C12 35 21 31 28 36 C23 38 17 41 12 44 Z", "cabbage"),
          F(E(26, 37.5, 4.2, 2.3), "tomato"),
          F("M13 61 C15 69 22 72 28 68.5 C23 67 17 64.5 13 61 Z", "cabbage"),
          F(E(20, 52, 7.4, 15.4), "chapatiShade"), F(E(20, 52, 6, 13.4), "egg"),
          F(E(20, 52, 3.6, 8.6), "eggLight"),
          S("M20 43.5 C23.5 45.5 23.5 58.5 20 61 C16.6 58.5 17.2 49.5 20 48.5", "spot", 1.4)]
    for l in R:
        if l[0] == "F":
            L.append(("F", rot(l[1], -16, 48, 52, 1.08, 1.08, 0, -2), l[2], l[3]))
        else:
            L.append(("S", rot(l[1], -16, 48, 52, 1.08, 1.08, 0, -2), l[2], l[3] * 1.08, l[4]))
    return L


# ── Tilapia: whole fried fish, lemon and tomato on an oval plate ──
def tilapia():
    L = [shadow(48, 77, 38)]
    L += [F(E(48, 65, 41, 13), "plateRim"), F(E(48, 62, 41, 12.5), "white"), F(E(48, 62, 33, 9), "plateWell")]
    L += [F("M68 53 L85 42 C83 48 83 57 85 64 Z", "fishDark"),
          F("M34 45 C40 36 55 36 61 43 C53 41 43 42 34 45 Z", "fishDark"),
          F("M15 54 C22 41 48 37 64 45 C68 47 70 50 72 53 C70 56 68 58 64 60 C48 68 22 66 15 54 Z", "fish"),
          F("M19 57 C32 64 52 64 66 58 C52 62 32 62 19 57 Z", "fishLight"),
          S("M29 45 C33 49 33 57 29 62", "fishDark", 1.8),
          S("M40 48 L43 58", "fishDark", 1.6), S("M48 46.5 L51 58.5", "fishDark", 1.6), S("M56 47 L58.5 57.5", "fishDark", 1.6),
          F(E(22.5, 52, 2.6, 2.6), "white"), F(E(22.5, 52, 1.3, 1.3), "ink")]
    L += [F("M63 67 A8 5.5 0 0 0 79 67 Z", "lemonRind"), F("M64.4 67 A6.6 4.3 0 0 0 77.6 67 Z", "lemon"),
          F(E(26, 68, 6, 3), "tomato"), F(E(26, 68, 4, 1.8), "tomatoLight"),
          F("M34 70 C36 67 41 67 43 69 C40 71 37 71 34 70 Z", "sage400")]
    return L


# ── Beef pilau: a mound of spiced rice with beef in a white bowl ──
def beef_pilau():
    L = [shadow(48, 81, 30)]
    L += [F("M18 54 C18 72 32 82 48 82 C64 82 78 72 78 54 Z", "white"),
          F("M24 72 C32 81 64 81 72 72 C62 78 34 78 24 72 Z", "plateRim"),
          F("M19.5 62 C30 67 66 67 76.5 62 L75.6 65.5 C64 70.5 32 70.5 20.4 65.5 Z", "clay600"),
          F(E(48, 54, 30, 8), "plateRim")]
    L += [F("M20 54 C21 38 35 29 48 29 C61 29 75 38 76 54 C66 60 30 60 20 54 Z", "rice"),
          F("M27 50 C28 40 37 34 47 33 C39 38 33 44 31 51 Z", "riceLight")]
    for cx, cy in [(30, 52), (38, 40), (44, 50), (52, 36), (58, 45), (66, 52), (49, 55), (35, 46), (62, 39), (70, 47), (42, 33)]:
        L.append(F(E(cx, cy, 1.7, 0.85), "grain"))
    for cx, cy, r in [(40, 45, 4.6), (57, 40, 4.2), (62, 51, 4.4), (34, 53, 3.8), (50, 49, 3.6)]:
        q = [(cx - r, cy - r * 0.5), (cx + r * 0.2, cy - r * 0.9), (cx + r, cy - r * 0.2), (cx + r * 0.6, cy + r * 0.8), (cx - r * 0.7, cy + r * 0.7)]
        L += [F(puff(q, 0.3, 0.08), "beef"), F(puff([q[0], q[1], (cx + r * 0.4, cy - r * 0.3), (cx - r * 0.4, cy)], 0.3, 0.05), "beefLight")]
    L += [F("M46 30 C48 25 54 25 56 28 C53 31 49 31 46 30 Z", "sage"),
          F("M54 31 C57 29 61 30 62 33 C59 34 56 33 54 31 Z", "sage400")]
    return L


# ── Mandazi: three puffy triangles of fried dough, a dust of sugar ──
def mandazi():
    L = [shadow(48, 81, 36)]
    L += [F(E(48, 72, 38, 10.5), "clay100"), F(E(48, 71, 34, 8.5), "cream")]

    def piece(a, b, c, depth=5):
        # The lit face: the same piece pulled toward its top left corner.
        g = ((a[0] + b[0] + c[0]) / 3, (a[1] + b[1] + c[1]) / 3)
        inner = [(g[0] + (p[0] - g[0]) * 0.62 - 1.6, g[1] + (p[1] - g[1]) * 0.62 - 1.8) for p in (a, b, c)]
        return [F(puff(shift([a, b, c], 0, depth), 0.3, 0.12), "doughShade"),
                F(puff([a, b, c], 0.3, 0.12), "dough"),
                F(puff(inner, 0.34, 0.14), "doughLight", 0.55)]

    L += piece((30, 22), (52, 58), (8, 60))
    L += piece((66, 20), (88, 58), (44, 58))
    L += piece((48, 40), (72, 76), (24, 76))
    for cx, cy in [(28, 36), (24, 48), (68, 34), (72, 46), (60, 50), (46, 56), (54, 62), (40, 66), (58, 70), (48, 50)]:
        L.append(F(E(cx, cy, 1.1, 0.9), "sugar"))
    return L


DISHES = dict(groundnutStew=groundnut_stew, matokeKatogo=matoke_katogo, rolex=rolex,
              tilapia=tilapia, beefPilau=beef_pilau, mandazi=mandazi)
P["line"] = "#D9D2CE"


def svg(layers, bg=None):
    body = f'<rect width="96" height="96" fill="{bg}"/>' if bg else ""
    for l in layers:
        if l[0] == "F":
            body += f'<path d="{l[1]}" fill="{l[2]}" fill-opacity="{l[3]}"/>'
        else:
            body += f'<path d="{l[1]}" fill="none" stroke="{l[2]}" stroke-width="{l[3]}" stroke-opacity="{l[4]}" stroke-linecap="round" stroke-linejoin="round"/>'
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96">{body}</svg>'
