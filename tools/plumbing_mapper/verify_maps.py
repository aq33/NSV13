"""Checks, straight from the map files, which sinks, toilets and showers can actually get water from a tank.

Rebuilds every duct network the way the game does (ducts join their cardinal neighbours on the default layer),
then marks a fixture as fed if a duct next to it belongs to a network that a tank's output faces.

usage: python verify_maps.py map.dmm [...]
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'mapmerge2'))
import dmm  # noqa: E402

DIRS = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
FIXTURE = re.compile(r'^/obj/(structure/sink(?!frame|/puddle)|structure/toilet|machinery/shower)')
TANK = '/obj/structure/reagent_dispensers/plumbed'


def main():
    total = fed_total = 0
    for path in sys.argv[1:]:
        m = dmm.DMM.from_file(path)
        for z in m.coords_z:
            ducts = set()
            fixtures = []
            tank_ports = []
            for x in range(1, m.size.x + 1):
                for y in range(1, m.size.y + 1):
                    tile = m.get_tile((x, y, z))
                    for atom in tile:
                        base = atom.split('{', 1)[0]
                        if base == '/obj/machinery/duct':
                            layer = re.search(r'duct_layer = (\d+)', atom)
                            if not layer or int(layer.group(1)) & 4:
                                ducts.add((x, y))
                        elif base.startswith(TANK):
                            d = re.search(r'dir = (\d+)', atom)
                            dx, dy = DIRS[int(d.group(1)) if d else 2]
                            tank_ports.append((x + dx, y + dy))
                        elif FIXTURE.match(base):
                            area = next((a for a in tile if a.startswith('/area/')), '')
                            fixtures.append(((x, y), base, area.split('{')[0]))
            # flood the networks that a tank pushes into
            wet = set()
            stack = [p for p in tank_ports if p in ducts]
            while stack:
                cur = stack.pop()
                if cur in wet:
                    continue
                wet.add(cur)
                for dx, dy in DIRS.values():
                    nxt = (cur[0] + dx, cur[1] + dy)
                    if nxt in ducts and nxt not in wet:
                        stack.append(nxt)
            for (x, y), base, area in fixtures:
                ok = any((x + dx, y + dy) in wet for dx, dy in DIRS.values())
                total += 1
                fed_total += ok
                if not ok:
                    print(f'NIEPODŁĄCZONE {os.path.basename(path)} ({x},{y}) {base} {area}')
            print(f'{os.path.basename(path)}: {len(fixtures)} urządzeń, {len(tank_ports)} zbiorników, {len(ducts)} rur, sucha rura bez zbiornika: {len(ducts - wet)}')
    print(f'RAZEM: {fed_total}/{total} podłączonych do zbiornika')


if __name__ == '__main__':
    main()
