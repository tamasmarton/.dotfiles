#!/usr/bin/env python3
"""Terminal screenshot generator for the README: one PNG per palette (themes/*.toml).

  docs/screenshots/render.py [palette ...]     # default: all palettes (headless browser; needs a GUI
                                               # session, if it hangs use --serve)

  docs/screenshots/render.py --serve [palette ...]   # local server: open the printed URLs in any
                                                     # Chromium-based browser, the page saves the PNG itself

Needs: chezmoi (reads the palettes), a Chromium-based browser (Brave/Chrome) and the JetBrainsMono
Nerd Font Mono installed. Output: docs/img/terminal-<name>.png
"""
import glob
import html
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(REPO, "docs", "img")
BROWSERS = [
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
]
FONT = "'JetBrainsMono Nerd Font Mono', 'JetBrainsMono NFM', 'JetBrains Mono', monospace"

# Nerd Font ikonok (private use area)
I_FOLDER, I_BRANCH, I_NODE, I_GO = "", "", "", ""
I_TS, I_MD, I_JSON, I_TOML, I_LUA, I_GIT = "", "", "", "", "", ""


def palette(name):
    tpl = '{{ $p := include "%s" | fromToml }}{{ $p.theme | toJson }}' % os.path.join(REPO, "themes", name + ".toml")
    out = subprocess.run(["chezmoi", "execute-template", "--source", REPO, tpl], check=True, capture_output=True, text=True).stdout
    return json.loads(out)


class Ctx:
    def __init__(self, t):
        self.t = t

    def span(self, color, text, bold=False, italic=False, bg=None):
        style = "color:%s;" % color
        if bold:
            style += "font-weight:700;"
        if italic:
            style += "font-style:italic;"
        if bg:
            style += "background:%s;" % bg
        return '<span style="%s">%s</span>' % (style, html.escape(text))


def highlight_ts(c, line):
    t, s = c.t, c.t["syntax"]
    kw = {"import", "export", "from", "return", "if", "await", "else"}
    st = {"const", "let", "async", "function", "interface", "type", "as", "new"}
    types = {"Hono", "User", "Config", "Promise", "Response"}
    funcs = {"fetchUser", "fetch", "get", "json", "uptime", "ok"}
    params = {"id", "retries"}
    props = {"port", "debug", "uptime", "ok", "res"}
    tok = re.compile(r'(//.*$)|("[^"]*"|`[^`]*`)|(\b\d+\b)|([A-Za-z_][A-Za-z_0-9]*)|(=>|[=<>!?:;,.(){}\[\]|+\-*/])|(\s+)|(.)')
    out = []
    pos = 0
    for m in tok.finditer(line):
        txt = m.group(0)
        if m.group(1):
            out.append(c.span(s["comment"], txt, italic=True))
        elif m.group(2):
            out.append(c.span(s["string"], txt))
        elif m.group(3):
            out.append(c.span(s["number"], txt))
        elif m.group(4):
            w = txt
            nxt = line[m.end():m.end() + 1]
            prev = line[:m.start()].rstrip()[-1:] if line[:m.start()].strip() else ""
            if w in kw:
                out.append(c.span(s["keyword"], w))
            elif w in st:
                out.append(c.span(s["storage"], w))
            elif w in ("true", "false", "null"):
                out.append(c.span(s["number"], w))
            elif w in types or (w[0].isupper() and not w.isupper()):
                out.append(c.span(s["type"], w))
            elif w.isupper() and len(w) > 2:
                out.append(c.span(s["constant"], w))
            elif nxt == "(" or w in ("fetchUser",) and prev != ":":
                out.append(c.span(s["func"], w))
            elif prev == "." or (nxt == ":" and prev in "{,"):
                out.append(c.span(s["property"], w))
            elif w in params or w == "c":
                out.append(c.span(s["parameter"], w, italic=True))
            else:
                out.append(c.span(s["variable"], w))
        elif m.group(5):
            out.append(c.span(s["operator"], txt))
        else:
            out.append(html.escape(txt))
    return "".join(out)


