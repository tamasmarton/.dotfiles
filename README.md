# dotfiles

[![CI](https://github.com/tamasmarton/.dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/tamasmarton/.dotfiles/actions/workflows/ci.yml)

macOS fejlesztői környezet [chezmoi](https://www.chezmoi.io/)-val, saját és céges gépre, valamint devcontainerbe.

**Gépek:** Mac (személyes, céges) · headless Debian/Ubuntu (SSH) · devcontainer

**Stack:** zsh + Starship · WezTerm (vagy Ghostty) + tmux · Neovim · VS Code (saját Borealis csomag) · mise (Node, Go, Java) · Claude Code, herdr, oh-my-pi · saját paletták (darker, nightfrost, bluehour) · JetBrainsMono Nerd Font

## Telepítés

### Új Mac

```sh
xcode-select --install          # git miatt
git clone https://github.com/tamasmarton/.dotfiles.git ~/Developer/.dotfiles
~/Developer/.dotfiles/install.sh
```

Az `install.sh` feltelepíti a chezmoit. Az **első kérdés a gép profilja** (a [`profiles/`](profiles/) mappa fájljai közül: `personal` vagy `work`), utána a Git név és email. Ha előre létrehozol egy [env fájlt](#profilok-és-gépspecifikus-adatok), nem kérdez semmit. Majd:

1. telepíti a Homebrew-t, ha még nincs,
2. kirakja a configokat a `$HOME`-ba,
3. a `Brewfile` alapján telepíti a csomagokat,
4. `mise install`: Node, pnpm, Go, Java,
5. megépíti és telepíti a Borealis VS Code csomagot (minden paletta egy téma),
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
- Nem kérdez, hanem az env fájlból vagy környezeti változókból dolgozik: `DOTFILES_PROFILE`, `DOTFILES_NAME`, `DOTFILES_EMAIL`, `DOTFILES_ENV_FILE`.
- **Kimarad:** a GUI-s részek és a runtime-ok (Node/Go/Java), mert azokat a projekt image adja.
- **Települ:** a terminál config, a CLI eszközök és a Claude Code CLI.

### Céges profil

- **Git email:** a fő email a céges. Ha megadsz személyes emailt (env fájl vagy init kérdés), a `personalGitDir` (alapból `~/Developer/personal/`, [`profiles/work.toml`](profiles/work.toml)) alatti repók automatikusan azt kapják (`includeIf`).
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
├── profiles/                   profilok (personal.toml, work.toml), személyes adat nélkül
├── env.example.toml            minta a ~/.config/dotfiles/env.toml-hoz (gépenkénti név, email)
├── themes/                     színpaletták (darker.toml, nightfrost.toml, …)
├── theme                       paletta váltó: ./theme use <név>
├── vscode/tm-themes/           saját VS Code téma csomag (build.sh → .vsix)
├── .chezmoiroot                → a chezmoi forrás a home/ mappa
└── home/
    ├── .chezmoi.toml.tmpl      profil + env fájl + kérdések → gépenkénti adatok
    ├── .chezmoidata/theme.toml symlink az aktív palettára (themes/*.toml)
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
    │   ├── tmux/               josean-alapú config, a paletta színeivel
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

Minden szín egy **palettából** jön. A paletták a [`themes/`](themes/) mappában vannak, egy fájl egy téma. A témacsalád közös neve **Borealis** ([`brand.toml`](home/.chezmoidata/brand.toml)): a VS Code választóban `Borealis · <Paletta>` néven látszanak, így azonnal látod, melyik a tiéd. Az omp és a btop a paletta nevét használja.

| Paletta | VS Code neve | Jellemző |
|---|---|---|
| `darker` | Borealis · Darker | az **eredeti**: nagyon sötét, kontrasztos (≈ 14,6:1). A `05e6aa8` commitban készült, a színei azonosak, ne írd át |
| `nightfrost` | Borealis · Nightfrost | kékesfekete, kicsit visszafogottabb (≈ 10,5:1) |
| `bluehour` | Borealis · Bluehour | a VS Code Dark 2026 felépítése (semleges sötét szerkesztő, világosabb panelek, visszafogott kék accent), Tokyo Night-szerű kódszínekkel (≈ 9,5:1) |

#### Téma váltása

```bash
./theme                  # lista, az aktív *-gal
./theme use nightfrost   # az aktív paletta átállítása (a home/.chezmoidata/theme.toml symlink)
chezmoi apply            # életbe léptetés: minden alkalmazás újragenerálódik
```

Utána a futó programok újratöltése: VS Code `Developer: Reload Window`, Ghostty a konfig újratöltése, tmuxban `source-file ~/.config/tmux/tmux.conf`, a WezTerm magától újratölt, az omp új sessionben veszi át.

**Ideiglenes váltás apply nélkül** (a következő `chezmoi apply` visszaállítja az aktívra):

- VS Code: `Cmd+K Cmd+T`, majd a Borealis témák közül választasz
- omp: `/settings` → theme, vagy `omp config set theme.dark bluehour`
- btop: a `t` billentyű a menüben

**Melyik alkalmazás melyik témát tölti be**

| Alkalmazás | Téma | Hogyan állítható külön |
|---|---|---|
| WezTerm, Ghostty, tmux, Starship, Neovim, lazygit, eza, fzf, delta, Claude státuszsor | mindig az **aktív paletta** | csak `./theme use` (ezek egy színkészletet kapnak) |
| VS Code | aktív paletta | [`theme-overrides.toml`](home/.chezmoidata/theme-overrides.toml): `vscode = "darker"` |
| oh-my-pi (`omp`) | aktív paletta | `omp = "nightfrost"` ugyanott |
| btop | aktív paletta | `btop = "darker"` ugyanott |

Az üres érték az aktív palettát jelenti. Példa: a terminál legyen `darker`, a VS Code pedig `bluehour`:

```bash
./theme use darker
sed -i '' 's/^vscode = .*/vscode = "bluehour"/' home/.chezmoidata/theme-overrides.toml
chezmoi apply
```

**Új paletta:** másold le valamelyik `.toml`-t `themes/<új-név>.toml` néven, írd át a `name`-et és a színeket, majd `./theme use <új-név>`. Egy meglévő szín átírása után is elég a `chezmoi apply`. A bat és a delta szintaxis-kiemelése az `ansi` témát használja, vagyis a terminál 16 színét.

#### macOS Terminal.app (a sima beépített terminál)

A `chezmoi apply` minden palettából készít egy Terminal.app profilt a `~/.config/terminal-app/` mappába (`Borealis-Darker.terminal`, `Borealis-Nightfrost.terminal`, `Borealis-Bluehour.terminal`): a 16 ANSI szín, háttér, szöveg, kurzor, kijelölés és a JetBrainsMono Nerd Font Mono. A profilt egyszer kell importálni:

```bash
./theme terminal            # az aktív paletta profilját megnyitja (importálja)
./theme terminal bluehour   # vagy egy konkrétat
```

Utána Terminal ▸ Settings ▸ Profiles ▸ a profil ▸ **Default**. Az import nem írja felül a többi profilodat, és a chezmoi nem nyúl a Terminal.app beállításaihoz, így ez tudatos, kézi lépés marad.

**Korlátok:** a Terminal.app nem tud 24 bites színt, csak 256-ot. A Neovim kódszínei emiatt eltérhetnek a VS Code-tól, a tmux pedig Terminal.app alatt kevésbé pontos. A shell, a Starship, az `eza`, a `bat` és a `lazygit` a 16 ANSI színt használja, ezért ott a téma pontosan jön. Neovimhez a Ghostty vagy a WezTerm ajánlott. A VS Code beépített termináljához nem kell külön profil: az a VS Code téma ANSI színeit használja.

### VS Code

- **Téma:** saját [Borealis](vscode/tm-themes/) csomag: minden paletta egy téma (Borealis · Darker, Nightfrost, Bluehour). A felület és a kódszínezés is a palettából generálódik (`[theme]` és `[theme.syntax]`). A `chezmoi apply` újraépíti és telepíti, ha a színek változnak, és az aktív palettát állítja be színtémának.
- **Fájlikonok:** Material Icon Theme (a Brewfile telepíti), a mappák cyan, az általános fájlok tompa színnel.
- **Beállítások:** a chezmoi a `settings.json`-ban csak a témát, a fontot (JetBrainsMono Nerd Font) és néhány megjelenési beállítást írja. A többi beállításod megmarad.

### AI agentek: Claude Code, herdr, oh-my-pi

- **Claude Code:** a chezmoi a `~/.claude/settings.json`-ba csak a státuszsort írja (az aktív paletta színeivel), plusz a `theme`, `sandbox` és értesítés alapértékeket, ha még nincsenek. Az `env` (tokenek), `permissions`, `hooks` és `mcpServers` gépenként maradnak, és **soha nem kerülnek a repóba**.
- **Globális utasítások:** egy közös sablonból ([`agent-instructions.md`](home/.chezmoitemplates/agent-instructions.md)) generálódik a Claude Code `~/.claude/CLAUDE.md`-je és az oh-my-pi `~/.omp/agent/AGENTS.md`-je. Tartalma: nyelv, stack, a dotfiles működése; a gép típusa szerint (Mac / Debian host / devcontainer) és céges profilon kiegészül.
- **herdr:** agent multiplexer, több Claude / omp session egy helyen. Az aktív paletta témájával. A sidebarban látszik, melyik agent dolgozik, vár inputra vagy végzett.
- **oh-my-pi (`omp`):** coding agent TUI, az aktív paletta témájával és Nerd Font ikonokkal.
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

### Profilok és gépspecifikus adatok

**Profilok** (`profiles/*.toml`, a repóban, személyes adat nélkül): minden fájl egy profil. A `chezmoi init` első kérdése ezek közül választ, a fájlnév a profil neve.

| Profil | Mit jelent |
|---|---|
| [`personal`](profiles/personal.toml) | személyes gép: minden app, személyes kiegészítők (Brave, Spotify, VLC …) |
| [`work`](profiles/work.toml) | céges gép: `work.zsh` (CA, proxy), céges Brewfile rész, külön személyes git email a `~/Developer/personal/` repókhoz |

Egy profilfájl kulcsai: `title`, `description`, `signCommits` (alapérték), `askPersonalEmail`, `personalGitDir`. Új profil: másold le valamelyiket `profiles/<név>.toml` néven.

**Env fájl** (`~/.config/dotfiles/env.toml`, a repón kívül, soha nem kerül verziókezelésbe): a név, email és a profil gépenkénti értékei. A repóban csak a minta van: [`env.example.toml`](env.example.toml).

```bash
mkdir -p ~/.config/dotfiles
cp ~/Developer/.dotfiles/env.example.toml ~/.config/dotfiles/env.toml
$EDITOR ~/.config/dotfiles/env.toml
chezmoi init && chezmoi apply
```

Egy érték forrása, az első találat nyer: **env fájl → `DOTFILES_*` környezeti változó → korábbi chezmoi válasz → kérdés**. Az env fájl tehát egy rossz, korábban megadott választ is felülír. Más helyről is betölthető: `DOTFILES_ENV_FILE=/path/env.toml`. Ha a név és az email üres, a git config nem kap `[user]` blokkot (devcontainerben a VS Code adja át a hoszt azonosságát).

Rossz válasz javítása (pl. rossz név): vagy írd be az env fájlba, vagy `chezmoi init --data=false`, ami újrakérdez.

| Adat (sablonban) | Jelentés |
|---|---|
| `.profile` | a választott profil neve (`personal`, `work`, …) |
| `.isWork` / `.isPersonal` | rövidítés a két alap profilra |
| `.name`, `.email`, `.personalEmail`, `.signCommits` | az env fájlból, változóból vagy kérdésből |
| `.personalGitDir` | a profilfájlból: ebben a mappában a személyes email érvényes |
| `.isContainer` | automatikusan felismert devcontainer, Codespaces vagy Docker |
| `.gui` | valódi Mac (nem konténer): casks, fontok, WezTerm |

Sablonban: `{{ if .isWork }}…{{ end }}`

## Régi configok

A 2022-es és 2024-es verziók tagként maradtak meg: `archive/master-2022`, `archive/nn-macbookair-2024`, `archive/test-2024`.

```sh
git show archive/nn-macbookair-2024:tmux/.tmux.conf
```
