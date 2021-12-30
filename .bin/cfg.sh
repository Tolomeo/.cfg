# see https://stackoverflow.com/questions/66162058/vscode-complains-that-resolving-my-environment-takes-too-long
function load-nvm() {
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
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

