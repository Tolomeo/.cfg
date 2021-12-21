# Dotfiles versioned (.cfg)

See [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)

## Installation Requirements

- Git
- Curl

### Nvim requirements

- [Node](https://nodejs.org/en/). Version 14+.
- [ripgrep](https://github.com/BurntSushi/ripgrep).
- A terminal supporting true colors (see [Terminal Colors](https://gist.github.com/XVilka/8346728) for details) to properly display theme colors.
Also, the chosen terminal has to be configured to use the patched font found in `Library/Fonts` for UI icons, and to make the option/alt key act like Meta for all keybindings to work as expected.
  - Pre-populated iterm2 profile configurations are found in `.config/iterm2_profile`. To use them, activate `Load preferences from a custom folder or URL` via `iterm2 > preferences > General > preferences` and select the directory as source.
- [Github CLI](https://cli.github.com), to support in editor PR reviews

## Install

Install config tracking in your $HOME by running:

    curl -Lks https://raw.githubusercontent.com/Tolomeo/.cfg/main/.bin/cfg-install.sh | /bin/bash
