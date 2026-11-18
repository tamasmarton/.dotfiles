#!/bin/bash
# End-to-end teszt: headless Debian/Ubuntu host (sudo-s felhasználó → install.sh → ellenőrzés).
# Rootként fut egy friss konténerben. Helyben:
#   docker run --rm -v "$PWD":/src:ro debian:13 bash /src/test/e2e/linux-host.sh
set -euo pipefail
SRC="${SRC:-/src}"

apt-get update -qq >/dev/null
apt-get install -y -qq sudo git curl ca-certificates >/dev/null 2>&1
id tamas >/dev/null 2>&1 || useradd -m -s /bin/bash tamas
echo 'tamas ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tamas

su - tamas -c "mkdir -p ~/Developer && cp -a '$SRC' ~/Developer/.dotfiles && rm -rf ~/Developer/.dotfiles/vscode/tm-themes/dist"
su -w GITHUB_TOKEN,MISE_GITHUB_TOKEN - tamas -c 'cd ~/Developer/.dotfiles && DOTFILES_CONTAINER=0 DOTFILES_PROFILE=personal DOTFILES_EMAIL=test@example.com ./install.sh </dev/null'
su - tamas -c "bash '$SRC/test/e2e/verify.sh'"
