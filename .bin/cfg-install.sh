echo "1. Checking out cfg repository"

git clone --bare git@github.com:Tolomeo/.cfg.git $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no

echo "2. Installing Homebrew"

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

echo "3. Installing Homebrew formulae"

brew bundle --file="${HOME}/.Brewfile"
