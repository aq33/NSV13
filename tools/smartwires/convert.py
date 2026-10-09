#!/usr/bin/env python3
"""
Convert NSV13 maps from directional cables (d1-d2 icon_states) to smartwires
(port of BeeStation/BeeStation-Hornet#14275).

Goal: every powernet of the old map stays exactly one powernet, and no two old
powernets get merged. Smartwires join every cardinal-adjacent cable of the same
colour, so:
  * each old powernet gets one colour (largest powernets keep theirs),
  * powernets that touch (same tile, cardinal neighbours, deck above/below)
    get different colours,
  * diagonal links (no longer supported) get an extra cable on a corner tile,
  * one cable per colour per tile, the old node cable's colour goes first so
    machines (WANTS_POWER_NODE) pick the right one,
  * cables that went between decks (x-32) become /obj/structure/cable/multiz.

Usage (from the repo root): python tools/smartwires/convert.py . [--only <part of a map path> ...] [--dry]
Run it on a map from an old branch before merging it, the result is in TGM format.
"""
import sys, os, glob, json, collections, argparse
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from mapmerge2 import dmm as dmmlib
from mapmerge2.mapmerge import merge_map

PALETTE = ['red', 'yellow', 'green', 'pink', 'orange']
OLD_TO_NEW = {'red': 'red', 'yellow': 'yellow', 'green': 'green', 'pink': 'pink', 'orange': 'orange',
              'blue': 'pink', 'cyan': 'orange', 'white': 'pink'}
CABLE = '/obj/structure/cable'

def cable_path(color, multiz):
    base = CABLE + ('/multiz' if multiz else '')
    return base if color == 'red' else base + '/' + color

# game direction -> grid delta (mapmerge grid y is the game y, north = y+1)
def step(pos, d):
    x, y, z = pos
    if d == 16: return (x, y, z + 1)
    if d == 32: return (x, y, z - 1)
    dx = dy = 0
    if d & 1: dy += 1
    if d & 2: dy -= 1
    if d & 4: dx += 1
    if d & 8: dx -= 1
    return (x + dx, y + dy, z)

def inv(d):
    if d == 16: return 32
    if d == 32: return 16
    r = 0
    if d & 1: r |= 2
    if d & 2: r |= 1
    if d & 4: r |= 8
    if d & 8: r |= 4
    return r

CARD = (1, 2, 4, 8)

class UF:
    def __init__(s): s.p = {}
    def f(s, a):
        s.p.setdefault(a, a)
        while s.p[a] != a:
            s.p[a] = s.p[s.p[a]]; a = s.p[a]
        return a
    def u(s, a, b): s.p[s.f(a)] = s.f(b)

def old_color(path, vars_):
    sub = path[len(CABLE):].strip('/')
    col = sub or 'red'
    if 'cable_color' in vars_:
        col = vars_['cable_color'].strip('"')
    return col

class MapGroup:
    """One or more dmm files stacked as z-levels (in load order, bottom first)."""
    def __init__(self, files):
        self.files = files
        self.maps = [dmmlib.DMM.from_file(f) for f in files]
        self.cables = []  # dict(pos, color, d1, d2, file_i)
        self.tile = {}  # pos -> list of atoms (mutable copy)
        self.old_style = False  # directional cables found (icon_state var-edits)
        self.new_style = False  # smartwire-only types found
        self.zoff = []
        z = 0
        for i, m in enumerate(self.maps):
            self.zoff.append(z)
            for (x, y, mz), key in m.grid.items():
                pos = (x, y, z + mz)
                atoms = list(m.dictionary[key])
                self.tile[pos] = atoms
            z += m.size.z
        for pos, atoms in self.tile.items():
            for a in atoms:
                if a.startswith(CABLE):
                    path, v = dmmlib.parse_map_atom(a)
                    st = v.get('icon_state', '"0-1"').strip('"')
                    parts = st.split('-')
                    d1, d2 = int(parts[0]), int(parts[1])
                    self.cables.append({'pos': pos, 'color': old_color(path, v), 'd1': d1, 'd2': d2})
                    if 'icon_state' in v or path.startswith(CABLE + '/multiz') or path[len(CABLE):].strip('/') in ('blue', 'cyan', 'white'):
                        self.old_style = self.old_style or 'icon_state' in v or path[len(CABLE):].strip('/') in ('blue', 'cyan', 'white')
                        self.new_style = self.new_style or path.startswith(CABLE + '/multiz')

    def turf(self, pos):
        for a in self.tile.get(pos, ()):
            if a.startswith('/turf'):
                return a
        return ''

