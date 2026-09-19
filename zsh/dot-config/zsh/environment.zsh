# Environment shared by interactive Zsh and launcher-started terminal apps.
export XDG_CONFIG_HOME="$HOME/.config"
export GITLAB_URL="https://gitlab.rtlq.ru/"
export HOMEBREW_NO_AUTO_UPDATE=1
export TOOLCHAINS=swift

export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

export ANDROID_HOME="/Users/$USER/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools/platform-tools"
export PATH="$HOME/Library/Python/2.7/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

if [[ -n ${CONTAINER_ID:-} ]]; then
  export PATH="$HOME/.local/lib/distrobox-host-bin:$PATH"
fi

export LANG=en_US.UTF-8
export MANPAGER='nvim +Man!'
export EDITOR=nvim
export BROWSER=zen-browser
export GIT_EDITOR=nvim

if [[ -z ${CONTAINER_ID:-} ]]; then
  export BUN_INSTALL="$HOME/.bun"
fi
export PATH="$BUN_INSTALL/bin:$PATH"
export GNUPGHOME="$HOME/.gnupg"
export PATH="$PATH:/Users/zen/.lmstudio/bin"
export OPENCODE_ENABLE_EXA=true

source "$HOME/secrets.sh"
