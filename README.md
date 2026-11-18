# dotfiles

[![CI](https://github.com/tamasmarton/.dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/tamasmarton/.dotfiles/actions/workflows/ci.yml)

macOS fejlesztői környezet [chezmoi](https://www.chezmoi.io/)-val, saját és céges gépre, valamint devcontainerbe.

**Gépek:** Mac (személyes, céges) · headless Debian/Ubuntu (SSH) · devcontainer

**Stack:** zsh + Starship · WezTerm (vagy Ghostty) + tmux · Neovim · VS Code (saját Glacier Night téma) · mise (Node, Go, Java) · Claude Code, herdr, oh-my-pi · glacier-night téma · JetBrainsMono Nerd Font

## Telepítés

### Új Mac

```sh
xcode-select --install          # git miatt
git clone https://github.com/tamasmarton/.dotfiles.git ~/Developer/.dotfiles
~/Developer/.dotfiles/install.sh
```

Az `install.sh` feltelepíti a chezmoit, megkérdezi a gép profilját (`personal` / `work`), a Git nevet és emailt, majd:

1. telepíti a Homebrew-t, ha még nincs,
2. kirakja a configokat a `$HOME`-ba,
3. a `Brewfile` alapján telepíti a csomagokat,
4. `mise install`: Node, pnpm, Go, Java,
5. megépíti és telepíti a Glacier Night VS Code témát,
6. bekapcsolja a herdr integrációt a Claude Code-hoz és az omp-hoz,
7. beállítja a macOS defaults-ot (billentyűismétlés, Finder, Dock, képernyőképek).

Egyetlen kézi lépés maradhat: a régi shell history importálása az atuinba (`atuin import auto`).

### Debian / Ubuntu szerver (headless, SSH-n át)

```sh
sudo apt install -y git curl
git clone https://github.com/tamasmarton/.dotfiles.git ~/Developer/.dotfiles
~/Developer/.dotfiles/install.sh
```

Ugyanaz a terminál, mint a Macen, GUI nélkül:

- **apt:** zsh, tmux, fordítóeszközök (a treesitter parserekhez). Ehhez egyszer sudo jelszót kér.
- **mise:** starship, fzf, eza, bat, fd, ripgrep, delta, lazygit, Neovim, sesh, yazi, btop, lazydocker, plusz Node LTS (a Neovim LSP-khez).
- **Claude Code CLI:** a hivatalos natív telepítővel (`~/.local/bin/claude`), ami magától frissül.
- **zsh lesz az alap shell** (`chsh`).
- **SSH kényelmi funkciók:**
  - a Neovimben és a tmuxban másolt szöveg a Mac vágólapjára kerül (OSC 52);
  - a tmux státuszsorban látszik a gép neve (beágyazott tmuxban `Ctrl-a Ctrl-a` a belső prefix);
  - a Starship mutatja a `user@host`-ot;
  - Ghostty-ból az SSH automatikusan rendezi a terminfo-t.
- **Debian 12** (régebbi glibc): a tree-sitter 0.25.10-en marad, az atuin helyett az fzf adja a `Ctrl-R`-t. **Debian 13-on** minden a legfrissebb.

### Devcontainer

A VS Code beállításaiba ezt a chezmoi magától beírja, így minden devcontainerbe automatikusan települ:

```json
"dotfiles.repository": "tamasmarton/.dotfiles",
"dotfiles.targetPath": "~/.dotfiles",
"dotfiles.installCommand": "install.sh",
"terminal.integrated.defaultProfile.linux": "zsh"
```

**Működés konténerben:**
- Nem kérdez, hanem környezeti változókból dolgozik: `DOTFILES_PROFILE`, `DOTFILES_NAME`, `DOTFILES_EMAIL`.
- **Kimarad:** a GUI-s részek és a runtime-ok (Node/Go/Java), mert azokat a projekt image adja.
- **Települ:** a terminál config, a CLI eszközök és a Claude Code CLI.

### Céges profil

- **Git email:** a fő email a céges. Ha az init során megadsz személyes emailt, a `~/Developer/personal/` alatti repók automatikusan azt kapják (`includeIf`).
- **Céges CA tanúsítvány:** ha a cég TLS-t bontó proxyt használ, tedd ide: `~/.config/certs/corp-ca.pem`. A Node automatikusan használja; a git, curl és Java beállítása a [`work.zsh`](home/dot_config/zsh/work.zsh.tmpl)-ben van leírva.
- **Proxy és titkok:** a `work.zsh`-ban (titkokat 1Passwordből, `onepasswordRead`).
- **Céges csomagok:** a Brewfile `{{ if .isWork }}` blokkjába.

### Tesztek

- **CI:** minden pushnál lefut (GitHub Actions).
- **Végponttól végpontig:** az `install.sh` friss Debian 12, Debian 13 és VS Code devcontainer konténerben fut le, utána ellenőrzi a zsh-t, az eszközöket, a tmuxot, a Neovim + treesitter működését és a Claude Code-ot.
- **Helyben is futtatható:**

```sh
docker run --rm -v "$PWD":/src:ro debian:13 bash /src/test/e2e/linux-host.sh
docker run --rm -v "$PWD":/src:ro mcr.microsoft.com/devcontainers/base:debian bash /src/test/e2e/devcontainer.sh
```

## Napi használat

| Parancs | Mit csinál |
|---|---|
| `chezmoi edit ~/.zshrc` | config szerkesztése a forrásban |
| `chezmoi diff` | mi változna a `$HOME`-ban |
| `chezmoi apply` | változások kirakása |
| `chezmoi update` | `git pull` + apply |
| `chezmoi cd` | ugrás a repóba |

### Homebrew csomagok

A csomaglista a [`home/dot_config/homebrew/Brewfile.tmpl`](home/dot_config/homebrew/Brewfile.tmpl) fájlban van, profil szerinti blokkokkal. Ha változik, a `chezmoi apply` magától telepíti az új csomagokat.

| Parancs | Mit csinál |
|---|---|
| `brewfile` | hiányzó csomagok telepítése (meglévőket nem frissít) |
| `brewfile upgrade` | `brew update` + elavultak frissítése |
| `brewfile check` | telepítve van-e minden |
| `brewfile cleanup` | ami telepítve van, de nincs a Brewfile-ban (csak lista) |
| `brewfile cleanup -f` | …és ezek eltávolítása, megerősítéssel |
| `brewfile edit` | Brewfile szerkesztése, majd apply |

## Felépítés

```
.
├── install.sh                  belépési pont (új gép, devcontainer)
├── .github/workflows/ci.yml    CI: minden profil renderelése és ellenőrzése, Neovim, témák, E2E
├── test/e2e/                   végponttól végpontig tesztek (Debian host, devcontainer)
├── nvim/lazy-lock.json         Neovim plugin verziók (a lazy.nvim ide írja)
├── vscode/glacier-night/       saját VS Code téma csomag (build.sh → .vsix)
├── .chezmoiroot                → a chezmoi forrás a home/ mappa
└── home/
    ├── .chezmoi.toml.tmpl      profil kérdések → gépenkénti adatok
    ├── .chezmoidata/theme.toml glacier-night paletta: felület + kódszínezés
    ├── .chezmoitemplates/      VS Code téma sablon
    ├── .chezmoiignore          profil szerint kihagyott fájlok
    ├── .chezmoiscripts/        Homebrew, brew bundle, mise install, VS Code téma, herdr integráció, macOS defaults
    ├── dot_claude/             Claude Code: settings (merge), statusline, CLAUDE.md
    ├── dot_omp/                oh-my-pi: téma és config (merge)
    ├── .chezmoiexternal.toml   antidote (zsh pluginkezelő) git repóból
    ├── dot_zshenv              ~/.zshenv → XDG változók, ZDOTDIR=~/.config/zsh
    ├── dot_config/
    │   ├── zsh/                .zshrc, pluginok, aliasok, függvények, téma, work.zsh
    │   ├── git/                config (delta, aliasok, opcionális SSH aláírás), ignore
    │   ├── starship.toml.tmpl  prompt a palettából
    │   ├── mise/               Node LTS, pnpm, Go, Java (Temurin 25)
    │   ├── atuin/              kereshető history (Ctrl-R)
    │   ├── wezterm/            terminál (Lua), ghostty/ opcionális alternatíva
    │   ├── tmux/               josean-alapú config, glacier-night státuszsor
    │   ├── sesh/               tmux session-ök
    │   ├── herdr/              agent multiplexer téma (merge)
    │   ├── aerospace/          tiling ablakkezelő (opcionális)
    │   ├── nvim/               Neovim (josean-struktúra, modern pluginok)
    │   ├── bat/ eza/ lazygit/ btop/   a palettából színezve
    │   └── homebrew/           Brewfile
    └── dot_local/bin/          saját parancsok (brewfile)
```

### Shell röviden

- **Pluginok** ([.zsh_plugins.txt](home/dot_config/zsh/dot_zsh_plugins.txt)): zsh-completions, fzf-tab, autosuggestions, fast-syntax-highlighting, history-substring-search
- **Billentyűk:** `↑`/`↓` keresés a beírt szövegre · `Ctrl-R` atuin · `Ctrl-T` fájl (fzf) · `Alt-C` mappa (fzf) · `Tab` fzf menü · `Ctrl-X Ctrl-E` parancs szerkesztése nvimben
- **`cd`** a zoxide-ot használja (`cd proj` → a leggyakoribb illeszkedő mappa), `cdi` interaktív
- **Runtime-ok:** `mise use node@20` a projektben, a `.nvmrc` / `.java-version` fájlokat is felismeri

### Téma

Minden szín a [`.chezmoidata/theme.toml`](home/.chezmoidata/theme.toml) palettából jön. Ha itt átírsz egy színt, a `chezmoi apply` után a WezTerm, a tmux, a Starship, az fzf, a delta, az eza, a lazygit és a btop is követi. A bat és a delta szintaxis-kiemelése az `ansi` témát használja, vagyis a terminál 16 színét.

### VS Code

- **Téma:** saját [Glacier Night](vscode/glacier-night/) csomag. A felület és a kódszínezés is a palettából generálódik (`[theme]` és `[theme.syntax]`). A `chezmoi apply` újraépíti és telepíti, ha a színek változnak.
- **Fájlikonok:** Material Icon Theme (a Brewfile telepíti), a mappák cyan, az általános fájlok tompa színnel.
- **Beállítások:** a chezmoi a `settings.json`-ban csak a témát, a fontot (JetBrainsMono Nerd Font) és néhány megjelenési beállítást írja. A többi beállításod megmarad.

### AI agentek: Claude Code, herdr, oh-my-pi

- **Claude Code:** a chezmoi a `~/.claude/settings.json`-ba csak a glacier-night státuszsort írja, plusz a `theme`, `sandbox` és értesítés alapértékeket, ha még nincsenek. Az `env` (tokenek), `permissions`, `hooks` és `mcpServers` gépenként maradnak, és **soha nem kerülnek a repóba**.
- **Globális utasítások:** egy közös sablonból ([`agent-instructions.md`](home/.chezmoitemplates/agent-instructions.md)) generálódik a Claude Code `~/.claude/CLAUDE.md`-je és az oh-my-pi `~/.omp/agent/AGENTS.md`-je. Tartalma: nyelv, stack, a dotfiles működése; a gép típusa szerint (Mac / Debian host / devcontainer) és céges profilon kiegészül.
- **herdr:** agent multiplexer, több Claude / omp session egy helyen. Glacier-night téma. A sidebarban látszik, melyik agent dolgozik, vár inputra vagy végzett.
- **oh-my-pi (`omp`):** coding agent TUI, saját glacier-night témával és Nerd Font ikonokkal.
  - **Engedélyezés:** az omp alapból `yolo` módban mindent kérdés nélkül futtat, nálunk az alap a `write`. A fájlszerkesztés megy, a parancsok kérdeznek, kivéve amit a szabálylista enged:
    - **kérdés nélkül:** olvasó és teszt parancsok (`git status/diff/log`, `rg`, `go test`, `pnpm test/lint`, `./gradlew test` …);
    - **mindig kérdez:** `sudo`, `git push`, `git reset --hard`, `rm -rf`, `chezmoi apply`;
    - **tilos:** `rm -rf /` és `rm -rf ~`.
  - **Projektenként:** a `.omp/config.yml`-ben szigorítható, lazítani nem lehet.
  - **`RULES.md`:** a legfontosabb szabályok röviden; ezt az omp subagentjei is megkapják.
  - **Billentyűk:** a `Ctrl+L` újrarajzolja a képernyőt, nem az élő hangmódot indítja.
- A herdr, omp és Claude configot az alkalmazások maguk is írják, ezért a chezmoi ezeket nem írja felül, csak a saját kulcsait állítja be bennük (`modify_` sablonok).

### Opcionális appok

| App | Mire jó | Indítás |
|---|---|---|
| **Ghostty** | alternatív terminál, ugyanazzal a palettával | nyisd meg a Ghostty-t |
| **AeroSpace** | tiling ablakkezelő, `Ctrl-Opt` + `h/j/k/l`, workspace-ek `1–9` | nyisd meg az AeroSpace-t; nem indul el magától |
| **Raycast** | launcher a Spotlight helyett | első indításkor végigvezet a beállításon |

### tmux röviden (prefix: `Ctrl-a`)

| Billentyű | Mit csinál |
|---|---|
| `\|` / `-` | függőleges / vízszintes split az aktuális mappában |
| `Ctrl-h/j/k/l` | mozgás panelek (és nvim splitek) között, prefix nélkül |
| `h/j/k/l` · `m` | panel átméretezése · zoom |
| `T` | session választó (sesh + fzf + zoxide) |
| `L` | előző session |
| `g` | lazygit popup |
| `Ctrl-s` / `Ctrl-r` | session mentése / visszaállítása (15 percenként automatikus) |
| `r` | config újratöltése |

A tmux pluginokat (vim-tmux-navigator, resurrect, continuum) a chezmoi tölti le, tpm nem kell.

### WezTerm

- **Option billentyűk:** a bal Option Alt-ként működik (fzf `Alt-C`, szóugrás), a jobb Option a magyar billentyűzet speciális karaktereit adja (`@`, `[`, `~` …).
- **Gyorsbillentyűk:** `Cmd-K` törli a képernyőt, `Shift-Enter` új sort ír (pl. Claude Code-ban).

### Neovim röviden (leader: `Space`)

Josean-alapú struktúra és billentyűzés, modern alapokon: lazy.nvim, natív `vim.lsp`, blink.cmp, snacks.nvim (picker, dashboard, lazygit), treesitter (main ág), conform, nvim-lint, nvim-dap, nvim-jdtls.

| Billentyű | Mit csinál |
|---|---|
| `ff` `fs` `fr` `fc` `ft` `fb` | fájl · szöveg · legutóbbi · kurzor alatti szó · TODO · bufferek |
| `ee` `ef` | fájlfa · fájlfa az aktuális fájlnál |
| `gd` `gR` `gi` `gt` `K` | definíció · hivatkozások · implementáció · típus · dokumentáció |
| `ca` `rn` `mp` | code action · átnevezés · formázás |
| `d` `D` `[d` `]d` | diagnosztika: sor · fájl · előző · következő |
| `hs` `hr` `hp` `hb` `]h` `[h` | git hunk: stage · reset · előnézet · blame · ugrás |
| `lg` | lazygit |
| `xw` `xd` | trouble: projekt / fájl diagnosztikák |
| `sv` `sh` `sx` `sm` | split: függőleges · vízszintes · bezár · maximalizál |
| `F5` `F9` `F10` `F11` · `bb` `bu` `bt` | debug (VS Code-szerűen) · breakpoint · UI · Go teszt debug |
| `jo` `jt` `jT` `jv` | Java: importok · teszt metódus · teszt osztály · változó kiemelése |

- **Nyelvek:** TS/JS (vtsls, eslint, prettier vagy biome), Go (gopls, gofumpt, golangci-lint, delve), Java (jdtls + Lombok, debug, tesztek), Lua, Docker, YAML/JSON (SchemaStore).
- **Plugin verziók:** a [`nvim/lazy-lock.json`](nvim/lazy-lock.json) a repóban van. A `:Lazy update` után a változás git diffként jelenik meg.
- **Formázás mentéskor:** a `:FormatToggle` kapcsolja ki vagy be.

### Gépspecifikus, nem verziózott fájlok

| Fájl | Mire jó |
|---|---|
| `~/.config/zsh/local.zsh` | csak ezen a gépen kellő shell beállítások |
| `~/.config/git/local` | pl. más email egy mappára (`includeIf`) |
| `~/.config/wezterm/local.lua` | pl. más fontméret: `return function(c) c.font_size = 14 end` |
| `~/.config/tmux/local.conf` | extra tmux beállítások |

### Profilok

| Adat | Jelentés |
|---|---|
| `.profile` | `personal` vagy `work` |
| `.isContainer` | automatikusan felismert devcontainer, Codespaces vagy Docker |
| `.gui` | valódi Mac (nem konténer): casks, fontok, WezTerm |

Sablonban: `{{ if .isWork }}…{{ end }}`

## Régi configok

A 2022-es és 2024-es verziók tagként maradtak meg: `archive/master-2022`, `archive/nn-macbookair-2024`, `archive/test-2024`.

```sh
git show archive/nn-macbookair-2024:tmux/.tmux.conf
```
