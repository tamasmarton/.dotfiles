{{- /* Céges gép: GUI-s része a Brewfile-nak (taps, casks, VS Code bővítmények, GUI-hoz kötött formulák).
       Teljesen önálló lista, nem osztozik a személyes profillal. Terminálos formulák: Brewfile.tmpl. */ -}}
# ── Tapek ───────────────────────────────────────────────────────────────
tap "nikitabobko/tap"           # AeroSpace

# ── Terminál és font ────────────────────────────────────────────────────
cask "wezterm@nightly"
cask "font-jetbrains-mono-nerd-font"
cask "ghostty"                  # alternatív terminál (a config a paletta színeit használja)

# ── Fejlesztés ──────────────────────────────────────────────────────────
cask "visual-studio-code"
vscode "pkief.material-icon-theme"   # fájlikonok (a Borealis csomagot a chezmoi telepíti)
cask "docker-desktop"
brew "lazydocker"               # a Docker Desktop adja a docker-t
cask "claude-code"
cask "1password-cli"            # titkok a chezmoi sablonokba (op read)

# ── macOS segédek ───────────────────────────────────────────────────────
cask "stats"                    # menüsoros rendszerfigyelő
cask "raycast"                  # Spotlight helyett: launcher, ablakkezelés, vágólap
cask "nikitabobko/tap/aerospace" # tiling ablakkezelő (opcionális, alapból nem indul el)

# ── Céges ───────────────────────────────────────────────────────────────
# Ide jönnek a céges gép extra csomagjai (VPN kliens, céges chat, …).
