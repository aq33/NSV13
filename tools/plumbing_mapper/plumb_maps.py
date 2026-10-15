"""Lays fluid ducts from stationary water tanks to every sink, toilet and shower on a map.

Ducts run under the floor, so they may pass under anything except walls, windows and space.
Fixtures (sinks, toilets, showers) take water from a duct on any of their four sides.
Tanks are dense, so they only go on empty floor tiles against a wall where they block nothing.

usage: python tools/plumbing_mapper/plumb_maps.py _maps/map_files/Atlas/atlas.dmm [...]
"""
import os
import re
import sys
from collections import deque

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'mapmerge2'))
import dmm  # noqa: E402

DUCT = '/obj/machinery/duct'
# THIRD_DUCT_LAYER, what fixtures, tanks and our ducts use
DUCT_LAYER_DEFAULT = 4
TANK = '/obj/structure/reagent_dispensers/plumbed'

# how far a fixture may be from the line before it gets its own tank
MAX_BRANCH = 45
# how far a new tank may be from the first fixture it serves
MAX_TANK_DISTANCE = 25

DIRS = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
RING = [(-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0)]

FIXTURE = re.compile(r'^/obj/(structure/sink(?!frame|/puddle)|structure/toilet|machinery/shower)')
# things a duct can never share a tile with
# full-tile windows always sit on a grille, thin directional windows are fine
DUCT_BLOCKERS = re.compile(r'^/obj/(structure/(window/.*fulltile|grille|reagent_dispensers/plumbed)|machinery/(duct|plumbing)|effect/spawner/structure/window)')
# fixtures nobody needs water at, like the joke toilet in the AI core
SKIP_AREAS = ('/area/ai_monitored', '/area/tcommsat')
# plumbing users that must not get water by accident
PLUMB_USERS = re.compile(r'^/obj/(machinery/(smoke_machine|limbgrower|plumbing|power/liquid_pump)|structure/reagent_dispensers/plumbed)')
# what may lie on a tile we put a tank on: floor decals, underfloor stuff and things hanging on the wall
TANK_OK = re.compile(r'^/obj/(effect/(turf_decal|decal/cleanable)|structure/(cable|disposalpipe|sign|extinguisher_cabinet|noticeboard|fireaxecabinet|lattice/catwalk)|machinery/(atmospherics/pipe|light|firealarm|airalarm|camera|light_switch|newscaster|status_display|button|requests_console)|item/radio/intercom)')
# what we can still walk over when deciding if a tank blocks a walkway
WALK_OK = re.compile(r'^/obj/(effect/(turf_decal|decal|landmark)|structure/(cable|disposalpipe|sign|extinguisher_cabinet|noticeboard|fireaxecabinet|lattice/catwalk|chair|bed|railing)|machinery/(atmospherics|light|firealarm|airalarm|camera|light_switch|newscaster|status_display|button|requests_console|power/apc|holopad|navbeacon|door|turnstile)|item/)')
# doors and other things a tank must not stand next to
DOORISH = re.compile(r'^/obj/(machinery/(door|turnstile)|structure/(mineral_door|plasticflaps|ladder|stairs)|machinery/(shower|computer|vending|disposal|power/apc)|structure/(sink|toilet)|machinery/hydroponics)')


def base_path(atom):
    return atom.split('{', 1)[0]


