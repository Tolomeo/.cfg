echo "1. Checking out cfg repository"

git clone --bare git@github.com:Tolomeo/.cfg.git $HOME/.cfg

function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
function mvp ()
{
    dir="$2" # Include a / at the end to indicate directory (not filename)
    tmp="$2"; tmp="${tmp: -1}"
    [[ "$tmp" != "/" ]] && dir="$(dirname "$2")"
    [[ -a "$dir" ]] ||
    mkdir -p "$dir" &&
    mv "$@"
}

# Checking out repo files
config checkout

# If there are conflicts given by already existing files
# move them into cfg-backup directory
if [ $? = 0 ]; then
  echo "Checked out cfg.";
  else
    echo "Backing up pre-existing dot files.";
		# Backup directory 
		mkdir -p .cfg-backup
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mvp {} .cfg-backup/{}
fi;

# Okay, checkout
config checkout
# Avoid showing the entire home as untracked
config config status.showUntrackedFiles no
# sourcing cfg utilities
source $HOME/.bin/cfg.sh

echo "2. Installing Homebrew"

# https://brew.sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "3. Installing Homebrew formulae"

brew bundle --file=$HOME/.Brewfile
