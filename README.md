# dotfiles

macOS fejlesztői környezet [chezmoi](https://www.chezmoi.io/)-val, saját és céges gépre, valamint devcontainerbe.

**Stack:** zsh + Starship · WezTerm + tmux · Neovim · mise (Node, Go, Java) · glacier-night téma · JetBrainsMono Nerd Font

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
3. a `Brewfile` alapján telepíti a csomagokat.

### Devcontainer

VS Code `settings.json`:

```json
"dotfiles.repository": "tamasmarton/.dotfiles",
"dotfiles.installCommand": "install.sh"
```

Konténerben nem kérdez, hanem környezeti változókból dolgozik (`DOTFILES_PROFILE`, `DOTFILES_NAME`, `DOTFILES_EMAIL`). A GUI-s részek (Homebrew casks, WezTerm) kimaradnak.

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
├── .chezmoiroot                → a chezmoi forrás a home/ mappa
└── home/
    ├── .chezmoi.toml.tmpl      profil kérdések → gépenkénti adatok
    ├── .chezmoidata/theme.toml glacier-night paletta (minden eszköz ebből színez)
    ├── .chezmoiignore          profil szerint kihagyott fájlok
    ├── .chezmoiscripts/        Homebrew telepítés, brew bundle
    ├── .chezmoiexternal.toml   antidote (zsh pluginkezelő) git repóból
    ├── dot_zshenv              ~/.zshenv → XDG változók, ZDOTDIR=~/.config/zsh
    ├── dot_config/
    │   ├── zsh/                .zshrc, pluginok, aliasok, függvények, téma, work.zsh
    │   ├── git/                config (delta, aliasok, opcionális SSH aláírás), ignore
    │   ├── starship.toml.tmpl  prompt a palettából
    │   ├── mise/               Node LTS, pnpm, Go, Java (Temurin 25)
    │   ├── atuin/              kereshető history (Ctrl-R)
    │   └── homebrew/           Brewfile
    └── dot_local/bin/          saját parancsok (brewfile)
```

### Shell röviden

- **Pluginok** ([.zsh_plugins.txt](home/dot_config/zsh/dot_zsh_plugins.txt)): zsh-completions, fzf-tab, autosuggestions, fast-syntax-highlighting, history-substring-search
- **Billentyűk:** `↑`/`↓` keresés a beírt szövegre · `Ctrl-R` atuin · `Ctrl-T` fájl (fzf) · `Alt-C` mappa (fzf) · `Tab` fzf menü · `Ctrl-X Ctrl-E` parancs szerkesztése nvimben
- **`cd`** a zoxide-ot használja (`cd proj` → a leggyakoribb illeszkedő mappa), `cdi` interaktív
- **Runtime-ok:** `mise use node@20` a projektben, a `.nvmrc` / `.java-version` fájlokat is felismeri

### Gépspecifikus, nem verziózott fájlok

| Fájl | Mire jó |
|---|---|
| `~/.config/zsh/local.zsh` | csak ezen a gépen kellő shell beállítások |
| `~/.config/git/local` | pl. más email egy mappára (`includeIf`) |

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
