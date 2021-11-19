# see https://stackoverflow.com/questions/66162058/vscode-complains-that-resolving-my-environment-takes-too-long
function load-nvm {
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}


# nvm
if [[ "x${TERM_PROGRAM}" = "xvscode" ]]; then 
  echo 'in vscode, nvm not work; use `load-nvm`';
else 
  load-nvm
fi

fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
zstyle :prompt:pure:path color 121

alias config='/usr/bin/git --git-dir=/Users/diegofrattini/.cfg/ --work-tree=/Users/diegofrattini'
alias ll='ls -la'

