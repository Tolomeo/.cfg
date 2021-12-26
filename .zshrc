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

# Adapted from
# https://github.com/Homebrew/brew/issues/3933#issuecomment-373771217
# Config command can be 'scoped' to brew, passing 'brew' as 1st param to confgi command
# making it possible to automatically update ~/.Brewfile when 'brew install' and 'brew unistall' cmds are used
#
# If the 1st param passed to config is not 'brew', everything gets passed to git
function config {
	local config_command="${1}"

	if [[ "${config_command}" == 'brew' ]]; then
		local dump_commands=('install' 'uninstall') # Include all commands that should do a brew dump
		local brew_command="${2}"

		brew ${@:2}

		for command in "${dump_commands[@]}"; do
			[[ "${command}" == "${brew_command}" ]] && brew bundle dump --file="${HOME}/.Brewfile" --force
		done
	else
		git --git-dir="${HOME}/.cfg/" --work-tree="${HOME}" ${@}
	fi
}

# aliases
alias ll='ls -l'
alias la='ls -la'

# propmpt customisation, see ~/.zsh/pure directory
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
zstyle :prompt:pure:path color 014 

# zsh sytax highlighting, needs to stay at the end, see .zsh/zsh-syntax-highlighting directory
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
