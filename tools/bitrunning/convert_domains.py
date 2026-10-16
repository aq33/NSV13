#!/usr/bin/env python3
"""Konwerter map domen bitrunningu z tgstation na kod Aquili.

Użycie:
    python tools/bitrunning/convert_domains.py <ścieżka do checkoutu tg> [mapa ...] [--report plik]

Czyta _maps/virtual_domains/*.dmm i _maps/safehouses/*.dmm z tg, wpieka kryjówkę (safehouse)
w mapę domeny, tłumaczy ścieżki typów według mapping.json oraz reguł poniżej i zapisuje wynik
w _maps/virtual_domains/<nazwa>.dmm naszego repo (format TGM).
"""
import collections
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from dmm import DMM, parse_obj, split_top  # noqa: E402

REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
OUR_DIRS = ['code', 'aquila', 'nsv13', '_maps']

DIRS = {'north': 1, 'south': 2, 'east': 4, 'west': 8}

BUILTIN_VARS = set('''name desc icon icon_state dir pixel_x pixel_y pixel_w pixel_z layer plane color alpha density
opacity luminosity invisibility mouse_opacity tag suffix gender appearance_flags blend_mode maptext maptext_width
maptext_height maptext_x maptext_y step_x step_y glide_size animate_movement screen_loc'''.split())


# ---------------------------------------------------------------------------
# Indeks typów i zmiennych (nasz kod i kod tg)
# ---------------------------------------------------------------------------

def _norm(p):
    p = p.rstrip('/')
    return p if p.startswith('/') else '/' + p


def index_code(root, dirs, want_values=None):
    """Zwraca (types: {typ: set(zmiennych)}, parents: {typ: parent_type}, values: {typ: {zmienna: tekst}}).
    values zbierane tylko dla typów zaczynających się od któregoś z prefiksów want_values."""
    types, parents, values = {}, {}, {}

    def addt(p):
        p = _norm(p)
        if re.search(r'/(proc|verb)(/|$)', p):
            return None
        types.setdefault(p, set())
        return p

    for d in dirs:
        for dp, dn, fn in os.walk(os.path.join(root, d)):
            for f in fn:
                if not f.endswith('.dm'):
                    continue
                try:
                    txt = io.open(os.path.join(dp, f), encoding='utf-8', errors='replace').read()
                except OSError:
                    continue
                txt = re.sub(r'/\*.*?\*/', '', txt, flags=re.S)
                lines = txt.split('\n')
                stack = []
                varblock = None
                i = 0
                while i < len(lines):
                    line = lines[i]
                    i += 1
                    body = line.strip()
                    if not body or body.startswith('//') or body.startswith('#'):
                        continue
                    depth = len(line) - len(line.lstrip('\t'))
                    while stack and stack[-1][0] >= depth:
                        stack.pop()
                    if varblock and depth <= varblock[0]:
                        varblock = None
                    cur = stack[-1][1] if stack else None
                    if varblock and depth > varblock[0]:
                        m = re.match(r'((?:\w+/)*)(\w+)\s*(?:=|$|//)', body)
                        if m and varblock[1]:
                            types.setdefault(varblock[1], set()).add(m.group(2))
                        continue
                    if body == 'var' and cur:
                        varblock = (depth, cur)
                        continue
                    m = re.match(r'^(/?[\w/]*?)/?var/((?:\w+/)*)(\w+)\s*(?:=|$|//|\[|as\b)', body)
                    if m and '(' not in re.sub(r'\s*//.*$', '', body).split('=')[0]:
                        pre = m.group(1)
                        if depth == 0 and pre:
                            t = addt(pre)
                        elif pre:
                            t = addt((cur or '') + '/' + pre.lstrip('/')) if cur else addt(pre)
                        else:
                            t = cur
                        if t:
                            types[t].add(m.group(3))
                        continue
                    m = re.match(r'^(\w+)\s*=\s*(.*)$', body)
                    if m and cur and depth > 0:
                        val = m.group(2)
                        # wartości wielowierszowe (listy)
                        while val.count('(') > val.count(')') and i < len(lines):
                            val += '\n' + lines[i].strip()
                            i += 1
                        val = re.sub(r'\s*//[^\n"]*$', '', val, flags=re.M).strip()
                        if m.group(1) == 'parent_type':
                            parents[cur] = _norm(val.split('//')[0].strip())
                        elif want_values and cur.startswith(want_values):
                            values.setdefault(cur, {})[m.group(1)] = val
                        continue
                    m = re.match(r'^(/?[A-Za-z_][\w/]*)\s*(?:$|//|\{)', body)
                    if not m:
                        if re.match(r'^/?[A-Za-z_][\w/]*\(', body):
                            stack.append((depth, None))
                        mp = re.match(r'^(/[A-Za-z_][\w/]*)\(', body)
                        if mp and depth == 0:
                            pp = mp.group(1)
                            if re.search(r'/(proc|verb)/', pp):
                                pp = re.split(r'/(?:proc|verb)/', pp)[0]
                            else:
                                pp = pp.rsplit('/', 1)[0]
                            if pp:
                                addt(pp)
                        continue
                    if '(' in body.split('//')[0]:
                        continue
                    p = m.group(1)
                    if depth == 0:
                        full = _norm(p)
                    else:
                        if not cur:
                            continue
                        if p in ('proc', 'verb', 'static', 'global', 'tmp', 'const'):
                            stack.append((depth, None))
                            continue
                        full = _norm(cur.rstrip('/') + '/' + p.strip('/'))
                    stack.append((depth, addt(full)))
    return types, parents, values