def convert(group, log):
    cab = group.cables
    if not cab:
        return False
    # Smartwire maps have no var-edited cables; converting them again would scramble their colours
    if not group.old_style or group.new_style:
        return False
    bypos = collections.defaultdict(list)
    for i, c in enumerate(cab):
        bypos[c['pos']].append(i)
    # ---- old connectivity
    uf = UF()
    for i in range(len(cab)):
        uf.f(i)
    for i, c in enumerate(cab):
        pos = c['pos']
        for d in (c['d1'], c['d2']):
            for j in bypos[pos]:
                if j != i and d in (cab[j]['d1'], cab[j]['d2']):
                    uf.u(i, j)
            if d == 0:
                continue
            for j in bypos.get(step(pos, d), []):
                if inv(d) in (cab[j]['d1'], cab[j]['d2']):
                    uf.u(i, j)
            if d < 16 and d & (d - 1):
                for dd, x in ((d & 3, d ^ 3), (d & 12, d ^ 12)):
                    for j in bypos.get(step(pos, dd), []):
                        if x in (cab[j]['d1'], cab[j]['d2']):
                            uf.u(i, j)
    comp = {i: uf.f(i) for i in range(len(cab))}
    members = collections.defaultdict(list)
    for i, r in comp.items():
        members[r].append(i)
    # multiz: cable pointing down (32) becomes a multiz cable; cables on open space are multiz at mapload
    multiz_cable = set()
    for i, c in enumerate(cab):
        if 32 in (c['d1'], c['d2']) or group.turf(c['pos']).startswith('/turf/open/openspace'):
            multiz_cable.add(i)
    # components that reach into an unknown neighbouring file keep their colour
    stacked = len(group.maps) > 1
    pinned = set()
    if not stacked:
        for i, c in enumerate(cab):
            if 16 in (c['d1'], c['d2']) or 32 in (c['d1'], c['d2']):
                pinned.add(comp[i])
    # ---- preferred colour per component (majority)
    pref = {}
    for r, ms in members.items():
        cnt = collections.Counter(OLD_TO_NEW.get(cab[i]['color'], 'red') for i in ms)
        pref[r] = max(sorted(cnt), key=lambda k: cnt[k])
    # ---- tiles per component (cables we will output), extra corner cables added later
    comp_tiles = collections.defaultdict(set)
    for i, c in enumerate(cab):
        comp_tiles[comp[i]].add(c['pos'])
    def neighbours(pos):
        x, y, z = pos
        return [pos, (x + 1, y, z), (x - 1, y, z), (x, y + 1, z), (x, y - 1, z)]
    # comps touching each tile
    tile_comps = collections.defaultdict(set)
    for r, ts in comp_tiles.items():
        for t in ts:
            tile_comps[t].add(r)
    multiz_tiles = collections.defaultdict(set)  # comp -> tiles of its multiz cables
    for i in multiz_cable:
        multiz_tiles[comp[i]].add(cab[i]['pos'])
    def conflicts_of(r):
        out = set()
        for t in comp_tiles[r]:
            for n in neighbours(t):
                out |= tile_comps.get(n, set())
        # vertical links of multiz cables reach the tile above and below
        for t in multiz_tiles.get(r, ()):
            x, y, z = t
            for n in ((x, y, z - 1), (x, y, z + 1)):
                out |= tile_comps.get(n, set())
        # a multiz cable of another component sitting above/below our tiles
        for t in comp_tiles[r]:
            x, y, z = t
            for n in ((x, y, z - 1), (x, y, z + 1)):
                for other in tile_comps.get(n, set()):
                    if n in multiz_tiles.get(other, ()):
                        out.add(other)
        out.discard(r)
        return out
    # ---- colour assignment, biggest first, pinned first
    order = sorted(members, key=lambda r: (r not in pinned, -len(members[r])))
    color = {}
    unresolved = []
    for r in order:
        used = {color[o] for o in conflicts_of(r) if o in color}
        if pref[r] not in used or r in pinned:
            color[r] = pref[r]
            if pref[r] in used:
                unresolved.append(('pinned colour clash', r))
        else:
            free = [c for c in PALETTE if c not in used]
            if not free:
                unresolved.append(('no free colour', r))
                color[r] = pref[r]
            else:
                color[r] = free[0]
    recoloured = sum(1 for r in members if color[r] != pref[r])
    # ---- diagonal fixes: make each component connected under smartwire rules
    added = []  # (pos, comp)
    def pieces(r):
        ts = comp_tiles[r]
        p = UF()
        for t in ts:
            p.f(t)
            x, y, z = t
            for n in ((x + 1, y, z), (x, y + 1, z)):
                if n in ts:
                    p.u(t, n)
        # vertical links of this component
        for t in multiz_tiles.get(r, ()):
            x, y, z = t
            for n in ((x, y, z - 1), (x, y, z + 1)):
                if n in ts:
                    p.u(t, n)
        return p
    def tile_ok(t, r):
        if t not in group.tile:
            return False
        col = color[r]
        for n in neighbours(t):
            for o in tile_comps.get(n, set()):
                if o != r and color[o] == col:
                    return False
        return True
    for r in members:
        for _ in range(64):
            p = pieces(r)
            roots = {p.f(t) for t in comp_tiles[r]}
            if len(roots) <= 1:
                break
            fixed = False
            for t in sorted(comp_tiles[r]):
                x, y, z = t
                for dx, dy in ((1, 1), (1, -1), (-1, 1), (-1, -1)):
                    o = (x + dx, y + dy, z)
                    if o in comp_tiles[r] and p.f(o) != p.f(t):
                        corners = [(x + dx, y, z), (x, y + dy, z)]
                        corners.sort(key=lambda c: group.turf(c).startswith('/turf/closed'))
                        for cpos in corners:
                            if tile_ok(cpos, r):
                                comp_tiles[r].add(cpos)
                                tile_comps[cpos].add(r)
                                added.append((cpos, r))
                                fixed = True
                                break
                    if fixed:
                        break
                if fixed:
                    break
            if not fixed:
                unresolved.append(('split powernet', r))
                break
    # ---- rewrite tiles
    node_first = {}
    for i, c in enumerate(cab):
        if c['d1'] == 0 and c['pos'] not in node_first:
            node_first[c['pos']] = color[comp[i]]
    out_cables = collections.defaultdict(dict)  # pos -> color -> multiz
    for i, c in enumerate(cab):
        col = color[comp[i]]
        mz = out_cables[c['pos']].get(col, False) or 32 in (c['d1'], c['d2'])
        out_cables[c['pos']][col] = mz
    for pos, r in added:
        out_cables[pos].setdefault(color[r], False)
    changed_tiles = 0
    for pos, cols in out_cables.items():
        atoms = group.tile[pos]
        first = next((k for k, a in enumerate(atoms) if a.startswith(CABLE)), None)
        rest = [a for a in atoms if not a.startswith(CABLE)]
        idx = None if first is None else sum(1 for a in atoms[:first] if not a.startswith(CABLE))
        if idx is None:
            # added corner cable: put it before the turf
            idx = next((k for k, a in enumerate(rest) if a.startswith('/turf') or a.startswith('/area')), len(rest))
        order_cols = sorted(cols, key=lambda c: (c != node_first.get(pos), PALETTE.index(c)))
        new = [cable_path(c, cols[c]) for c in order_cols]
        result = rest[:idx] + new + rest[idx:]
        if result != atoms:
            group.tile[pos] = result
            changed_tiles += 1
    stats = {
        'cables': len(cab), 'powernets': len(members), 'recoloured': recoloured,
        'diagonal_fixes': len(added), 'multiz': sum(1 for i in multiz_cable if 32 in (cab[i]['d1'], cab[i]['d2'])),
        'unresolved': [(why, cab[members[r][0]]['pos']) for why, r in unresolved],
        'added': [p for p, _ in added], 'changed_tiles': changed_tiles,
    }
    log.append(stats)
    return True

