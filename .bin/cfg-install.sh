echo "1. Checking out cfg repository"

git clone --bare git@github.com:Tolomeo/.cfg.git $HOME/.cfg

function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# Checking out repo files
config checkout

# If there are conflicts given by already existing files
# move them into cfg-backup directory
if [ $? = 0 ]; then
  echo "Checked out cfg.";
  else
    echo "Backing up pre-existing dot files.";
		mkdir -p .cfg-backup
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .cfg-backup/{}
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

echo "3. Installing formulae"

brew bundle --file=$HOME/.Brewfile

echo "4. Installing NVM"

# https://github.com/nvm-sh/nvm#installing-and-updating
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

echo "5. Installing Node lts"

load-nvm
nvm install --lts
