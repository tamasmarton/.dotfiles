#!/bin/sh
# Dotfiles telepítő — új gépen és devcontainerben is ez a belépési pont.
#
#   Új Mac:        git clone <repo> ~/Developer/.dotfiles && ~/Developer/.dotfiles/install.sh
#   Devcontainer:  VS Code "dotfiles.repository" beállítás → automatikusan lefuttatja
#
# Nem interaktív futásnál (devcontainer) a profil környezeti változókból jön:
#   DOTFILES_PROFILE=work DOTFILES_NAME=... DOTFILES_EMAIL=... ./install.sh
# vagy egy env fájllal: ~/.config/dotfiles/env.toml (példa: env.example.toml)
set -eu

script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if ! command -v chezmoi >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "==> chezmoi telepítése Homebrew-val…"
    brew install chezmoi
    chezmoi="chezmoi"
  else
    bin_dir="$HOME/.local/bin"
    chezmoi="$bin_dir/chezmoi"
    echo "==> chezmoi telepítése ide: $bin_dir"
    if command -v curl >/dev/null 2>&1; then
      sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
    elif command -v wget >/dev/null 2>&1; then
      sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
    else
      echo "Hiba: a chezmoi telepítéséhez curl vagy wget kell." >&2
      exit 1
    fi
  fi
else
  chezmoi="chezmoi"
fi

# Linuxon / konténerben nincs Homebrew: a mise adja a runtime-okat és a CLI eszközöket
if [ "$(uname -s)" != "Darwin" ] && ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  echo "==> mise telepítése ide: $HOME/.local/bin"
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh
fi

echo "==> chezmoi init --apply (forrás: $script_dir)"
exec "$chezmoi" init --apply --source="$script_dir"
