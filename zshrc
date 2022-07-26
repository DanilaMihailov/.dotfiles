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
export NVM_DIR="$HOME/.nvm"

export PATH="$HOME/.local/bin:$PATH"

# this is slow, you can use source $NVM_DIR/nvm.sh to load manually
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# show last folder on the left
export PS1="%1~ $ "

# show full path in the right prompt
RPROMPT="%~"

# export PATH="$PATH:`yarn global bin`"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# vim mode
bindkey -v

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME=""

# gruvbox colors for iterm
source "$HOME/.vim/plugged/gruvbox/gruvbox_256palette.sh"

plugins=(macos docker zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
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

bindkey -v

# show vim mod in left prompt
function zle-line-init zle-keymap-select {
	case ${KEYMAP} in
		(vicmd)      VI_MODE="#" ;;
		(main|viins) VI_MODE="$" ;;
		(*)          VI_MODE="$" ;;
	esac
	PS1="%1~ $VI_MODE "
	zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Options to fzf command
export FZF_DEFAULT_OPTS="--reverse --no-info"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -alF'
alias ll='ls -l'
alias localip="ipconfig getifaddr en0"
# alias vi='nvim'
# alias vim='nvim'
# vim
alias e="$EDITOR"

# haskell stuff
[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

pyclean () {
        find . -type f -name "*.py[co]" -delete
        find . -type d -name "__pycache__" -delete
}

. /usr/local/opt/asdf/asdf.sh
