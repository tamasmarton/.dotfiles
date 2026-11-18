#!/usr/bin/env python3
"""macOS Terminal.app profil (.terminal) generálása egy palettából.

  make-profile.py <márka> <kimenet.terminal> < paletta.json

A paletta JSON a themes/<név>.toml [theme] táblája (a chezmoi adja át). Csak a Python 3 standard
könyvtárát használja (a macOS Command Line Tools része). A színek NSKeyedArchiver NSColor-ként
kerülnek a fájlba, ahogy a Terminal.app maga is exportálja.
"""
import json
import plistlib
import sys
from plistlib import UID

FONT_PS_NAME = "JetBrainsMonoNFM-Regular"  # JetBrainsMono Nerd Font Mono — fix cellaszélesség
FONT_SIZE = 14.0


def archive(objects, top):
    return plistlib.dumps(
        {"$archiver": "NSKeyedArchiver", "$objects": objects, "$top": {"root": UID(top)}, "$version": 100000},
        fmt=plistlib.FMT_BINARY,
    )


def color(hex_value):
    h = hex_value.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    rgb = ("%.6f %.6f %.6f" % (r, g, b)).encode() + b"\x00"
    return archive(
        ["$null",
         {"$class": UID(2), "NSColorSpace": 1, "NSRGB": rgb},
         {"$classes": ["NSColor", "NSObject"], "$classname": "NSColor"}],
        1,
    )


def font(ps_name, size):
    return archive(
        ["$null",
         {"$class": UID(2), "NSName": UID(3), "NSSize": size, "NSfFlags": 16},
         {"$classes": ["NSFont", "NSObject"], "$classname": "NSFont"},
         ps_name],
        1,
    )


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    brand, out = sys.argv[1], sys.argv[2]
    t = json.load(sys.stdin)
    names = ["Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"]
    profile = {
        "name": "%s · %s" % (brand, t["name"].title()),
        "type": "Window Settings",
        "ProfileCurrentVersion": 2.07,
        "BackgroundColor": color(t["bg"]),
        "TextColor": color(t["fg"]),
        "TextBoldColor": color(t["fg_bright"]),
        "CursorColor": color(t["cursor"]),
        "SelectionColor": color(t["selection"]),
        "Font": font(FONT_PS_NAME, FONT_SIZE),
        "UseBrightBold": False,       # a félkövér ne váltson világos színre
        "useOptionAsMetaKey": True,   # Alt a tmuxban / Neovimben
        "columnCount": 140,
        "rowCount": 40,
    }
    for n in names:
        profile["ANSI%sColor" % n] = color(t["ansi"][n.lower()])
        profile["ANSIBright%sColor" % n] = color(t["bright"][n.lower()])
    with open(out, "wb") as fh:
        plistlib.dump(profile, fh, fmt=plistlib.FMT_XML)


if __name__ == "__main__":
    main()
