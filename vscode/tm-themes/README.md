# TM Themes

Saját sötét VS Code témák. Minden `themes/<név>.toml` palettából (a repó gyökerében) egy `<Név>` nevű téma lesz: pl. **Darker** és **Nightfrost**. Ugyanaz a paletta hajtja a terminált, a tmuxot, a Neovimet és a többi eszközt.

## Honnan jönnek a színek

A téma JSON-t **nem kézzel szerkesztjük**, hanem a chezmoi generálja:

- paletták: [`themes/*.toml`](../../themes/) — `[theme]` a felület, `[theme.syntax]` a kódszínezés
- sablon: [`home/.chezmoitemplates/vscode-theme.json`](../../home/.chezmoitemplates/vscode-theme.json)

A `chezmoi apply` újragenerálja és telepíti a csomagot, ha bármelyik paletta, a sablon vagy a csomag változik. Az **aktív** témát a `./theme use <név>` állítja be (VS Code-ban is ez lesz a `workbench.colorTheme`); a többi a Color Theme választóból (`Cmd+K Cmd+T`) is elérhető.

## Kézi build

```sh
./build.sh             # themes/*.json újragenerálása + dist/tm-themes-<verzió>.vsix
./build.sh --install   # …és telepítés a VS Code-ba
```

A `.vsix` egy sima zip (manifest + `extension/`), ezért a buildhez nem kell Node vagy `vsce`.
