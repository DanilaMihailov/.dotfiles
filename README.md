![Screenshot 2024-06-25 at 23 51 13](https://github.com/DanilaMihailov/.dotfiles/assets/1163040/e8a00dd2-05d0-4eff-83dc-e5cb40031213)

## Dotfiles Repository

This repository contains my personal configuration files (dotfiles) for various development tools and applications. It's organized using GNU Stow to manage symlinks efficiently.

## Contents

- **Neovim configuration** (`nvim/`) - My main editor setup including LSP configuration, plugins, and keybindings
- **Zsh configuration** (`zsh/`) - Shell configuration with custom aliases and functions
- **Git configuration** (`git/`) - Global git settings and aliases
- **Alacritty terminal** (`alacritty/`) - Terminal emulator configuration
- **Other tools** - Configuration for various other development tools

## Using GNU stow

```sh
git clone git@github.com:DanilaMihailov/.dotfiles.git dotfiles

cd dotfiles
stow -v --dotfiles */
```

`-n` - will run in simulation mode

`--dotfiles` - change `dot-` to `.` in names
