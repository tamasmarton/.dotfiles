# compinit cache-elve: teljes ellenőrzés naponta egyszer, egyébként gyors (-C) betöltés.
() {
  setopt local_options extended_glob
  local zcd="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
  [[ -d ${zcd:h} ]] || mkdir -p ${zcd:h}
  autoload -Uz compinit
  if [[ -n $zcd(#qN.mh+24) || ! -f $zcd ]]; then
    compinit -i -d $zcd
  else
    compinit -i -C -d $zcd
  fi
}