class Index:
    def __init__(self, types, parents):
        self.types, self.parents = types, parents

    def has(self, t):
        return t in self.types

    def ancestors(self, t):
        out, cur = [], t
        while cur and cur.startswith('/') and cur != '/' and cur not in out:
            out.append(cur)
            cur = self.parents.get(cur) or cur.rsplit('/', 1)[0]
        return out + ['/atom/movable', '/atom', '/datum']

    def has_var(self, t, v):
        if v in BUILTIN_VARS:
            return True
        return any(v in self.types.get(a, ()) for a in self.ancestors(t))

    def is_a(self, t, base):
        return t == base or t.startswith(base + '/')


# ---------------------------------------------------------------------------
# Dane z tg: przesunięcia directional, spawnery losowe
# ---------------------------------------------------------------------------

class TG:
    def __init__(self, root):
        self.root = root
        self.offsets = {}
        defines = {}
        for dp, dn, fn in os.walk(os.path.join(root, 'code')):
            for f in fn:
                if not f.endswith('.dm'):
                    continue
                txt = io.open(os.path.join(dp, f), encoding='utf-8', errors='replace').read()
                for m in re.finditer(r'^#define\s+(\w+)\s+\(?(-?\d+)\)?\s*(?://.*)?$', txt, re.M):
                    defines[m.group(1)] = int(m.group(2))
                for m in re.finditer(r'^MAPPING_DIRECTIONAL_HELPERS\((/[\w/]+),\s*(.+?)\)\s*$', txt, re.M):
                    self.offsets[m.group(1)] = m.group(2).strip()
        for k, v in list(self.offsets.items()):
            v = v.strip('() ')
            if re.fullmatch(r'-?\d+', v):
                self.offsets[k] = int(v)
            elif v in defines:
                self.offsets[k] = defines[v]
            else:
                self.offsets[k] = 32
        types, parents, values = index_code(root, ['code'], want_values=('/obj/effect/spawner/random',))
        self.index = Index(types, parents)
        self.values = values
        self.safehouses = {}
        toml = os.path.join(root, 'strings', 'modular_maps', 'safehouse.toml')
        if os.path.exists(toml):
            cur = None
            for line in io.open(toml, encoding='utf-8'):
                m = re.match(r'\[rooms\.(\w+)\]', line.strip())
                if m:
                    cur = m.group(1)
                m = re.match(r'modules\s*=\s*\["([^"]+)"', line.strip())
                if m and cur:
                    self.safehouses[cur] = m.group(1)

    def offset(self, base):
        cur = base
        while cur and cur != '/':
            if cur in self.offsets:
                return self.offsets[cur]
            cur = cur.rsplit('/', 1)[0]
        return None

    def spawner_vars(self, path):
        out = {}
        for a in reversed(self.index.ancestors(path)):
            out.update(self.values.get(a, {}))
        return out


def parse_loot(text):
    """'list(/a = 2, /b, list(/c, /d) = 3)' -> lista (wpis, waga); wpis to ścieżka albo zagnieżdżona lista."""
    text = text.strip()
    if not text.startswith('list('):
        return []
    inner = text[5:text.rfind(')')]
    out = []
    for part in split_top(inner, ','):
        part = part.strip()
        if not part:
            continue
        w = 1.0
        key = part
        bits = split_top(part, '=')
        if len(bits) == 2:
            key, wv = bits[0].strip(), bits[1].strip()
            try:
                w = float(eval(wv, {}, {}))
            except Exception:
                w = 1.0
        if key.startswith('list('):
            out.append((parse_loot(key), w))
        elif key.startswith('/'):
            out.append((key, w))
    return out


