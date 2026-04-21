# AGENTS.md

## Codebase Overview

This is a dotfiles repository managed with GNU Stow. It contains configuration files for various development tools and applications including Neovim, Zsh, Git, Alacritty and others.

## Build/Lint/Test Commands

### General Commands

- `stow -v --dotfiles */` - Apply all configurations (simulation: `stow -n -v --dotfiles */`)
- `stow -v --dotfiles <package>` - Apply specific configuration (e.g., `stow -v --dotfiles nvim`)
- `stow -D -v --dotfiles <package>` - Remove specific configuration

### For development tools:

- `git status` - Check current git status for managed dotfiles
- `git diff` - Show changes to tracked files
- `git pull` - Update dotfiles from remote repository

## Code Style Guidelines

### File Organization

- Configuration files organized by tool/application
- Use `stow` for managing symlinks
- Dotfiles are named with leading dots (e.g., `.zshrc`, `.vimrc`)
- Configuration directories are named to match the tool (e.g., `nvim/`, `zsh/`)

For example, nvim config by default should be in ~/.config/nvim. But here used
`gnu stow`, and nvim config lies in `nvim/dot-config/nvim`. Top level folder is
tool name, and then path to the config relative to home directory, with caveat,
that dots "." are replaced with "dot-"

### Naming Conventions

- Configuration file names match tool conventions (e.g., `.zshrc`, `.vimrc`, `.gitconfig`)
- Directory names match tool names (e.g., `nvim/`, `zsh/`, `git/`)
- File extensions for non-dotfiles should be omitted (e.g., `README.md` not `README`)

### Import/Module Structure

- Not applicable for dotfiles (no modules or imports)
- Configuration files are standalone and self-contained
- Use appropriate shebangs in shell scripts: `#!/bin/zsh` or `#!/bin/bash`
- Include comments to explain key configuration blocks

### Code Formatting

- Use consistent indentation (2 spaces for shell scripts)
- For shell scripts:
  - Indent continuation lines
  - Use `if [ condition ]` over `if [[ condition ]]` for portability
  - Separate commands with newlines for readability
- For Vim/Neovim configurations:
  - Use consistent indentation with spaces
  - Group related settings logically
  - Use `set` for options, `let` for variables

### Error Handling

- Dotfiles typically don't have error handling as they're configurations
- Ensure paths are valid when symlinking
- Use defensive scripting for shell configs (check if files exist, etc.)

## Tool Specific Rules

### Neovim Config (`nvim/`)

- Uses `init.vim` or `init.lua` as entry points
- Plugin management with appropriate plugin managers
- Configuration organized into logical sections (plugins, mappings, settings)

### Zsh Config (`zsh/`)

- `~/.zshrc` as main configuration file
- Consistent alias definitions
- Proper function organization with comments
- Path management with `PATH` variable adjustments

### Git Config (`git/`)

- `~/.gitconfig` with global settings
- Aliases defined for common git operations
- Proper user configuration (name/email)

### General Dotfiles

- All files in this repository are managed via GNU Stow
- Symlinks are automatically created by stow
- Use `stow -D` to remove configurations cleanly

## Cursor/Copilot Rules

### General Guidelines

- These dotfiles are configuration files, not application code
- Focus on correct file structure and symlinking practices
- Consider the cross-platform compatibility of shell configurations
- Use standard convention for dotfile names and organization

### Code Quality

- Ensure shell scripts are POSIX compatible when possible
- Validate correct file permissions for configurations
- Follow best practices for each tool's configuration format
- Use appropriate shebangs for script execution
