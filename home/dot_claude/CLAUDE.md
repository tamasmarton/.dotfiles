# Globális utasítások (minden projektre)

> A chezmoi kezeli: `~/Developer/.dotfiles/home/dot_claude/CLAUDE.md`.
> Szerkesztés: `chezmoi edit ~/.claude/CLAUDE.md`, vagy ha közvetlenül itt módosítottad: `chezmoi re-add ~/.claude/CLAUDE.md`.

## Kommunikáció

- Velem magyarul beszélj. Kód, kommentek a kódban, commit üzenetek és PR-ok angolul.
- Tömören: előbb a válasz vagy a javaslat, utána az indoklás.

## Környezet

- macOS, zsh (`ZDOTDIR=~/.config/zsh`), WezTerm + tmux, Neovim és VS Code.
- A runtime-okat a **mise** kezeli (Node LTS, pnpm, Go, Java Temurin). Projektverzió: `mise use node@20` stb. — ne nvm-et vagy brew-t javasolj ehhez.
- Elérhető CLI eszközök: `rg`, `fd`, `jq`, `yq`, `bat`, `eza`, `delta`, `gh`, `lazygit`.
- **Dotfiles:** a configokat (`~/.config/…`, `~/.zshenv`, `~/.claude/…`) a chezmoi generálja a `~/Developer/.dotfiles` repóból. Configot mindig a repóban (a forrásban) módosíts, ne a célfájlban — különben a következő `chezmoi apply` felülírja.

## Stack és szokások

- Fő nyelvek: TypeScript / JavaScript, Go, Java. Rust később.
- JS/TS: pnpm, ha a projektben nincs más lockfile. Biome, ha van `biome.json`, egyébként Prettier + ESLint.
- Go: `gofumpt`, `goimports`, `golangci-lint`. Java: a projekt saját build eszköze (Gradle / Maven wrapper).
- Tesztet és lintert futtass, mielőtt késznek mondasz egy változtatást.
- Titkot (token, jelszó, kulcs) soha ne írj fájlba vagy commitba; 1Password (`op`) vagy környezeti változó.
