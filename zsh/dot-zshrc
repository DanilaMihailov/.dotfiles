# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export GITLAB_URL="https://gitlab.clabs.net/"

# Do not run update on every command wtf
export HOMEBREW_NO_AUTO_UPDATE=1

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export TOOLCHAINS=swift

# allows to install global packages without root
export PATH=~/.npm-global/bin:$PATH
export PATH="$HOME/.cargo/bin:$PATH"

export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools/platform-tools

export PATH="$HOME/Library/Python/2.7/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::brew
zinit snippet OMZP::asdf
zinit snippet OMZP::mosh
zinit snippet OMZP::npm
# zinit snippet OMZP::poetry
zinit snippet OMZP::tmux
zinit snippet OMZP::command-not-found

zinit wait lucid is-snippet as"completion" for \
  OMZP::docker/completions/_docker \
  OMZP::docker-compose/_docker-compose \
  OMZP::mix/_mix \

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# vim mode
bindkey -v

export LANG=en_US.UTF-8

export MANPAGER='nvim +Man!'
export EDITOR='nvim'

# run this command on ssh login 
if [[ -n $SSH_CONNECTION ]]; then
    if [ -z $TMUX ]; then
        tmux attach || tmux new
    fi
fi

export GIT_EDITOR=nvim

# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

bindkey '^y' autosuggest-accept
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward


eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias cd.='cd ..'
alias cd..='cd ..'

alias ls='ls --color'
alias l='ls -alF'
alias ll='ls -lh'
alias localip="ipconfig getifaddr en0"

# vim
alias e="$EDITOR"
alias em="$EDITOR -u ~/.config/nvim/minimal.lua"
alias lazyvim="NVIM_APPNAME=lazynvim $EDITOR"
alias nvchad="NVIM_APPNAME=nvchad $EDITOR"
alias nvimrocks="NVIM_APPNAME=nvimrocks $EDITOR"

# alias to love
alias love="/Applications/love.app/Contents/MacOS/love"

# haskell stuff
# [ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

pyclean () {
        find . -type f -name "*.py[co]" -delete
        find . -type d -name "__pycache__" -delete
}

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/secrets.sh

alias emacs='exec $(brew --prefix)/opt/emacs-mac/Emacs.app/Contents/MacOS/Emacs.sh "$@"'

DISABLE_AUTO_TITLE="true"
precmd () { echo -ne "\e]1;$PWD\a" } # title bar prompt

