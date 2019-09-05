cd ~

rm .tmux.conf .zshrc .vimrc rm ~/.config/nvim/init.vim rm ~/.config/git/ignore

ln -s .dotfiles/zshrc .zshrc
ln -s .dotfiles/vimrc .vimrc
ln -s .dotfiles/tmux.conf .tmux.conf

mkdir -p .config/nvim && cd ./config/nvim
ln -s ~/.dotfiles/init.vim init.vim
cd ~

mkdir -p .config/git && cd ./config/git
ln -s ~/.dotfiles/global_git_ignore ignore
cd ~
