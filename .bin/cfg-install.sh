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
  echo "Checked out cfg.";
  else
    echo "Backing up pre-existent dot files.";
    config checkout 2>&1 | egrep "^\s+." | awk {'print $1'} | xargs -I{} mv {} $HOME/.cfg-backup/
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
