## Kommunikáció

- Velem magyarul beszélj. Kód, kommentek a kódban, commit üzenetek és PR-ok angolul.
- Tömören: előbb a válasz vagy a javaslat, utána az indoklás.

## Környezet

{{ if .gui -}}
- macOS, zsh (`ZDOTDIR=~/.config/zsh`), WezTerm vagy Ghostty + tmux, Neovim és VS Code.
- A runtime-okat a **mise** kezeli (Node LTS, pnpm, Go, Java Temurin). Projektverzió: `mise use node@20` stb. — ne nvm-et vagy brew-t javasolj ehhez.
- Csomagok: Homebrew, a listát a dotfiles `Brewfile`-ja tartalmazza (`brewfile` parancs).
{{- else if .brew }}
- Headless Mac szerver, SSH-n át használva. zsh, tmux, Neovim; nincs GUI, nincsenek cask-ok.
- A CLI eszközöket a **Homebrew** adja (`brewfile` parancs), a Node a **mise**-ből.
{{- else if .linuxHost }}
- Headless {{ if .isDebian }}Debian/Ubuntu {{ end }}szerver, SSH-n át használva. zsh, tmux, Neovim; nincs GUI.
- A CLI eszközök és a Node a **mise**-ből jönnek (`mise ls`), a rendszercsomagok apt-ból (sudo kell hozzájuk).
- A vágólap OSC 52-vel a helyi gépre megy: hosszabb kimenetet fájlba írj, ne a terminálba.
{{- else }}
- Devcontainer: a runtime-okat és a projekt eszközeit a konténer image adja (nem a mise). zsh, tmux, Neovim.
{{- end }}
- Elérhető CLI eszközök: `rg`, `fd`, `jq`, `yq`, `bat`, `eza`, `delta`, `lazygit`{{ if .gui }}, `gh`{{ end }}.
- **Dotfiles:** a configokat (`~/.config/…`, `~/.zshenv`, `~/.claude/…`, `~/.omp/…`) a chezmoi generálja a `{{ .chezmoi.workingTree | replace .chezmoi.homeDir "~" }}` repóból. Configot mindig a repóban (a forrásban) módosíts, ne a célfájlban — különben a következő `chezmoi apply` felülírja.

## Stack és szokások

- Fő nyelvek: TypeScript / JavaScript, Go, Java. Rust később.
- JS/TS: pnpm, ha a projektben nincs más lockfile. Biome, ha van `biome.json`, egyébként Prettier + ESLint.
- Go: `gofumpt`, `goimports`, `golangci-lint`. Java: a projekt saját build eszköze (Gradle / Maven wrapper).
- Tesztet és lintert futtass, mielőtt késznek mondasz egy változtatást.
- Titkot (token, jelszó, kulcs) soha ne írj fájlba vagy commitba; 1Password (`op`) vagy környezeti változó.
{{- if .isWork }}
- Céges gép: céges kódot, adatot vagy belső URL-t ne küldj külső szolgáltatásnak, és ne másolj személyes repóba.
{{- end }}