def repath_items(atoms):
    out = []
    for a in atoms:
        path, v = dmmlib.parse_map_atom(a)
        if path.startswith('/obj/item/rcl'):
            a = '/obj/item/stack/cable_coil'
        elif path.startswith('/obj/item/stack/cable_coil'):
            sub = path[len('/obj/item/stack/cable_coil'):]
            keep = {k: val for k, val in v.items() if k not in ('cable_color', 'color')}
            if sub.startswith('/cut'):
                newp = '/obj/item/stack/cable_coil/cut'
            elif sub in ('/cyborg', '/one'):
                newp = path
            else:
                newp = '/obj/item/stack/cable_coil'
                if sub == '/random/five' and 'amount' not in keep:
                    keep['amount'] = '5'
            if newp != path or keep != v:
                a = newp if not keep else newp + '{' + '; '.join(f'{k} = {val}' for k, val in keep.items()) + '}'
        out.append(a)
    return out

def save_group(group, write=True):
    z0 = 0
    for f, m, off in zip(group.files, group.maps, group.zoff):
        new = dmmlib.DMM(m.key_length, m.size)
        for (x, y, z), key in m.grid.items():
            atoms = group.tile[(x, y, off + z)]
            atoms = repath_items(atoms)
            new.set_tile((x, y, z), atoms)
        merged = merge_map(new, m)
        if write and merged.to_bytes() != m.to_bytes():
            merged.to_file(f)