CODE = [
    'import { Hono } from "hono";',
    'import type { User } from "./types";',
    '',
    'const app = new Hono();',
    'const MAX_RETRIES = 3; // retry budget',
    '',
    'interface Config { port: number; debug?: boolean }',
    '',
    'export async function fetchUser(id: string, retries = MAX_RETRIES): Promise<User | null> {',
    '  const res = await fetch(`/api/users/${id}`);',
    '  if (!res.ok) {',
    '    return retries > 0 ? fetchUser(id, retries - 1) : null;',
    '  }',
    '  return (await res.json()) as User;',
    '}',
    '',
    'app.get("/health", (c) => c.json({ ok: true, uptime: process.uptime() }));',
]


def build(name, t):
    c = Ctx(t)
    a, b, x = t["ansi"], t["bright"], t["extra"]
    fg, bgc, muted = t["fg"], t["bg"], t["muted"]
    L = []  # terminal lines (html strings)

    def prompt(cmd_html):
        L.append(
            c.span(a["cyan"], I_FOLDER + " ~/Developer/api", bold=True) + " "
            + c.span(x["pink"], I_BRANCH + " main") + " "
            + c.span(a["yellow"], "⇡1 !2") + " "
            + c.span(a["green"], "❯", bold=True) + " " + cmd_html)

    # 1) eza
    prompt(c.span(a["green"], "eza") + " " + c.span(t["syntax"]["property"], "-l --icons --git"))
    rows = [
        ("d", "-", "src", I_FOLDER, a["blue"], "M"),
        ("-", "1.2k", "README.md", I_MD, fg, "M"),
        ("-", "842", "package.json", I_JSON, a["yellow"], "-"),
        ("-", "3.1k", "server.ts", I_TS, a["cyan"], "M"),
        ("-", "512", "go.mod", I_GO, a["cyan"], "-"),
        ("-", "204", "mise.toml", I_TOML, a["green"], "N"),
    ]
    for kind, size, fname, icon, ncol, git in rows:
        perms = ("d" if kind == "d" else ".") + "rwxr-xr-x" if kind == "d" else ".rw-r--r--"
        pr = "".join(c.span({"d": a["blue"], "r": a["yellow"], "w": a["red"], "x": a["green"], "-": muted, ".": muted}.get(ch, fg), ch) for ch in perms)
        gcol = {"M": a["yellow"], "N": a["green"], "-": muted}[git]
        L.append(pr + " " + c.span(a["green"], size.rjust(5), bold=True) + " " + c.span(a["yellow"], "tamas") + " "
                 + c.span(a["blue"], "18 Nov 10:42") + " " + c.span(gcol, git, bold=True) + " "
                 + c.span(ncol, icon + " " + fname + ("/" if kind == "d" else ""), bold=(kind == "d")))
    L.append("")

    # 2) bat
    prompt(c.span(a["green"], "bat") + " " + c.span(fg, "src/server.ts"))
    L.append(c.span(muted, "───────┬" + "─" * 70))
    L.append(c.span(muted, "       │ ") + c.span(fg, "File: ") + c.span(fg, "src/server.ts", bold=True))
    L.append(c.span(muted, "───────┼" + "─" * 70))
    for n, line in enumerate(CODE, 1):
        L.append(c.span(muted, str(n).rjust(5) + "  │ ") + highlight_ts(c, line))
    L.append(c.span(muted, "───────┴" + "─" * 70))
    L.append("")

    # 3) git log
    prompt(c.span(a["green"], "git") + " log --oneline --graph -4")
    log = [
        ("*", "a1b2c3d", " (HEAD -> main, origin/main)", "feat: selectable palettes and a theme switcher"),
        ("*", "9f8e7d6", "", "fix(zsh): fast startup with a static antidote bundle"),
        ("*", "5c4b3a2", "", "docs: tmux, herdr and omp usage guides"),
        ("*", "1d2e3f4", "", "chore: bump lazy-lock.json"),
    ]
    for g, h, refs, msg in log:
        line = c.span(a["red"], g) + " " + c.span(a["yellow"], h)
        if refs:
            line += c.span(a["yellow"], " (") + c.span(b["cyan"], "HEAD -> ", bold=True) + c.span(a["green"], "main", bold=True) + c.span(a["yellow"], ", ") + c.span(a["red"], "origin/main") + c.span(a["yellow"], ")")
        L.append(line + " " + c.span(fg, msg))
    L.append("")

    # 4) színek
    prompt(c.span(a["green"], "colors"))
    def sw(row, label):
        names = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
        cells = "".join('<span style="display:inline-block;width:6ch;height:1.32em;vertical-align:top;background:%s"></span> ' % row[n] for n in names)
        return c.span(muted, label.ljust(7)) + cells
    L.append(sw(a, "normal"))
    L.append(sw(b, "bright"))
    L.append("")
    L.append(c.span(a["cyan"], I_FOLDER + " ~/Developer/api", bold=True) + " " + c.span(x["pink"], I_BRANCH + " main") + " "
             + c.span(a["green"], "❯", bold=True) + " " + '<span class="cursor"></span>')

    body = "\n".join(L)
    title = name.title()
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>
html,body{{margin:0;background:{bgc};}}
#stage{{width:1400px;box-sizing:border-box;padding:50px 60px 28px;position:relative;overflow:hidden;
  background:radial-gradient(1200px 700px at 15% 0%, {t['accent']}33, transparent 60%),
             radial-gradient(1000px 700px at 100% 100%, {x['pink']}26, transparent 60%), #05080c;
  font-family:{FONT};}}
