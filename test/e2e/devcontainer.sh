#!/bin/bash
# End-to-end teszt: VS Code devcontainer (mcr.microsoft.com/devcontainers/base, `vscode` felhasználó).
# A VS Code `dotfiles.repository` beállítás pontosan így futtatja: klón a targetPath-ba, majd install.sh.
#   docker run --rm -v "$PWD":/src:ro mcr.microsoft.com/devcontainers/base:debian bash /src/test/e2e/devcontainer.sh
set -euo pipefail
SRC="${SRC:-/src}"

su - vscode -c "cp -a '$SRC' ~/.dotfiles && rm -rf ~/.dotfiles/vscode/tm-themes/dist"
su -w GITHUB_TOKEN,MISE_GITHUB_TOKEN - vscode -c 'cd ~/.dotfiles && REMOTE_CONTAINERS=true DOTFILES_PROFILE=work DOTFILES_EMAIL=test@example.com ./install.sh </dev/null'
su - vscode -c "bash '$SRC/test/e2e/verify.sh'"
