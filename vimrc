set number " show line numbers
set relativenumber " show relative line numbers (may be slow)
set clipboard=unnamed " copy to system clipboard
set keymap=russian-jcukenwin " allow use russian keys for moves and stuff
set iminsert=0
set imsearch=0
set cursorline " show cursor line
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

set updatetime=100 " delay for vim update (used by gitgutter)

" indentation rules
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab " use spaces instead of tabs
set autoindent
filetype plugin indent on

" backups and undo dirs
set backupdir=/tmp//
set directory=/tmp//
set undodir=/tmp//

set backup		" keep a backup file (restore to previous version)
if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
endif

" leader key, mostly used for plugins
let mapleader = " "

" Make searching better
set gdefault      " Never have to type /g at the end of search / replace again
set ignorecase    " case insensitive searching (unless specified)
set smartcase     " use case sensitive, if have different cases in search string

" Movement in insert mode
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>

" recall the command-line whose beginning matches the current command-line
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

" navigate by display lines
noremap j gj
noremap k gk

" make Y act like D
noremap Y y$

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" when splitting windows, they will appear to the right, or below
set splitbelow splitright

" highlight yanking region
if has('nvim')
	set inccommand=split
	highlight HighlightedyankRegion cterm=reverse gui=reverse
	let g:highlightedyank_highlight_duration = 300
endif

" mouse support (scrolling and other stuff)
if !has('nvim')
    set ttymouse=xterm2 " this option only affects vim
endif
set mouse=a

" use zsh as default shell
set shell=/bin/zsh

" auto install vim plug if it is not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" Theme
Plug 'altercation/vim-colors-solarized'
" Plug 'tomasiser/vim-code-dark' " old theme (vscode theme)

" Files plugins
Plug 'junegunn/fzf', { 'do': './install --all' } " --all makes it awailable to the system
Plug 'junegunn/fzf.vim' " Ctrl+P fuzzy file search
Plug 'scrooloose/nerdtree' " Ctrl+B file tree, sidebar

" Git plugins
Plug 'tpope/vim-dispatch' " needed for fugitive
Plug 'tpope/vim-fugitive' " git status, blame, history, etc
Plug 'airblade/vim-gitgutter' " gutters

" Languages
Plug 'pangloss/vim-javascript'
Plug 'rust-lang/rust.vim'
Plug 'elixir-editors/vim-elixir'
Plug 'keith/swift.vim'
Plug 'ron-rs/ron.vim'
Plug 'elzr/vim-json'
Plug 'ekalinin/Dockerfile.vim'
Plug 'burnettk/vim-angular'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'maxmellon/vim-jsx-pretty'

" Motion and helpers
Plug 'easymotion/vim-easymotion' " Space+Space+Motion
Plug 'mattn/emmet-vim' " Emmet support Ctrl+y Ctrl+,
Plug 'tpope/vim-surround' " Surrond with braces ysB
Plug 'tpope/vim-repeat' " enable repeat for tpope's plugins
Plug 'tomtom/tcomment_vim' " gcc to comment line
Plug 'jiangmiao/auto-pairs' " auto pair open brackets
Plug 'bkad/CamelCaseMotion' " move by camel case words with Space + Motion

" Autocomplete, linting, LSP
Plug 'neomake/neomake' " run make commands, used for eslint
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
" npm install -g typescript typescript-language-server
Plug 'ryanolsonx/vim-lsp-javascript'
" pip install python-language-server
Plug 'ryanolsonx/vim-lsp-python'
" Plug 'ryanolsonx/vim-lsp-swift'

" Misc
Plug 'itchyny/lightline.vim' " Status line
Plug 'https://github.com/machakann/vim-highlightedyank' " Highlight yanked text
Plug 'myusuf3/numbers.vim' " toggle line numbers intelligently
Plug 'mhinz/vim-mix-format' " format elixir files on save
Plug 'majutsushi/tagbar' " show ctags in sidebar
call plug#end()

" theme
set background=dark
colorscheme solarized
" colorscheme codedark
 
" File plugins settings
"
"Let the input go up and the search list go down
let $FZF_DEFAULT_OPTS = '--layout=reverse'

"Open FZF and choose floating window
let g:fzf_layout = { 'window': 'call OpenFloatingWin()' }

function! OpenFloatingWin()
  let height = &lines - 3
  let width = float2nr(&columns - (&columns * 2 / 10))
  let col = float2nr((&columns - width) / 2)

  "Set the position, size, etc. of the floating window.
  "The size configuration here may not be so flexible, and there's room for further improvement.
  let opts = {
        \ 'relative': 'editor',
        \ 'row': 3,
        \ 'col': col + 30,
        \ 'width': width * 2 / 3,
        \ 'height': height / 2
        \ }

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)

  "Set Floating Window Highlighting
  call setwinvar(win, '&winhl', 'Normal:Pmenu')

  setlocal
        \ buftype=nofile
        \ nobuflisted
        \ bufhidden=hide
        \ nonumber
        \ norelativenumber
        \ signcolumn=no
        \ background=dark
endfunction

" Ctrl+P open search for git files
map <C-p> :GFiles<CR>
" Space+P search for commands
map <Leader>p :Commands<CR>
" Ctrl+B show sidebar
map <C-b> :NERDTreeToggle<CR>

" ignore files for NERDTree
let NERDTreeIgnore = ['\.pyc$']

" highlight libs
let g:used_javascript_libs = 'underscore,angularjs,angularui,angularuirouter,jquery'
" disable concealing for json files
let g:vim_json_syntax_conceal = 0

" autocomplete bindings
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
map gh :LspHover<CR>
map <Leader>gd :LspDefinition<CR>

autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript
autocmd BufNewFile,BufRead *.json.ejs set filetype=json

call neomake#configure#automake('nrwi', 500)
let g:neomake_javascript_enabled_makers = ['eslint']
let g:lsp_diagnostics_enabled = 0
" let g:lsp_signs_enabled = 1         " enable signs
" let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
let g:dispatch_no_tmux_make = 1
let g:dispatch_no_tmux_start = 1

" format rust files on save by calling cargo format via :RustFmt
let g:rustfmt_autosave = 1
" Use leader ket for camel case
let g:camelcasemotion_key = '<leader>'
" elixir, format files on save
let g:mix_format_on_save = 1

" Status line settings
set noshowmode " do not show mode, as it i shown by light line

let g:lightline = {
	\ 'enable': { 'tabline': 0 },
	\ 'colorscheme': 'solarized',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'component_function': {
	\   'gitbranch': 'fugitive#head'
	\ },
	\ }