.win{{position:relative;width:1280px;border-radius:14px;overflow:hidden;background:{bgc};
  box-shadow:0 40px 90px #000a, 0 0 0 1px {t['border']}88;}}
.bar{{height:42px;background:{t['bg_alt']};display:flex;align-items:center;padding:0 16px;gap:9px;}}
.dot{{width:13px;height:13px;border-radius:50%;}}
.ttl{{flex:1;text-align:center;color:{muted};font-size:13px;margin-right:60px;}}
.tmux{{height:30px;background:{t['bg_alt']};display:flex;align-items:center;justify-content:space-between;font-size:14px;padding:0 6px;border-top:1px solid {t['bg_highlight']};}}
.tmux .l span{{padding:3px 9px;}}
pre{{margin:0;padding:18px 22px 26px;font-family:{FONT};font-size:15.5px;line-height:1.32;color:{fg};font-feature-settings:"calt" 1;white-space:pre;}}
.cursor{{display:inline-block;width:0.6em;height:1.15em;background:{t['cursor']};vertical-align:text-bottom;}}
.cap{{position:relative;margin-top:24px;width:1280px;display:flex;align-items:center;justify-content:space-between;color:{t['fg']};font-size:15px;}}
.cap b{{color:{t['accent']};}}
.chip{{display:inline-block;width:18px;height:18px;border-radius:5px;margin-left:6px;vertical-align:middle;box-shadow:0 0 0 1px #ffffff22;}}
</style></head><body>
<div id="stage">
<div class="win">
  <div class="bar"><span class="dot" style="background:#ff5f57"></span><span class="dot" style="background:#febc2e"></span><span class="dot" style="background:#28c840"></span>
  <div class="ttl">tamas@mac — ~/Developer/api</div></div>
  <div class="tmux"><div class="l"><span style="color:{t['bg']};background:{t['accent']};font-weight:700"> ● api </span><span style="background:{t['bg_highlight']};color:{t['fg_bright']}">1:nvim</span><span style="color:{muted}">2:zsh</span><span style="color:{muted}">3:herdr</span></div>
  <div style="color:{muted}">10:42 </div></div>
<pre>{body}</pre>
</div>
<div class="cap"><div><b>Borealis · {title}</b> &nbsp;·&nbsp; JetBrainsMono Nerd Font Mono &nbsp;·&nbsp; zsh · starship · tmux · bat · eza</div>
<div>{''.join('<span class="chip" style="background:%s"></span>' % v for v in (t['bg'], t['bg_highlight'], t['accent'], t['syntax']['keyword'], t['syntax']['func'], t['syntax']['type'], t['syntax']['string'], t['syntax']['number'], t['syntax']['tag']))}</div></div>
</div>
<script src="capture.js"></script>
</body></html>"""


CAPTURE_JS = """// Az oldal #stage elemét PNG-vé rajzolja (SVG foreignObject -> canvas) és elküldi a helyi szervernek.
// Csak akkor fut, ha az URL végén #save van.
(async () => {
  if (location.hash !== '#save') return;
  await document.fonts.ready;
  const stage = document.getElementById('stage');
  const css = [...document.querySelectorAll('style')].map(x => x.textContent).join('\\n');
  const w = stage.offsetWidth, h = stage.offsetHeight, scale = 2;
  const xml = new XMLSerializer().serializeToString(stage);
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}"><foreignObject width="100%" height="100%"><div xmlns="http://www.w3.org/1999/xhtml"><style>${css}</style>${xml}</div></foreignObject></svg>`;
  const img = new Image();
  img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
  await img.decode();
  const canvas = document.createElement('canvas');
  canvas.width = w * scale; canvas.height = h * scale;
  const ctx = canvas.getContext('2d'); ctx.scale(scale, scale); ctx.drawImage(img, 0, 0);
  const blob = await new Promise(r => canvas.toBlob(r, 'image/png'));
  const name = location.pathname.split('/').pop().replace('.html', '');
  const res = await fetch('/save?name=' + name, { method: 'POST', body: blob });
  document.title = 'saved:' + res.status;
})();
"""


def serve(names):
    """Helyi szerver: kiszolgálja az oldalakat, a #save-es oldal PNG-jét pedig a docs/img-be írja."""
    import http.server
    import functools

    tmp = tempfile.mkdtemp(prefix="shots-")
    for name in names:
        with open(os.path.join(tmp, name + ".html"), "w", encoding="utf-8") as fh:
            fh.write(build(name, palette(name)))
    with open(os.path.join(tmp, "capture.js"), "w", encoding="utf-8") as fh:
        fh.write(CAPTURE_JS)

    class Handler(http.server.SimpleHTTPRequestHandler):
        def do_POST(self):
            name = re.sub(r"[^a-z0-9_-]", "", self.path.split("name=")[-1])
            data = self.rfile.read(int(self.headers["Content-Length"]))
            os.makedirs(OUT, exist_ok=True)
            path = os.path.join(OUT, "terminal-%s.png" % name)
            with open(path, "wb") as fh:
                fh.write(data)
            print("==>", path, len(data), "bytes", flush=True)
            self.send_response(200)
            self.end_headers()

        def log_message(self, *a):
            pass

    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 8765), functools.partial(Handler, directory=tmp))
    print("Nyisd meg böngészőben (az oldal magától menti a PNG-t):")
    for name in names:
        print("  http://127.0.0.1:8765/%s.html#save" % name)
    httpd.serve_forever()


def main():
    flags = [a for a in sys.argv[1:] if a.startswith("--")]
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    names = args or [os.path.basename(p)[:-5] for p in sorted(glob.glob(os.path.join(REPO, "themes", "*.toml")))]
    if "--serve" in flags:
        serve(names)
        return
    browser = next((b for b in BROWSERS if os.path.exists(b)), None)
    if not browser:
        sys.exit("render.py: nincs Chromium-alapú böngésző (Brave / Chrome); használd a --serve módot")
    os.makedirs(OUT, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name in names:
            page = os.path.join(tmp, name + ".html")
            with open(page, "w", encoding="utf-8") as fh:
                fh.write(build(name, palette(name)))
            with open(os.path.join(tmp, "capture.js"), "w", encoding="utf-8") as fh:
                fh.write(CAPTURE_JS)
            png = os.path.join(OUT, "terminal-%s.png" % name)
            subprocess.run([browser, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-sandbox",
                            "--user-data-dir=" + os.path.join(tmp, "profile"), "--no-first-run",
                            "--force-device-scale-factor=2", "--window-size=1400,1300",
                            "--screenshot=" + png, "file://" + page],
                           check=True, capture_output=True, timeout=90)
            print("==>", png)


if __name__ == "__main__":
    main()
