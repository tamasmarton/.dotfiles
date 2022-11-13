# Path to your oh-my-zsh installation.
# export ZSH=$HOME/.oh-my-zsh

# ZSH_THEME="agnoster"

# plugins=(git)

# source $ZSH/oh-my-zsh.sh

[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh

PATH=/Applications/MAMP/Library/bin:/Applications/MAMP/bin/php/php7.4.21/bin:$PATH

# NVM directory
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Load Starship
eval "$(starship init zsh)"
