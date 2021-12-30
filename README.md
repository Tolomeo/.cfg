# Cfg

My dotfiles.
This setup was inspired by [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles).
The setup makes use of [Homebrew](https://brew.sh) to manage packages, and [NVM](https://github.com/nvm-sh/nvm) to manage Node versions.

## Install

Install by running:

```bash
curl -Lks https://raw.githubusercontent.com/Tolomeo/.cfg/macOS/.bin/cfg-install.sh | /bin/bash
```

The script will clone this repository as bare, placing it in `~/.cfg`.
It will then install [homebrew](https://brew.sh), Homebrew formulae, [NVM](https://github.com/nvm-sh/nvm) and Node lts.

It will be possible to interact with the cfg repo by using the `cfg` command from anywhere in the filesystem, passing arguments like you would do with any git repository.
The working directory will be set to your home directory. Notice that, in order to add new files to the repo, your will need to explicitly add them with `cfg add ~/path/to/file`.

## Requirements

- Git
- Curl
- [Homebrew installation requirements](https://docs.brew.sh/Installation)
- The above should cover also [NVM installation requirements](https://github.com/nvm-sh/nvm#about)

### Nvim requirements

- A terminal supporting true colors (see [Terminal Colors](https://gist.github.com/XVilka/8346728) for details) to properly display theme colors.
- The chosen terminal has to be configured so that
  - it uses the patched font found in `Library/Fonts` for UI icons
  - it makes the option/alt key act like Meta, for keybindings to work

Pre-populated iTerm2 profile configurations are found in `~/.config/iterm2_profile`.
To use them, activate `Load preferences from a custom folder or URL` via `iterm2 > preferences > General > preferences` and select the directory as source.