# ---------------------------------------------------------------------------
# Konwerter
# ---------------------------------------------------------------------------

class Converter:
    def __init__(self, tg_root, mapping_path):
        print('indeksuję nasz kod...')
        t, p, _ = index_code(REPO, OUR_DIRS)
        self.ours = Index(t, p)
        print('indeksuję tg...')
        self.tg = TG(tg_root)
        self.tg_root = tg_root
        m = json.load(io.open(mapping_path, encoding='utf-8'))
        self.exact = m['exact']
        self.prefix = m['prefix']
        self.access = m['access']
        self.gasmix = m.get('gas_mix', {})
        self.decal_colors = m['decal_colors']
        self.extra_types = set(m.get('assume_types', []))
        self.var_rename = m.get('var_rename', [])
        self.dir_fix = m.get('dir_fix', [])
        self.drop_var_names = set(m.get('drop_vars', []))
        self.assume_regex = m.get('assume_regex', [])
        self.stats = None
        self.weight = 1
        self.unresolved = collections.Counter()

    # --- pomocnicze -------------------------------------------------------
    def exists(self, path):
        return self.ours.has(path) or path in self.extra_types or any(re.fullmatch(r, path) for r in self.assume_regex)

    def note(self, kind, tgpath, detail=''):
        if self.stats is not None:
            self.stats[kind][(tgpath, detail)] += self.weight

    # --- główna funkcja ----------------------------------------------------
    def conv(self, path, vars_, depth=0):
        """Tłumaczy obiekt tg -> lista obiektów [ścieżka, [(zmienna, wartość)]] (może być pusta)."""
        if depth > 12:
            raise RuntimeError('rekurencja ' + path)
        if path in self.exact:
            return self.apply_spec(path, self.exact[path], vars_, depth)
        m = re.match(r'^(.*)/directional/(north|south|east|west)$', path)
        if m:
            if self.exists(path):
                return [[path, self.clean_vars(path, path, vars_)]]
            base, d = m.group(1), m.group(2)
            off = self.tg.offset(base)
            dv = DIRS[d]
            add = [('dir', str(dv))]
            if off:
                if d == 'north':
                    add.append(('pixel_y', str(off)))
                elif d == 'south':
                    add.append(('pixel_y', str(-off)))
                elif d == 'east':
                    add.append(('pixel_x', str(off)))
                else:
                    add.append(('pixel_x', str(-off)))
            res = self.conv(base, add + list(vars_), depth + 1)
            # nasz kod ma czasem własne podtypy kierunkowe (firealarm, intercom, newscaster...) - wtedy ich używamy
            own = set(k for k, v in vars_)
            for o in res[:1]:
                cand = o[0] + '/directional/' + d
                if not o[0].startswith('@') and self.exists(cand):
                    o[0] = cand
                    o[1] = [kv for kv in o[1] if kv[0] not in ('dir', 'pixel_x', 'pixel_y') or kv[0] in own]
            return res
        m = re.match(r'^(.*)/style_(random|\d+)$', path)
        if m:
            return self.conv(m.group(1), vars_, depth + 1)
        if path.startswith('/obj/effect/spawner/random/'):
            ours = '/obj/effect/spawner/lootdrop/' + path[len('/obj/effect/spawner/random/'):]
            if self.exists(ours):
                return [[ours, self.clean_vars(path, ours, vars_)]]
            return self.random_spawner(path, vars_)
        if path.startswith('/obj/effect/turf_decal/'):
            r = self.decal(path, vars_)
            if r is not None:
                return r
        for a, b in self.prefix:
            if path.startswith(a):
                np = b + path[len(a):]
                if np != path:
                    return self.conv(np, vars_, depth + 1)
        if self.exists(path):
            return [[path, self.clean_vars(path, path, vars_)]]
        self.unresolved[path] += 1
        self.note('dropped', path, 'brak odpowiednika')
        return []

    def apply_spec(self, tgpath, spec, vars_, depth):
        if spec is None:
            self.note('dropped', tgpath, 'celowo pominięte')
            return []
        if isinstance(spec, str):
            spec = {'path': spec}
        if isinstance(spec, list):
            out = []
            for i, s in enumerate(spec):
                inherit = i == 0 or (isinstance(s, dict) and s.get('inherit_vars'))
                out += self.apply_spec(tgpath, s, vars_ if inherit else [], depth)
            return out
        if spec.get('helper'):
            return [['@' + spec['helper'], list(vars_) + [('@spec', json.dumps(spec))]]]
        if spec.get('approx'):
            self.note('approx', tgpath, spec['approx'])
        target = spec['path']
        base_vars = [(k, v) for k, v in spec.get('vars', {}).items()]
        own = [(k, v) for k, v in vars_ if k not in spec.get('drop_vars', [])]
        if spec.get('force_vars'):
            merged = own + base_vars
        else:
            merged = base_vars + own
        if spec.get('dirmap'):
            dm = spec['dirmap']
            merged = [(k, str(dm.get(v, v)) if k == 'dir' else v) for k, v in merged]
            if not any(k == 'dir' for k, v in merged) and '2' in dm:
                merged.append(('dir', str(dm['2'])))
        if target in self.exact and target != tgpath:
            return self.conv(target, merged, depth + 1)
        if not self.exists(target):
            # cel też może wymagać tłumaczenia (np. kierunkowy)
            return self.conv(target, merged, depth + 1)
        return [[target, self.clean_vars(tgpath, target, merged)]]

    # --- zmienne -------------------------------------------------------------
    def clean_vars(self, tgpath, path, vars_):
        out = collections.OrderedDict()
        for k, v in vars_:
            if k.startswith('@') or k in self.drop_var_names:
                if not k.startswith('@'):
                    self.note('var_dropped', tgpath, k)
                continue
            if k in ('req_access', 'req_one_access'):
                conv = self.conv_access(v)
                if conv is None:
                    continue
                k, v = k + '_txt', conv
            for r in self.var_rename:
                if k == r['from'] and self.ours.is_a(path, r['type']):
                    k, v = r['to'], r.get('values', {}).get(v, v)
            if k == 'initial_gas_mix' and v.strip('"') in self.gasmix:
                v = '"%s"' % self.gasmix[v.strip('"')]
            if re.search(r'(^|[\s(,=])/(obj|mob|turf|area|datum)/', v) and k not in ('control_area',):
                v2 = self.conv_typepaths(v)
                if v2 is None:
                    self.note('var_dropped', tgpath, '%s = %s' % (k, v))
                    continue
                v = v2
            if not self.ours.has_var(path, k):
                self.note('var_dropped', tgpath, k)
                continue
            out[k] = v
        for fix in self.dir_fix:
            if path == fix['type'] and 'dir' in out:
                out['dir'] = str(fix['dirmap'].get(out['dir'], out['dir']))
        # zero pikseli to szum
        return [(k, v) for k, v in out.items() if not (k in ('pixel_x', 'pixel_y') and v.strip() == '0')]

    def conv_access(self, v):
        v = v.strip()
        if v == 'null':
            return None
        names = re.findall(r'"([^"]*)"', v)
        nums = []
        for n in names:
            if n in self.access:
                if self.access[n] is not None:
                    nums.append(str(self.access[n]))
        if not nums:
            return None
        return '"%s"' % ';'.join(nums)

    def conv_typepaths(self, v):
        bad = False

        def rep(m):
            nonlocal bad
            p = m.group(0)
            r = self.conv_path(p)
            if r is None:
                bad = True
                return p
            return r
        out = re.sub(r'/(?:obj|mob|turf|area|datum)(?:/\w+)+', rep, v)
        return None if bad else out

    def conv_path(self, p):
        """Tłumaczenie samej ścieżki (do list łupów i zmiennych typu typepath)."""
        if p.startswith('/datum/'):
            return p if self.exists(p) else None
        saved, saved_u = self.stats, self.unresolved
        self.stats, self.unresolved = None, collections.Counter()
        try:
            r = self.conv(p, [])
        finally:
            self.stats, self.unresolved = saved, saved_u
        if len(r) == 1 and not r[0][0].startswith('@') and not r[0][1]:
            return r[0][0]
        if len(r) >= 1 and not r[0][0].startswith('@'):
            return r[0][0]
        return None

    # --- spawnery losowe ------------------------------------------------------
    def flatten_loot(self, entries, depth=0):
        out = collections.Counter()
        total = sum(w for e, w in entries) or 1
        for e, w in entries:
            frac = w / total
            if isinstance(e, list):
                for k, v in self.flatten_loot(e, depth + 1).items():
                    out[k] += frac * v
                continue
            if e.startswith('/obj/effect/spawner/random/') and depth < 6:
                ours = '/obj/effect/spawner/lootdrop/' + e[len('/obj/effect/spawner/random/'):]
                if e not in self.exact and not self.exists(ours):
                    sub = self.spawner_loot(e, depth + 1)
                    for k, v in sub.items():
                        out[k] += frac * v
                    continue
            out[e] += frac
        return out

    def spawner_loot(self, path, depth=0):
        sv = self.tg.spawner_vars(path)
        entries = parse_loot(sv.get('loot', 'list()'))
        if not entries and sv.get('loot_type_path'):
            entries = [(sv['loot_type_path'].strip(), 1)]
        return self.flatten_loot(entries, depth)

    LOOT_SUFFIXES = ('empty', 'full', 'filled', 'loaded', 'random', 'unrestricted', 'old', 'spent', 'prearmed',
                     'no_lid', 'lit', 'on', 'off', 'preopen', 'stocked', 'all_access', 'cyborg', 'single', 'five',
                     'ten', 'twenty', 'thirty', 'fifty', 'half', 'mapload', 'premium', 'deluxe', 'small', 'large',
                     'contraband', 'surplus', 'single_use', 'blue', 'syndie', 'less_mods', 'crew')

    def loot_fallback(self, p):
        """Dla wpisów list łupów: zdejmujemy końcówki-modyfikatory (empty, full, ...) i próbujemy ponownie."""
        cur = p
        while cur.rsplit('/', 1)[-1] in self.LOOT_SUFFIXES and cur.count('/') > 3:
            cur = cur.rsplit('/', 1)[0]
            r = self.conv_path(cur)
            if r:
                return r
        return None

    def random_spawner(self, path, vars_):
        sv = self.tg.spawner_vars(path)
        loot = self.spawner_loot(path)
        mapped = collections.Counter()
        for p, w in loot.items():
            r = self.conv_path(p) or self.loot_fallback(p)
            if r and r.startswith('/') and not r.startswith('/obj/effect/spawner/random'):
                mapped[r] += w
        if not mapped:
            self.note('dropped', path, 'pusty spawner po tłumaczeniu')
            return []
        self.note('approx', path, 'spawner tg -> lootdrop z przetłumaczoną listą')
        tot = sum(mapped.values())
        items = sorted(mapped.items(), key=lambda kv: -kv[1])
        parts = ['%s = %d' % (p, max(1, round(1000 * w / tot))) for p, w in items]
        chance = sv.get('spawn_loot_chance', '100').strip()
        try:
            chance = float(chance)
        except ValueError:
            chance = 100
        if chance < 100:
            parts.append('"" = %d' % round(1000 * (100 - chance) / max(chance, 1)))
        out = [('loot', 'list(%s)' % ', '.join(parts))]
        cnt = sv.get('spawn_loot_count', '1').strip()
        if sv.get('spawn_all_loot', 'FALSE').strip() == 'TRUE':
            out.append(('lootcount', str(len(items))))
            out.append(('lootdoubles', '0'))
        elif cnt.isdigit() and cnt != '1':
            out.append(('lootcount', cnt))
        name = sv.get('name')
        if name:
            out.append(('name', name))
        for k, v in vars_:
            if k in ('pixel_x', 'pixel_y', 'name'):
                out.append((k, v))
        return [['/obj/effect/spawner/lootdrop', out]]

    # --- naklejki podłogowe -----------------------------------------------------
    TILE_SHAPES = {
        '': ('tile_corner', None),
        'half': ('flat_side', None),
        'half/contrasted': ('tile_side', {2: 8, 1: 4, 4: 2, 8: 1}),
        'anticorner': ('flat_side', {2: 9, 1: 10, 4: 6, 8: 5}),
        'anticorner/contrasted': ('tile_side', {2: 9, 1: 10, 4: 6, 8: 5}),
        'fourcorners': ('tile_full', None),
        'full': ('flat_full', None),
        'opposingcorners': ('tile_marquee', {2: 2, 1: 1, 4: 2, 8: 1}),
    }

    def decal(self, path, vars_):
        m = re.match(r'^/obj/effect/turf_decal/tile/(\w+)(?:/(.*))?$', path)
        if m and m.group(1) in self.decal_colors['tile']:
            if self.exists(path):
                return None
            color, alpha = self.decal_colors['tile'][m.group(1)]
            shape = m.group(2) or ''
            if shape not in self.TILE_SHAPES:
                return None
            state, dm = self.TILE_SHAPES[shape]
            d = 2
            rest = []
            for k, v in vars_:
                if k == 'dir':
                    d = int(v)
                else:
                    rest.append((k, v))
            if dm:
                d = dm.get(d, d)
            out = [('icon_state', '"%s"' % state), ('color', '"%s"' % color)]
            if alpha != 110:
                out.append(('alpha', str(alpha)))
            if d != 2 and state != 'tile_full' and state != 'flat_full':
                out.append(('dir', str(d)))
            self.note('approx', path, 'naklejka tg -> /obj/effect/turf_decal/tile z ikoną i kolorem')
            return [['/obj/effect/turf_decal/tile', out + rest]]
        m = re.match(r'^/obj/effect/turf_decal/siding/(\w+)(?:/(corner|end|inner_corner))?$', path)
        if m and m.group(1) in self.decal_colors['siding']:
            if self.exists(path):
                return None
            state = {None: 'siding_line', 'corner': 'siding_corner', 'end': 'siding_end',
                     'inner_corner': 'siding_corner'}[m.group(2)]
            out = [('icon_state', '"%s"' % state), ('color', '"%s"' % self.decal_colors['siding'][m.group(1)])]
            self.note('approx', path, 'siding tg -> /obj/effect/turf_decal/siding z kolorem')
            return [['/obj/effect/turf_decal/siding', out + list(vars_)]]
        m = re.match(r'^/obj/effect/turf_decal/trimline/(\w+)/(.*)$', path)
        if m and m.group(1) in self.decal_colors['trimline'] and not self.exists(path):
            states = {'line': 'trimline', 'corner': 'trimline_corner', 'end': 'trimline_end',
                      'filled/line': 'trimline_fill', 'filled/corner': 'trimline_corner_fill',
                      'filled/end': 'trimline_end_fill', 'warning': 'trimline_warn',
                      'filled/warning': 'trimline_warn_fill', 'filled/warning/corner': 'trimline_warn_fill',
                      'arrow_cw': 'trimline_arrow_cw', 'arrow_ccw': 'trimline_arrow_ccw'}
            if m.group(2) in states:
                out = [('icon_state', '"%s"' % states[m.group(2)]),
                       ('color', '"%s"' % self.decal_colors['trimline'][m.group(1)])]
                self.note('approx', path, 'trimline tg -> /obj/effect/turf_decal/trimline z kolorem')
                return [['/obj/effect/turf_decal/trimline', out + list(vars_)]]
        return None

    # --- rury "smart" z tg ---------------------------------------------------------
    SMART_RE = re.compile(r'^/obj/machinery/atmospherics/pipe/smart/(?:simple|manifold|manifold4w)/(\w+)/(visible|hidden)(?:/layer(\d))?$')
    COMP_RE = re.compile(r'^/obj/machinery/atmospherics/components/unary/[\w/]*?(?:/layer(\d))?$')

    def resolve_smart_pipes(self, dom):
        """Rury smart z tg łączą się same; u nas kształt (prosta/kolano/trójnik/czwórnik) i dir trzeba podać."""
        def pipes_at(pos):
            out = []
            for o in dom.keys.get(dom.grid.get(pos), []):
                m = self.SMART_RE.match(o[0])
                if m:
                    out.append((m.group(1), int(m.group(3) or 3)))
            return out

        def comps_at(pos):
            out = []
            for o in dom.keys.get(dom.grid.get(pos), []):
                m = self.COMP_RE.match(o[0])
                if m:
                    out.append((int(m.group(1) or 3), int(dict(o[1]).get('dir', '2'))))
            return out
        rev = {1: 2, 2: 1, 4: 8, 8: 4}
        step = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
        changes = {}
        for pos, k in list(dom.grid.items()):
            objs = dom.keys[k]
            if not any(self.SMART_RE.match(o[0]) for o in objs):
                continue
            new = []
            for o in objs:
                m = self.SMART_RE.match(o[0])
                if not m:
                    new.append(o)
                    continue
                color, vis, layer = m.group(1), m.group(2), int(m.group(3) or 3)
                conn = 0
                for d, (dx, dy) in step.items():
                    npos = (pos[0] + dx, pos[1] + dy, pos[2])
                    if (color, layer) in pipes_at(npos) or (layer, rev[d]) in comps_at(npos):
                        conn |= d
                bits = [d for d in (1, 2, 4, 8) if conn & d]
                suffix = '/%s/%s%s' % (color, vis, '' if layer == 3 else '/layer%d' % layer)
                if len(bits) == 4:
                    np, nd = 'manifold4w', None
                elif len(bits) == 3:
                    np, nd = 'manifold', 15 & ~conn
                elif len(bits) == 2:
                    np = 'simple'
                    nd = 1 if conn == 3 else 4 if conn == 12 else conn
                elif len(bits) == 1:
                    np, nd = 'simple', (1 if bits[0] in (1, 2) else 4)
                else:
                    self.note('dropped', o[0], 'rura bez połączeń')
                    continue
                vars_ = [kv for kv in o[1] if kv[0] != 'dir']
                if nd and nd != 2:
                    vars_.append(('dir', str(nd)))
                new.append(['/obj/machinery/atmospherics/pipe/' + np + suffix, vars_])
            changes[pos] = new
        for pos, objs in changes.items():
            nk = 'PP%d_%d_%d' % pos
            dom.keys[nk] = objs
            dom.grid[pos] = nk

    # --- kryjówki ---------------------------------------------------------------
    def bake_safehouse(self, dom, name):
        roots = [(pos, o) for pos, k in dom.grid.items() for o in dom.keys[k] if o[0].startswith('/obj/modular_map_root')]
        if not roots:
            return None
        if len(roots) > 1:
            raise SystemExit('%s: więcej niż jeden modular_map_root' % name)
        (rx, ry, rz), root = roots[0]
        key = dict(root[1]).get('key', '').strip('"')
        fname = self.tg.safehouses.get(key, key + '.dmm')
        sh_path = os.path.join(self.tg_root, '_maps', 'safehouses', fname)
        sh = DMM(io.open(sh_path, encoding='utf-8').read())
        conn = [pos for pos, k in sh.grid.items() if any(o[0] == '/obj/modular_map_connector' for o in sh.keys[k])]
        cx, cy = (conn[0][0], conn[0][1]) if conn else (1, 1)
        ox, oy = rx - cx, ry - cy
        tiles = {}
        kept = 0
        for (x, y, z), k in sh.grid.items():
            tx, ty = x + ox, y + oy
            if (tx, ty, rz) not in dom.grid:
                continue
            s_objs = [o for o in sh.keys[k] if not o[0].startswith(('/obj/modular_map_connector', '/obj/modular_map_root'))]
            d_objs = [o for o in dom.keys[dom.grid[(tx, ty, rz)]] if not o[0].startswith('/obj/modular_map_root')]
            s_turf = [o for o in s_objs if o[0].startswith('/turf')]
            s_area = [o for o in s_objs if o[0].startswith('/area')]
            s_mov = [o for o in s_objs if not o[0].startswith(('/turf', '/area'))]
            d_turf = [o for o in d_objs if o[0].startswith('/turf')]
            d_area = [o for o in d_objs if o[0].startswith('/area')]
            d_mov = [o for o in d_objs if not o[0].startswith(('/turf', '/area'))]
            turf = d_turf if (not s_turf or s_turf[0][0] == '/turf/template_noop') else s_turf
            area = d_area if (not s_area or s_area[0][0] == '/area/template_noop') else s_area
            # jak w tg: obiekty domeny zostają (mapy kładą tak np. sprzęt w kryjówce), kryjówka dokłada swoje
            kept += len(d_mov)
            self.sh_kept.extend(o[0] for o in d_mov)
            tiles[(tx, ty, rz)] = d_mov + s_mov + turf + area
        # pole root usuwamy zawsze
        if (rx, ry, rz) not in tiles:
            tiles[(rx, ry, rz)] = [o for o in dom.keys[dom.grid[(rx, ry, rz)]] if not o[0].startswith('/obj/modular_map_root')]
        for pos, objs in tiles.items():
            nk = 'SH%d_%d' % (pos[0], pos[1])
            dom.keys[nk] = objs
            dom.grid[pos] = nk
        return key, fname, kept

    # --- jedna mapa -------------------------------------------------------------
    def convert_map(self, name, out_path):
        self.stats = collections.defaultdict(collections.Counter)
        src = os.path.join(self.tg_root, '_maps', 'virtual_domains', name + '.dmm')
        dom = DMM(io.open(src, encoding='utf-8').read())
        self.sh_kept = []
        sh = self.bake_safehouse(dom, name)
        self.resolve_smart_pipes(dom)
        cache = {}
        newkeys = {}
        grid = {}
        freq = collections.Counter(dom.grid.values())
        for pos, k in dom.grid.items():
            if k not in cache:
                self.weight = freq[k]
                cache[k] = self.convert_tile(dom.keys[k])
            objs = cache[k]
            sig = json.dumps(objs)
            if sig not in newkeys:
                newkeys[sig] = 'k%d' % len(newkeys)
            grid[pos] = newkeys[sig]
        out = DMM.__new__(DMM)
        out.keys = {v: [[p, [tuple(kv) for kv in vs]] for p, vs in json.loads(s)] for s, v in newkeys.items()}
        out.grid = grid
        out.maxx, out.maxy, out.maxz = dom.maxx, dom.maxy, dom.maxz
        out.write(out_path)
        st, self.stats = self.stats, None
        return st, sh

    def convert_tile(self, objs):
        res = []
        helpers = []
        for path, vars_ in objs:
            if path.startswith('/area'):
                continue
            for o in self.conv(path, vars_):
                if o[0].startswith('@'):
                    helpers.append(o)
                else:
                    res.append(o)
        areas = [o for o in objs if o[0].startswith('/area')]
        area_out = []
        for path, vars_ in areas:
            area_out += self.conv(path, vars_)
        turfs = [o for o in res if o[0].startswith('/turf')]
        movs = [o for o in res if not o[0].startswith('/turf')]
        if not turfs:
            turfs = [['/turf/template_noop', []]]
            self.note('approx', '(pole bez podłogi)', 'template_noop')
        turfs = turfs[-1:]
        for h in helpers:
            self.apply_helper(h, movs, turfs)
        if not area_out:
            area_out = [['/area/template_noop', []]]
        return [[p, [list(kv) for kv in v]] for p, v in movs + turfs + area_out[-1:]]

    def apply_helper(self, h, movs, turfs):
        name = h[0][1:]
        spec = json.loads(dict(h[1])['@spec'])
        turf = turfs[0]
        if name == 'turf_state':
            # uszkodzona/spalona podłoga: wybieramy stan ikony zależnie od typu podłogi
            states = spec['states']
            tp = turf[0]
            for prefix, st in states:
                if tp.startswith(prefix):
                    turf[1] = [kv for kv in turf[1] if kv[0] != 'icon_state'] + [('icon_state', '"%s"' % st)]
                    return
            return
        if name == 'set_var':
            for o in movs:
                if any(o[0].startswith(t) for t in spec['targets']):
                    for k, v in spec['vars'].items():
                        if self.ours.has_var(o[0], k):
                            o[1] = [kv for kv in o[1] if kv[0] != k] + [(k, v)]
            return
        if name == 'turf_replace':
            # tg broken_flooring (kawałki płytek na kratownicy) -> uszkodzona podłoga
            if turf[0] == spec['from']:
                turf[0] = spec['to']
                turf[1] = [kv for kv in turf[1] if kv[0] not in spec['vars']] + list(spec['vars'].items())
            return
        if name == 'drop':
            return
        raise SystemExit('nieznany helper ' + name)


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(1)
    report = None
    if '--report' in args:
        i = args.index('--report')
        report = args[i + 1]
        del args[i:i + 2]
    tg_root = args[0]
    maps = args[1:]
    conv = Converter(tg_root, os.path.join(HERE, 'mapping.json'))
    src_dir = os.path.join(tg_root, '_maps', 'virtual_domains')
    if not maps:
        maps = sorted(f[:-4] for f in os.listdir(src_dir) if f.endswith('.dmm'))
    out_dir = os.path.join(REPO, '_maps', 'virtual_domains')
    os.makedirs(out_dir, exist_ok=True)
    lines = []
    for name in maps:
        st, sh = conv.convert_map(name, os.path.join(out_dir, name + '.dmm'))
        dropped = sum(st['dropped'].values())
        approx = sum(st['approx'].values())
        print('%-24s safehouse=%s pominięte=%d przybliżone=%d zmienne_pominięte=%d' % (
            name, sh[0] if sh else '-', dropped, approx, sum(st['var_dropped'].values())))
        lines.append('## %s (kryjówka: %s)' % (name, ('%s, obiektów domeny na jej polach: %d' % (sh[1], sh[2])) if sh else 'brak'))
        if conv.sh_kept:
            lines.append('obiekty domeny na polach kryjówki: ' + ', '.join('%dx %s' % (n, p) for p, n in collections.Counter(conv.sh_kept).most_common()))
        for kind in ('dropped', 'approx', 'var_dropped'):
            if st[kind]:
                lines.append('### ' + kind)
                for (p, d), n in sorted(st[kind].items(), key=lambda kv: -kv[1]):
                    lines.append('- %dx %s %s' % (n, p, d))
        lines.append('')
    if conv.unresolved:
        print('\nNIEROZWIĄZANE TYPY:')
        for p, n in conv.unresolved.most_common():
            print('  %4d %s' % (n, p))
    if report:
        io.open(report, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main()