class Plumber:
    def __init__(self, path):
        self.path = path
        self.map = dmm.DMM.from_file(path)
        self.size = self.map.size

    def tile(self, x, y, z):
        return self.map.get_tile((x, y, z))

    def inside(self, x, y):
        return 1 <= x <= self.size.x and 1 <= y <= self.size.y

    def turf(self, tile):
        for atom in tile:
            if atom.startswith('/turf/'):
                return base_path(atom)
        return ''

    def area(self, tile):
        for atom in tile:
            if atom.startswith('/area/'):
                return base_path(atom)
        return ''

    def objects(self, tile):
        return [base_path(a) for a in tile if a.startswith('/obj/')]

    def is_floor(self, tile):
        turf = self.turf(tile)
        return turf.startswith('/turf/open/floor') and '/area/shuttle' not in self.area(tile) and self.area(tile) != '/area/space'

    def is_wall(self, tile):
        return self.turf(tile).startswith('/turf/closed')

    def duct_ok(self, x, y, z):
        if not self.inside(x, y):
            return False
        tile = self.tile(x, y, z)
        if not self.is_floor(tile):
            return False
        if any(DUCT_BLOCKERS.match(o) for o in self.objects(tile)):
            return False
        # stay away from other plumbing users so we don't flood them with water
        for d, (dx, dy) in DIRS.items():
            if self.inside(x + dx, y + dy):
                if any(PLUMB_USERS.match(o) for o in self.objects(self.tile(x + dx, y + dy, z))):
                    return False
        return True

    def walkable(self, x, y, z):
        if not self.inside(x, y):
            return False
        tile = self.tile(x, y, z)
        return self.is_floor(tile) and all(WALK_OK.match(o) for o in self.objects(tile))

    def tank_floor(self, x, y, z):
        tile = self.tile(x, y, z)
        return self.is_floor(tile) and all(TANK_OK.match(o) for o in self.objects(tile))

    def tank_ok(self, x, y, z):
        """Empty floor against a wall, nothing next to it that needs access, and it splits no walkway"""
        if not self.inside(x, y) or not self.tank_floor(x, y, z):
            return False
        if self.area(self.tile(x, y, z)).startswith(SKIP_AREAS):
            return False
        walls = 0
        for d, (dx, dy) in DIRS.items():
            nx, ny = x + dx, y + dy
            if not self.inside(nx, ny):
                return False
            ntile = self.tile(nx, ny, z)
            if self.is_wall(ntile):
                walls += 1
        if walls == 0:
            return False
        for dx, dy in RING:
            nx, ny = x + dx, y + dy
            if not self.inside(nx, ny):
                return False
            if any(DOORISH.match(o) for o in self.objects(self.tile(nx, ny, z))):
                return False
        # the walkable ring around us must stay one connected piece
        ring = [self.walkable(x + dx, y + dy, z) for dx, dy in RING]
        if sum(ring) < 3:
            return False
        pieces = 0
        for i in range(8):
            if ring[i] and not ring[i - 1]:
                pieces += 1
        if pieces == 0 and all(ring):
            pieces = 1
        # corner tiles of the ring only link their sides, cardinal gaps split
        return pieces == 1

    def fixtures(self, z):
        found = []
        for x in range(1, self.size.x + 1):
            for y in range(1, self.size.y + 1):
                tile = self.tile(x, y, z)
                # fixtures hang on walls too, the duct only has to reach a floor next to them
                if any(FIXTURE.match(o) for o in self.objects(tile)) and not self.area(tile).startswith(SKIP_AREAS):
                    found.append((x, y))
        return found

    def has_duct(self, x, y, z):
        """A duct on the default layer, the only one fixtures and our tanks connect to"""
        for atom in self.tile(x, y, z):
            if base_path(atom) != DUCT:
                continue
            layer = re.search(r'duct_layer = (\d+)', atom)
            if not layer or int(layer.group(1)) & DUCT_LAYER_DEFAULT:
                return True
        return False

    def ports(self, fixture, z):
        """Tiles a duct can sit on to feed this fixture"""
        x, y = fixture
        return [(x + dx, y + dy) for dx, dy in DIRS.values() if self.duct_ok(x + dx, y + dy, z) or (self.inside(x + dx, y + dy) and self.has_duct(x + dx, y + dy, z))]

    def bfs(self, sources, z, blocked, limit):
        """distance and parent maps over duct-able tiles"""
        dist = {}
        parent = {}
        queue = deque()
        for s in sources:
            dist[s] = 0
            parent[s] = None
            queue.append(s)
        while queue:
            cur = queue.popleft()
            if dist[cur] >= limit:
                continue
            for dx, dy in DIRS.values():
                nxt = (cur[0] + dx, cur[1] + dy)
                if nxt in dist or nxt in blocked:
                    continue
                if not (self.duct_ok(nxt[0], nxt[1], z) or (self.inside(*nxt) and self.has_duct(nxt[0], nxt[1], z))):
                    continue
                dist[nxt] = dist[cur] + 1
                parent[nxt] = cur
                queue.append(nxt)
        return dist, parent

    def add(self, x, y, z, atom):
        tile = list(self.tile(x, y, z))
        # objects go before the turf
        idx = next(i for i, a in enumerate(tile) if a.startswith('/turf/'))
        tile.insert(idx, atom)
        self.map.set_tile((x, y, z), tile)

    def place_tank(self, fixture, z, tanks, tree_tiles):
        """Finds the closest good tank tile for a fixture, returns (tank, port) or None"""
        ports = self.ports(fixture, z)
        if not ports:
            return None
        blocked = set(tanks)
        dist, _ = self.bfs(ports, z, blocked, MAX_TANK_DISTANCE)
        best = None
        for (px, py), d in dist.items():
            # the tank sits next to a reachable duct tile and feeds it from that side
            for direction, (dx, dy) in DIRS.items():
                tx, ty = px - dx, py - dy
                if (tx, ty) in tree_tiles or (tx, ty) in tanks:
                    continue
                if not self.tank_ok(tx, ty, z):
                    continue
                # corners and nooks keep rooms and corridors clear
                walls = sum(1 for ddx, ddy in DIRS.values() if self.is_wall(self.tile(tx + ddx, ty + ddy, z)))
                score = d + (0 if walls >= 2 else 6)
                if best is None or score < best[0]:
                    best = (score, (tx, ty), (px, py), direction)
        if not best:
            return None
        return best[1], best[2], best[3]

    def tank_ports(self, z):
        """Tiles the output of every tank already on the map faces"""
        ports = []
        for x in range(1, self.size.x + 1):
            for y in range(1, self.size.y + 1):
                for atom in self.tile(x, y, z):
                    if base_path(atom).startswith(TANK):
                        direction = re.search(r'dir = (\d+)', atom)
                        dx, dy = DIRS[int(direction.group(1)) if direction else 2]
                        ports.append((x + dx, y + dy))
        return ports

    @staticmethod
    def flood(ducts, sources):
        """Ducts connected to any of the sources, as the game joins neighbouring ducts"""
        wet = set()
        stack = [s for s in sources if s in ducts]
        while stack:
            cur = stack.pop()
            if cur in wet:
                continue
            wet.add(cur)
            for dx, dy in DIRS.values():
                nxt = (cur[0] + dx, cur[1] + dy)
                if nxt in ducts and nxt not in wet:
                    stack.append(nxt)
        return wet

    def run(self):
        report = []
        for z in self.map.coords_z:
            fixtures = self.fixtures(z)
            if not fixtures:
                continue
            fed = set()
            tanks = []
            # ducts already on the map count, so running this twice adds nothing
            ducts = {(x, y) for x in range(1, self.size.x + 1) for y in range(1, self.size.y + 1) if self.has_duct(x, y, z)}
            existing = set(ducts)
            # where tanks already on the map push water into
            tank_ports = self.tank_ports(z)
            wet = self.flood(ducts, tank_ports)
            for fixture in fixtures:
                if fixture in fed:
                    continue
                if any(p in wet for p in self.ports(fixture, z)):
                    fed.add(fixture)
                    continue
                # branch off a line that already carries water before putting down another tank
                if wet:
                    dist, parent = self.bfs(wet, z, set(tanks), MAX_BRANCH)
                    reachable = [(dist[p], p) for p in self.ports(fixture, z) if p in dist]
                    if reachable:
                        node = min(reachable)[1]
                        while node is not None and node not in wet:
                            ducts.add(node)
                            node = parent[node]
                        wet = self.flood(ducts, tank_ports)
                        fed.add(fixture)
                        report.append(f'  z{z}: {fixture} joined an existing line')
                        continue
                placed = self.place_tank(fixture, z, tanks, ducts)
                if not placed:
                    report.append(f'  z{z}: no tank spot near {fixture}')
                    continue
                tank, port, direction = placed
                tanks.append(tank)
                tank_ports.append(port)
                tree = {port}
                ducts.add(port)
                # grow the line to every fixture we can reach
                while True:
                    targets = {}
                    for other in fixtures:
                        if other in fed:
                            continue
                        other_ports = self.ports(other, z)
                        if any(p in tree for p in other_ports):
                            fed.add(other)
                            continue
                        for p in other_ports:
                            targets[p] = other
                    if not targets:
                        break
                    dist, parent = self.bfs(tree, z, set(tanks), MAX_BRANCH)
                    reachable = [(dist[p], p) for p in targets if p in dist]
                    if not reachable:
                        break
                    _, goal = min(reachable)
                    node = goal
                    while node is not None and node not in tree:
                        tree.add(node)
                        ducts.add(node)
                        node = parent[node]
                    fed.add(targets[goal])
                wet = self.flood(ducts, tank_ports)
                self.add(tank[0], tank[1], z, TANK if direction == 2 else f'{TANK}{{dir = {direction}}}')
                report.append(f'  z{z}: tank at {tank} feeds {len(tree)} ducts')
            for (x, y) in sorted(ducts - existing):
                self.add(x, y, z, DUCT)
            missing = [f for f in fixtures if f not in fed]
            report.append(f'  z{z}: {len(fixtures)} fixtures, {len(fixtures) - len(missing)} plumbed, {len(tanks)} new tanks, {len(ducts - existing)} new ducts')
            for f in missing:
                report.append(f'    unplumbed fixture at {f}')
        return report


def main():
    for path in sys.argv[1:]:
        plumber = Plumber(path)
        report = plumber.run()
        plumber.map.to_file(path)
        print(path)
        print('\n'.join(report))


if __name__ == '__main__':
    main()
