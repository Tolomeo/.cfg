echo "1. Checking out cfg repository"

git clone --bare git@github.com:Tolomeo/.cfg.git $HOME/.cfg

function config {
	/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# Backup dir
mkdir $HOME/.cfg-backup
# Checking out repo files
config checkout

# If there are conflicts given by already existing files
# move them into cfg-backup directory
if [ $? = 0 ]; then
	echo "Checked out cfg";
else
	echo "Removing zsh deps"
	# These folders give problems
	rm -Rf $HOME/.zsh/pure/
	rm -Rf $HOME/.zsh/zsh-syntax-highlighting/

	echo "Backing up pre-existent files";
	config checkout 2>&1 | egrep "^\s+." | awk  '{ sub(/^[ \t]+/, ""); print }' | xargs -I{} mv {} $HOME/.cfg-backup/
fi;

# Okay, checkout
config checkout

# Avoid showing the entire home as untracked
config config status.showUntrackedFiles no

echo "2. Initialising submodules"

# Submodules
config submodule update --init

# sourcing cfg utilities
source $HOME/.bin/cfg.sh

echo "3. Installing Homebrew"

# https://brew.sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "4. Installing Homebrew formulae"

brew bundle --file=$HOME/.Brewfile
