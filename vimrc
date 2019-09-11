"
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2017 Sep 20
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

syntax on
"set ruler
set number
set clipboard=unnamed
"set showcmd
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
set laststatus=2
set noshowmode
set cursorline
set tabstop=4
set shiftwidth=4
set relativenumber
let mapleader = " "

" Make searching better
set gdefault      " Never have to type /g at the end of search / replace again
set ignorecase    " case insensitive searching (unless specified)
set smartcase

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" auto install vim plug if it is not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" files
" git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
" ~/.fzf/install
Plug '/usr/local/opt/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
" Plug 'jistr/vim-nerdtree-tabs'
" Plug 'tpope/vim-vinegar'
"Plug 'ryanoasis/vim-devicons'

" visuals
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'pangloss/vim-javascript'
" Plug 'mhinz/vim-startify'
Plug 'https://github.com/machakann/vim-highlightedyank'
Plug 'tomasiser/vim-code-dark'

" motions
Plug 'easymotion/vim-easymotion'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'mattn/emmet-vim'
Plug 'jiangmiao/auto-pairs'
" Plug 'yuttie/comfortable-motion.vim'

" complete and linting
Plug 'neomake/neomake'

Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" npm install -g typescript typescript-language-server
Plug 'ryanolsonx/vim-lsp-javascript'
" pip install python-language-server
Plug 'ryanolsonx/vim-lsp-python'

call plug#end()

" theme
colorscheme codedark

" autocomplete bindings
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
map gh :LspHover<CR>
map <Leader>gd :LspDefinition<CR>

" files view bindings
map <C-p> :GFiles<CR>
map <C-b> :NERDTreeToggle<CR>
" map <C-b> :NERDTreeTabsToggle<CR>

" ignore files for NERDTree
let NERDTreeIgnore = ['\.pyc$']

autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript

call neomake#configure#automake('nrwi', 500)
let g:neomake_javascript_enabled_makers = ['eslint']
let g:lsp_diagnostics_enabled = 0
" let g:lsp_signs_enabled = 1         " enable signs
" let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode

" move lines in all modes (option key mappings not working)
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" recall the command-line whose beginning matches the current command-line
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

" navigate by display lines
noremap j gj
noremap k gk

if has('nvim')
	set inccommand=split
	highlight HighlightedyankRegion cterm=reverse gui=reverse
	let g:highlightedyank_highlight_duration = 300
endif

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

set splitbelow splitright

let g:lightline = {
	\ 'enable': { 'tabline': 0 },
	\ 'colorscheme': 'seoul256',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'component_function': {
	\   'gitbranch': 'fugitive#head'
	\ },
	\ }

if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
endif

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
" source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
" if has('syntax') && has('eval')
"   packadd! matchit
" endif

