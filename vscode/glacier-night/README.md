# Glacier Night

Sötét VS Code téma mélykék háttérrel és teal kiemelésekkel. Ugyanaz a paletta, mint a dotfiles többi részében (WezTerm, tmux, Starship, Neovim).

## Honnan jönnek a színek

A téma JSON-t **nem kézzel szerkesztjük**, hanem a chezmoi generálja:

- paletta: [`home/.chezmoidata/theme.toml`](../../home/.chezmoidata/theme.toml) — `[theme]` a felület, `[theme.syntax]` a kódszínezés
- sablon: [`home/.chezmoitemplates/vscode-glacier-night.json`](../../home/.chezmoitemplates/vscode-glacier-night.json)

A `chezmoi apply` újragenerálja és telepíti, ha a paletta vagy a sablon változik.

## Kézi build

```sh
./build.sh             # themes/*.json újragenerálása + dist/glacier-night-<verzió>.vsix
./build.sh --install   # …és telepítés a VS Code-ba
```

A `.vsix` egy sima zip (manifest + `extension/`), ezért a buildhez nem kell Node vagy `vsce`.

## Kódszínezés

| Elem | Szín |
|---|---|
| kulcsszavak (`if`, `return`, `import`, `func`) | teal |
| deklarációk, módosítók (`const`, `public`, `class`) | cyan |
| függvények, metódusok | világoskék |
| típusok, osztályok, interfészek | sárga |
| stringek | menta |
| számok, `true` / `null` | narancs |
| paraméterek | halvány lila, dőlt |
| mezők, objektum kulcsok | jégkék |
| HTML / JSX tagek | pink |
| annotációk, dekorátorok | magenta |
| kommentek | tompa szürkéskék, dőlt |

A szemantikus kiemelés (TS, Go, Java LSP) is ugyanezt a kiosztást követi.
