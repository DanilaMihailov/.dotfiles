cd ~

rm .tmux.conf .zshrc .vimrc rm ~/.config/nvim/init.vim

ln -s .dotfiles/zshrc .zshrc
ln -s .dotfiles/vimrc .vimrc
ln -s .dotfiles/tmux.conf .tmux.conf

mkidr -p .config/nvim && cd ./config/nvim
ln -s ~/.dotfiles/init.vim init.vim
cd ~

