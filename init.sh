cd ~

rm .zshrc .vimrc rm ~/.config/nvim/init.vim

ln -s .dotfiles/zshrc .zshrc
ln -s .dotfiles/vimrc .vimrc

mkidr -p .config/nvim && cd ./config/nvim
ln -s ~/.dotfiles/init.vim init.vim
cd ~