def canon(atom):
    # turn "path{a = b; c = d}" into the TGM-parsed representation mapmerge uses
    if '{' not in atom:
        return atom
    path, v = dmmlib.parse_map_atom(atom)
    return path + '{' + '; '.join(f'{k} = {val}' for k, val in v.items()) + '}'

def find_groups(root):
    groups = []
    seen = set()
    for j in glob.glob(os.path.join(root, '_maps', '*.json')):
        try:
            data = json.load(open(j, encoding='utf-8'))
        except Exception:
            continue
        files = data.get('map_file')
        if isinstance(files, str):
            files = [files]
        paths = [os.path.join(root, '_maps', data['map_path'], f) for f in files]
        if all(os.path.exists(p) for p in paths):
            groups.append(paths)
            seen.update(os.path.normpath(p) for p in paths)
    for f in glob.glob(os.path.join(root, '_maps', '**', '*.dmm'), recursive=True) + glob.glob(os.path.join(root, 'aquila', '_maps', '**', '*.dmm'), recursive=True):
        if os.path.normpath(f) not in seen:
            groups.append([f])
    return groups

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('root')
    ap.add_argument('--report')
    ap.add_argument('--only', nargs='*')
    ap.add_argument('--dry', action='store_true')
    a = ap.parse_args()
    rep = []
    for files in find_groups(a.root):
        rel = [os.path.relpath(f, a.root) for f in files]
        if a.only and not any(o in r for o in a.only for r in rel):
            continue
        g = MapGroup(files)
        log = []
        has = convert(g, log)
        save_group(g, write=not a.dry)
        if has:
            s = log[0]
            rep.append((rel, s))
            print(' + '.join(rel), {k: v for k, v in s.items() if k not in ('added',)})
    if a.report:
        with open(a.report, 'w') as f:
            json.dump(rep, f, indent=1)
