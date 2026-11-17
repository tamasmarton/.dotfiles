# Mappa létrehozása és belépés
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# yazi: kilépéskor a shell abba a mappába lép, ahol a yaziban voltál
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Melyik process fogja a portot: port 3000
port() { lsof -nP -iTCP:"$1" -sTCP:LISTEN; }
