# see https://stackoverflow.com/questions/66162058/vscode-complains-that-resolving-my-environment-takes-too-long
function load-nvm() {
	export NVM_DIR="$HOME/.nvm"
	[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh" # This loads nvm
	[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
}

# Adapted from
# https://github.com/Homebrew/brew/issues/3933#issuecomment-373771217
# updating ~/.Brewfile file on every brew formula install and uninstall
function brew() {
	local brew_command="${1}"
	local dump_commands=('install' 'uninstall') # Include all commands that should do a brew dump

	command brew ${@}

	for command in "${dump_commands[@]}"; do
		[[ "${command}" == "${brew_command}" ]] && command brew bundle dump --file="${HOME}/.Brewfile" --force
	done
}

# Managing configuration repo
function cfg() {
	git --git-dir="${HOME}/.cfg/" --work-tree="${HOME}" ${@}
}

