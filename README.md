![Screenshot 2024-06-25 at 23 51 13](https://github.com/DanilaMihailov/.dotfiles/assets/1163040/e8a00dd2-05d0-4eff-83dc-e5cb40031213)

## Dotfiles Repository

This repository contains my personal configuration files (dotfiles) for various development tools and applications. It's organized using GNU Stow to manage symlinks efficiently.

## Contents

- [Neovim configuration](#neovim) - Editor setup with LSP, plugins, and keybindings
- [Zsh configuration](#zsh-configuration) - Shell configuration with Powerlevel10k, plugins, and customizations
- [Git configuration](#git-configuration) - Global git settings and aliases
- Alacritty terminal (`alacritty/`) - Terminal emulator configuration
- Other tools - Configuration for various development tools

## Using GNU stow

```sh
git clone git@github.com:DanilaMihailov/.dotfiles.git dotfiles

cd dotfiles
stow -v --dotfiles */
```

`-n` - will run in simulation mode

`--dotfiles` - change `dot-` to `.` in names

## Neovim

[Neovim](https://neovim.io/) is a hyperextensible Vim-based text editor focused on extensibility and usability. This configuration is a modular Lua-based setup optimized for modern development.

### Configuration Structure

- `init.lua` - Main entry point that loads core configurations and the plugin manager.
- `lua/config/` - Core editor settings:
  - `opts.lua` - Global Neovim options and settings.
  - `maps.lua` - Custom keybindings and mappings.
  - `lazy.lua` - Bootstrap and configuration for the `lazy.nvim` plugin manager.
- `lua/plugins/` - Individual plugin configurations for easy management.

### Key Features & Plugins

- **AI-Powered Development**: Integrated with `avante.nvim`, `claude.lua`, and custom `opencode.lua` for AI-assisted coding.
- **LSP & Language Support**: Full IDE features using `nvim-lspconfig`, `mason.nvim`, and `nvim-cmp` for autocompletion.
- **File Management**: `oil.nvim` for editing the file system like a buffer and `telescope.nvim` for fuzzy finding.
- **Visuals & UI**: `lualine.nvim` for a status line, `which-key.nvim` for mapping discovery, and `treesitter` for advanced syntax highlighting.
- **Workflow**: `conform.nvim` for formatting, `nvim-dap` for debugging, and `gitsigns.nvim` for git integration.

## Zsh Configuration

- [Powerlevel10k](<[romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)>) - Feature-rich Zsh prompt theme with instant prompt support
- [Zinit](<[zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit)>) - Plugin manager for Zsh
- [fzf-tab](<[Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab)>) - Fuzzy matching for command completion
- [zoxide](<[ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide)>) - Improved `cd` command with smart directory navigation
- [fzf](<[junegunn/fzf](https://github.com/junegunn/fzf)>) - Interactive command-line fuzzy finder

### Features

- Custom aliases for common commands (`..`, `...`, `....`)
- Directory aliases (`cd.`, `cd..`)
- Enhanced `ls` with color output and icons
- Vim mode bindings
- SSH auto-attach to tmux sessions
- Custom terminal title management
- Environment variable management for various tools
- Python virtual environment detection
- Command history search with `Ctrl+N` and `Ctrl+P`

## Git Configuration

[Git](https://git-scm.com/) - Distributed version control system that tracks changes to code and enables collaborative software development

### Files

- `config` - Global user configuration with name and email
- `ignore` - File patterns to ignore in git repositories

### Configuration

- Global user settings for Danila Mihailov
- Standard Vim, macOS, and Claude settings ignored
