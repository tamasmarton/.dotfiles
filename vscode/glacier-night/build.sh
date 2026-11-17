#!/usr/bin/env bash
# Glacier Night VS Code téma: JSON generálása a palettából + .vsix csomag (+ telepítés).
#
#   ./build.sh                 téma JSON újragenerálása (chezmoi) + dist/*.vsix
#   ./build.sh --install       …és telepítés a VS Code-ba
#   ./build.sh --skip-render   a meglévő themes/*.json-ból csomagol (a chezmoi script így hívja)
set -euo pipefail

here="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
repo="$(cd "$here/../.." && pwd -P)"
cd "$here"

install=false
render=true
for arg in "$@"; do
  case "$arg" in
    --install) install=true ;;
    --skip-render) render=false ;;
    *) echo "build.sh: ismeretlen kapcsoló: $arg" >&2; exit 2 ;;
  esac
done

theme_json="themes/glacier-night-color-theme.json"

if $render; then
  command -v chezmoi >/dev/null || { echo "build.sh: a chezmoi kell a téma generálásához" >&2; exit 1; }
  chezmoi execute-template --source="$repo" '{{ template "vscode-glacier-night.json" . }}' >"$theme_json.tmp"
  mv "$theme_json.tmp" "$theme_json"
fi

# JSON ellenőrzés (python3 a macOS Command Line Tools része)
python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$theme_json"

name="$(sed -n 's/^ *"name": *"\([^"]*\)".*/\1/p' package.json | head -1)"
publisher="$(sed -n 's/^ *"publisher": *"\([^"]*\)".*/\1/p' package.json | head -1)"
version="$(sed -n 's/^ *"version": *"\([^"]*\)".*/\1/p' package.json | head -1)"
display="$(sed -n 's/^ *"displayName": *"\([^"]*\)".*/\1/p' package.json | head -1)"
vsix="dist/$name-$version.vsix"

stage="$(mktemp -d "${TMPDIR:-/tmp}/glacier-night.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/extension/themes" dist
cp package.json README.md "$stage/extension/"
cp "$theme_json" "$stage/extension/themes/"

cat >"$stage/[Content_Types].xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json"/>
  <Default Extension=".md" ContentType="text/markdown"/>
  <Default Extension=".vsixmanifest" ContentType="text/xml"/>
</Types>
EOF

cat >"$stage/extension.vsixmanifest" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">
  <Metadata>
    <Identity Language="en-US" Id="$name" Version="$version" Publisher="$publisher"/>
    <DisplayName>$display</DisplayName>
    <Description xml:space="preserve">Glacier Night color theme</Description>
    <Tags>theme,color-theme,dark</Tags>
    <Categories>Themes</Categories>
    <GalleryFlags>Public</GalleryFlags>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.85.0"/>
    </Properties>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>
  </Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
    <Asset Type="Microsoft.VisualStudio.Services.Content.Details" Path="extension/README.md" Addressable="true"/>
  </Assets>
</PackageManifest>
EOF

rm -f "$vsix"
(cd "$stage" && zip -qrX "$here/$vsix" '[Content_Types].xml' extension.vsixmanifest extension)
echo "==> $vsix"

if $install; then
  code_bin="$(command -v code || true)"
  [[ -z "$code_bin" && -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]] \
    && code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [[ -z "$code_bin" ]]; then
    echo "build.sh: a VS Code 'code' parancs nem található, telepítés kihagyva" >&2
    exit 0
  fi
  "$code_bin" ${VSCODE_EXTENSIONS_DIR:+--extensions-dir "$VSCODE_EXTENSIONS_DIR"} --install-extension "$here/$vsix" --force
fi
