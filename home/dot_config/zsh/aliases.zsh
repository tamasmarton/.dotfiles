# ── Navigáció ───────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias dev='cd ~/Developer'
alias dots='chezmoi cd'

# ── eza (ls) ────────────────────────────────────────────────────────────
if (( $+commands[eza] )); then
  alias ls='eza --icons=always --group-directories-first'
  alias ll='eza --icons=always --group-directories-first -l --git'
  alias la='eza --icons=always --group-directories-first -la --git'
  alias lt='eza --icons=always --tree --level=2 --git-ignore'
  alias ltt='eza --icons=always --tree --level=4 --git-ignore'
fi

# ── bat (cat) ───────────────────────────────────────────────────────────
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# ── Szerkesztő ──────────────────────────────────────────────────────────
alias v='nvim'
alias vim='nvim'
alias zshrc='chezmoi edit --apply ~/.config/zsh/.zshrc'
alias reload='exec zsh'

# ── Git ─────────────────────────────────────────────────────────────────
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gs='git status -sb'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gd='git diff'
alias gds='git diff --staged'
alias gpu='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git l'
alias lg='lazygit'

# ── Docker ──────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias lzd='lazydocker'

# ── Egyéb ───────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias path='print -l $path'
alias wttr='curl -s "wttr.in/Budapest?format=3"'
