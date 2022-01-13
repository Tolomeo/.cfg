# aliases are placed on top to be picked up by autocompletion
alias reload='source ~/.zshrc'
alias ll='ls -l'
alias la='ls -la'

# cfg functions
source $HOME/.bin/cfg.sh

# Loading NVM only if we are not in VSCode
# see https://stackoverflow.com/questions/66162058/vscode-complains-that-resolving-my-environment-takes-too-long
if [[ "x${TERM_PROGRAM}" = "xvscode" ]]; then 
  echo 'in vscode, nvm doesn`t work; use `load-nvm`';
else 
  load-nvm
fi

# propmpt customisation, see ~/.zsh/pure directory
# fpath+=$HOME/.zsh/pure
# autoload -U promptinit; promptinit
# prompt pure
# zstyle :prompt:pure:path color 014 

# zsh sytax highlighting, needs to stay at the end, see .zsh/zsh-syntax-highlighting directory
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
