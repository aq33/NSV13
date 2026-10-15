"""Lists every stationary water tank on the given maps with its area and a small ASCII view around it.

usage: python list_tanks.py map.dmm [...]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'mapmerge2'))
import dmm  # noqa: E402
from ascii_view import glyph  # noqa: E402

TANK = '/obj/structure/reagent_dispensers/plumbed'


def main():
    for path in sys.argv[1:]:
        m = dmm.DMM.from_file(path)
        for z in m.coords_z:
            for x in range(1, m.size.x + 1):
                for y in range(1, m.size.y + 1):
                    tile = m.get_tile((x, y, z))
                    tank = next((a for a in tile if a.startswith(TANK)), None)
                    if not tank:
                        continue
                    area = next(a for a in tile if a.startswith('/area/'))
                    print(f'{os.path.basename(path)} ({x},{y},{z}) {area} {tank}')
                    for yy in range(y + 3, y - 4, -1):
                        print('   ' + ''.join(glyph(m.get_tile((xx, yy, z))) if m.size.x >= xx >= 1 and m.size.y >= yy >= 1 else ' ' for xx in range(x - 5, x + 6)))


if __name__ == '__main__':
    main()
