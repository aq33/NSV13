"""Prints an ASCII view of a map region to check duct and tank placement.

usage: python ascii_view.py map.dmm x y radius [z]
# wall, . floor, D duct, T tank, S sink/toilet/shower, + door, w window, o other object, space blank
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'mapmerge2'))
import dmm  # noqa: E402


def glyph(tile):
    paths = [a.split('{', 1)[0] for a in tile]
    objs = [p for p in paths if p.startswith('/obj/')]
    turf = next((p for p in paths if p.startswith('/turf/')), '')
    if any(p.startswith('/obj/structure/reagent_dispensers/plumbed') for p in objs):
        return 'T'
    if any(p.startswith(('/obj/structure/sink', '/obj/structure/toilet', '/obj/machinery/shower')) for p in objs):
        return 'S'
    if '/obj/machinery/duct' in objs:
        return 'D'
    if any(p.startswith('/obj/machinery/door') for p in objs):
        return '+'
    if any(p.startswith(('/obj/structure/window', '/obj/structure/grille', '/obj/effect/spawner/structure/window')) for p in objs):
        return 'w'
    if turf.startswith('/turf/closed'):
        return '#'
    if not turf.startswith('/turf/open/floor'):
        return ' '
    solid = [p for p in objs if not p.startswith(('/obj/effect', '/obj/structure/cable', '/obj/machinery/atmospherics/pipe', '/obj/structure/disposalpipe'))]
    return 'o' if solid else '.'


def main():
    path, x, y, r = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
    z = int(sys.argv[5]) if len(sys.argv) > 5 else 1
    m = dmm.DMM.from_file(path)
    for yy in range(min(m.size.y, y + r), max(0, y - r), -1):
        row = ''
        for xx in range(max(1, x - r), min(m.size.x, x + r) + 1):
            row += glyph(m.get_tile((xx, yy, z)))
        print(f'{yy:4d} {row}')


if __name__ == "__main__":
    main()
