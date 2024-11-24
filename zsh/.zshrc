# Path to your oh-my-zsh installation.
# export ZSH=$HOME/.oh-my-zsh

# ZSH_THEME="agnoster"

# plugins=(git)

# source $ZSH/oh-my-zsh.sh

[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh

# ---- NVM directory ---- 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# ---- Powerlevel 10k ---- 
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ---- Starship ---- 
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh
eval "$(starship init zsh)"


# ---- History setup ---- 
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Eza (better ls) -----
alias ls="eza --icons=always --tree --level=3 --all"
alias ll="eza --icons=always --group-directories-first -l"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"