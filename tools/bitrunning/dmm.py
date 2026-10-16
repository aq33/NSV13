"""Minimal DMM (TGM and classic) parser/writer used for porting bitrunning maps."""
import re

def split_top(s, sep):
    """Split s by sep at nesting depth 0, ignoring quoted strings."""
    out, cur, depth, q = [], [], 0, None
    i = 0
    while i < len(s):
        ch = s[i]
        if q:
            cur.append(ch)
            if ch == '\\':
                cur.append(s[i + 1]); i += 2; continue
            if ch == q:
                q = None
        elif ch in '"\'':
            q = ch; cur.append(ch)
        elif ch in '({[':
            depth += 1; cur.append(ch)
        elif ch in ')}]':
            depth -= 1; cur.append(ch)
        elif ch == sep and depth == 0:
            out.append(''.join(cur)); cur = []
        else:
            cur.append(ch)
        i += 1
    out.append(''.join(cur))
    return out


def parse_obj(s):
    """'/obj/x{a = 1; b = "q"}' -> (path, [(k, v)...])"""
    s = s.strip()
    m = re.match(r'(/[\w/]+)\s*(\{(.*)\})?\s*$', s, re.S)
    if not m:
        raise ValueError('bad obj ' + s[:80])
    path = m.group(1)
    vars_ = []
    if m.group(3) is not None:
        body = m.group(3)
        for part in split_top(body, ';'):
            part = part.strip()
            if not part:
                continue
            k, v = part.split('=', 1)
            vars_.append((k.strip(), v.strip()))
    return [path, vars_]


def fmt_obj(o, tgm=True):
    path, vars_ = o
    if not vars_:
        return path
    if tgm:
        return path + '{\n' + ';\n'.join('\t%s = %s' % kv for kv in vars_) + '\n\t}'
    return path + '{' + '; '.join('%s = %s' % kv for kv in vars_) + '}'


class DMM:
    def __init__(self, text):
        self.keys = {}      # key -> list of objs
        self.order = []
        self.grid = {}      # (x,y,z) -> key
        self.parse(text)

    def parse(self, text):
        body_start = None
        pos = 0
        defs = re.compile(r'^"([A-Za-z]+)" = \((.*?)\)\n(?=("|\n|\())', re.S | re.M)
        # robust: iterate definitions until we hit the grid "(1,1,1)"
        gi = text.find('\n(1,1,')
        if gi < 0:
            gi = text.find('(1,1,')
        head, grid = text[:gi], text[gi:]
        for m in re.finditer(r'^"([A-Za-z]+)" = \(', head, re.M):
            start = m.end()
            # find matching close paren
            depth, i, q = 1, start, None
            while depth:
                ch = head[i]
                if q:
                    if ch == '\\':
                        i += 2; continue
                    if ch == q:
                        q = None
                elif ch in '"\'':
                    q = ch
                elif ch == '(':
                    depth += 1
                elif ch == ')':
                    depth -= 1
                i += 1
            content = head[start:i - 1]
            objs = [parse_obj(p) for p in split_top(content, ',') if p.strip()]
            k = m.group(1)
            self.keys[k] = objs
            self.order.append(k)
            self.keylen = len(k)
        for m in re.finditer(r'\((\d+),(\d+),(\d+)\) = \{"\n?(.*?)\n?"\}', grid, re.S):
            x0, y0, z = int(m.group(1)), int(m.group(2)), int(m.group(3))
            rows = [r for r in m.group(4).split('\n')]
            kl = self.keylen
            if len(rows) == 1 and len(rows[0]) > kl:
                # classic format: row of keys, many rows
                pass
            # TGM: each block is one column (x0), rows top->bottom
            if all(len(r) == kl for r in rows):
                n = len(rows)
                for i, k in enumerate(rows):
                    self.grid[(x0, y0 + n - 1 - i, z)] = k
            else:
                n = len(rows)
                for i, r in enumerate(rows):
                    for j in range(0, len(r), kl):
                        self.grid[(x0 + j // kl, y0 + n - 1 - i, z)] = r[j:j + kl]
        xs = [p[0] for p in self.grid]; ys = [p[1] for p in self.grid]; zs = [p[2] for p in self.grid]
        self.maxx, self.maxy, self.maxz = max(xs), max(ys), max(zs)

    def at(self, x, y, z=1):
        return self.keys[self.grid[(x, y, z)]]

    def write(self, path):
        used = sorted(set(self.grid.values()))
        # re-key compactly
        import itertools, string
        letters = string.ascii_letters
        n = len(self.keys)
        kl = 1
        while len(letters) ** kl < n:
            kl += 1
        out = ['//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE']
        newkey = {}
        gen = (''.join(p) for p in itertools.product(letters, repeat=kl))
        for k in sorted(self.keys):
            newkey[k] = next(gen)
            out.append('"%s" = (\n%s)' % (newkey[k], ',\n'.join(fmt_obj(o) for o in self.keys[k])))
        out.append('')
        for z in range(1, self.maxz + 1):
            for x in range(1, self.maxx + 1):
                col = [newkey[self.grid[(x, y, z)]] for y in range(self.maxy, 0, -1)]
                out.append('(%d,1,%d) = {"\n%s\n"}' % (x, z, '\n'.join(col)))
        open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
