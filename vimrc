" TODO
" * add check lang for tansation
" * add session selector
" * move to init.vim
" * move plugins (maybe new plugin manager)

" Section: Basic options

set modelineexpr
set number " show line numbers
set relativenumber " show relative line numbers (may be slow)
set clipboard=unnamed " copy to system clipboard
set keymap=russian-jcukenwin " allow use russian keys for moves and stuff
set iminsert=0
set imsearch=0
set cursorline " show cursor line
set backspace=indent,eol,start " backspace over indent, eol, start

set encoding=utf-8

let g:man_hardwrap = $MANWIDTH

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

if has("nvim")
    set termguicolors " use gui colors, allows to support 24bit color
endif

" allows using motions in russian language
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

set splitbelow splitright " when splitting windows, they will appear to the right, or below

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

set lazyredraw " do not redrow while macros execute

set scrolloff=8

set cmdheight=2 " Better display for messages
set showtabline=1 " always show tab line
set noshowmode " do not show mode, as it i shown by light line

set updatetime=100 " delay for vim update (used by gitgutter and coc.vim)
set hidden " allow hidden buffers (TextEdit might fail if hidden is not set)

set shortmess+=c " Don't pass messages to |ins-completion-menu|.

" backups and undo dirs
set backupdir=/tmp//
set directory=/tmp//
set undodir=/tmp//
set backup		" keep a backup file (restore to previous version)

if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
endif

" indentation rules
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab " use spaces instead of tabs
set autoindent
filetype plugin indent on

" Make searching better
set gdefault      " Never have to type /g at the end of search / replace again
set ignorecase    " case insensitive searching (unless specified)
set smartcase     " use case sensitive, if have different cases in search string

" helps gf to find files
" ** - all files from root
" .  - relative from current
" ,, - relative from current in same dir
set path+=**,.,,

set mouse=a " enable mouse for all modes

if has('nvim')
    set inccommand=split " show split with results when substitute
endif

" mouse support (scrolling and other stuff)
if !has('nvim')
    set ttymouse=xterm2 " this option only affects vim
endif

set shell=/bin/zsh " use zsh as default shell

" use ripgrep for :grep command
if executable('rg') 
	set grepprg=rg\ --vimgrep\ --hidden
endif

if has('nvim')
    augroup mytermgroup
        autocmd!
        au TermOpen * setlocal norelativenumber nonumber signcolumn=no nocursorline
    augroup end
endif

set wildmode=longest:full,list:longest,full " complete longest string
set wildignorecase " ignore file names and dirs case when completing

" Section: Basic maps

" leader key, mostly used for plugins
let mapleader = " "

" Ctrl+h to stop search highlight
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" show vim highlight group under cursor
nnoremap <leader>hi :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" change terminal mode to normal as in vim
tnoremap <C-W>N <C-\><C-n>
tnoremap <C-W>n <C-\><C-n>

" move out of terminal as if it is just a window
tnoremap <C-W> <C-\><C-N><C-w>

" Movement in insert mode (not really working)
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

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Open new file adjacent to current file like emacs
nnoremap <C-x><C-f> :e <C-R>=expand("%:p:h") . "/" <CR>

" Jump to last edit position on opening file
if has("autocmd")
  " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
    augroup mygrouplastposition
        autocmd!
        au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
        au WinEnter * setlocal cursorline
        au WinLeave * setlocal nocursorline
    augroup end
endif

" highlight yanking region
if has('nvim')
	highlight HighlightedyankRegion cterm=reverse gui=reverse
	let g:highlightedyank_highlight_duration = 300
endif

" auto install vim plug if it is not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Section: Plugin list

call plug#begin()
" Theme
Plug 'gruvbox-community/gruvbox'

" Files plugins
Plug 'junegunn/fzf', { 'do': './install --all' } " --all makes it awailable to the system
Plug 'junegunn/fzf.vim' " Ctrl+P fuzzy file search
Plug 'stsewd/fzf-checkout.vim'
" Using coc-explorer, with Ctrl+B

" Git plugins
Plug 'tpope/vim-dispatch' " needed for fugitive
Plug 'tpope/vim-fugitive' " git status, blame, history, etc
Plug 'fugitive-gitlab.vim' " extension for :Gbrowse
Plug 'christoomey/vim-conflicted'
Plug 'airblade/vim-gitgutter' " gutters

" Languages
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'elixir-editors/vim-elixir'
Plug 'keith/swift.vim'
Plug 'ron-rs/ron.vim'
Plug 'elzr/vim-json'
Plug 'ekalinin/Dockerfile.vim'
Plug 'burnettk/vim-angular'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'neovimhaskell/haskell-vim'

" Motion and helpers
Plug 'wellle/targets.vim' " make bracets motions find closest bracket and more
Plug 'andymass/vim-matchup' " better brackets highlihgts and motion
Plug 'tpope/vim-surround' " Surrond with braces ysB
Plug 'tpope/vim-repeat' " enable repeat for tpope's plugins
Plug 'tomtom/tcomment_vim' " gcc to comment line
Plug 'tpope/vim-unimpaired' " ]b for next buffer, ]e for exchange line, etc
Plug 'jiangmiao/auto-pairs' " auto pair open brackets
Plug 'bkad/CamelCaseMotion' " move by camel case words with Space + Motion

" Autocomplete, linting, LSP
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Misc
Plug 'itchyny/lightline.vim' " Status line
Plug 'https://github.com/machakann/vim-highlightedyank' " Highlight yanked text
Plug 'mhinz/vim-mix-format' " format elixir files on save
Plug 'antoinemadec/coc-fzf'
Plug 'Asheq/close-buffers.vim' " Bdelete [other, hidden, this]
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify' " session management, start screen
Plug 'mattn/emmet-vim' " Ctrl+y , to trigger
Plug 'voldikss/vim-translator' " use google translate (:Translate)
Plug 'skywind3000/vim-quickui'
Plug 'voldikss/vim-floaterm'
Plug 'tweekmonster/helpful.vim' " :HelpfulVersion
" Plug 'danilamihailov/vim-wiki-tips'
Plug '~/personal/vim-tips-wiki'
" Plug 'danilamihailov/beacon.nvim'
Plug '~/personal/beacon.nvim'
Plug 'tmux-plugins/vim-tmux'
call plug#end()

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

function! GitCheckoutBranch(branch)
    let l:name = split(split(trim(a:branch), "", 1)[0], "/", 1)[-1]
    echo "checking out ".l:name."\n"
    execute "Git checkout ".l:name
endfunction

command! -bang Gbranch call fzf#run(fzf#wrap({'source': 'git branch -avv --color', 'sink': function('GitCheckoutBranch'), 'options': '--ansi --nth=1'}, <bang>0))

" Section: Quickmenu

" clear all the menus
call quickui#menu#reset()

" install a 'File' menu, use [text, command] to represent an item.
call quickui#menu#install('&File', [
            \ [ "&Open...\t:Files", "Files", "Files" ],
            \ [ "&Explore\tCtrl-f", "CocCommand explorer --position=floating", "Coc explorer" ],
            \ [ "&Welcome screen\t:Startify", "Startify", "Show startify" ],
			\ [ '--','' ],
			\ [ "&Save as\t:saveas", "call feedkeys(':saveas ')", "Safe file with new name" ],
			\ [ '--','' ],
			\ [ "&Preferences", "tabe ~/.dotfiles/vimrc", "Edit vimrc" ],
			\ [ "&Coc Config\t:CocConfig", "CocConfig", "Edit coc-config.json" ],
			\ [ "&Reload vimrc", "silent! call ReloadConfig()", "source ~/.config/nvim/init.vim" ],
			\ [ '--','' ],
			\ [ "&Quit\t:qa", "qa", "Quit vim" ],
            \ ])

call quickui#menu#install("&Edit", [
            \ [ "&Format file\t:Format", "Format", "Format file using Coc" ],
            \ [ "Fo&ld\t:Fold", "Fold", "Fold file using Coc" ],
            \ [ "&Organize imports\t:OR", "OR", "Organize imports file using Coc" ],
			\ [ '--','' ],
            \ [ "&Wrap with emmet\tCtrl+y ,", "norm gv\<C-y>,", "Wrap with emmet abbriviation" ],
            \ [ "Rewrap document\tgggqG", "norm gggqG", "Runs gggqG" ],
			\ [ '--','' ],
            \ [ "&Expand all folds\tzR", "norm zR", "Epands all folds" ],
            \ [ "&Collapse all folds\tzM", "norm zM", "Collapse all folds" ],
            \ ])

call quickui#menu#install("&Buffers", [
            \ [ "L&ist\tCtrl-b", "Buffers", "Buffers" ],
			\ ['--',''],
            \ [ "Close &other buffers\t:Bdelete other", "Bdelete other", "" ],
            \ [ "Close hidd&en buffers\t:Bdelete hidden", "Bdelete hidden", "" ],
            \ [ "Close &this buffer\t:Bdelete this", "Bdelete this", "" ],
            \ [ "Close &nameless buffers\t:Bdelete nameless", "Bdelete nameless", "" ],
            \ ])
call quickui#menu#install("&Windows", [
            \ [ "&Zoom window\tSpace+-", "normal 1 -", "" ],
            \ [ "&Re-balance windows\tSpace+=", "normal 1 =", "" ],
			\ ['--',''],
            \ [ "Move to the left\tCtrl-w H", "wincmd H", "" ],
            \ [ "Move to the right\tCtrl-w L", "wincmd L", "" ],
            \ [ "Move to the bottom\tCtrl-w J", "wincmd J", "" ],
            \ [ "Move to the top\tCtrl-w K", "wincmd K", "" ],
			\ ['--',''],
            \ [ "&New window\tCtrl-w n", "wincmd n", "" ],
            \ [ "New tab\t:tabnew", "tabnew", "" ],
			\ ['--',''],
            \ [ "&Exchange windows\tCtrl-w x", "wincmd x", "" ],
            \ [ "&Move to tab\tCtrl-w T", "wincmd T", "" ],
			\ ['--',''],
            \ [ "Close other &tabs\t:tabo", "tabo", "" ],
            \ [ "Close other &windows\t<Ctrl-w> o", "wincmd o", "" ],
            \ ])
call quickui#menu#install("&Commands", [
            \ [ "&Search Commands\tSpace-p", "Commands", "Commands" ],
            \ [ "C&oC Commands\tSpace-cp", "CocFzfList", "CocFzfList" ],
			\ ['--',''],
            \ [ "&Save session\t:SSave", "SSave", "" ],
            \ [ "L&oad session\t:SLoad", "SLoad", "" ],
            \ [ "&Close session\t:SClose", "SClose", "" ],
            \ [ "&Delete session\t:SDelete", "SDelete", "" ],
			\ ['--',''],
            \ [ "Floating &Terminal\tCtrl-t", "FloatermToggle", "FloatermToggle" ],
            \ ])

call quickui#menu#install("&Git", [
            \ [ "&Status\t:G", "G", "Git fugitive" ],
            \ [ "P&ull\t:Git pull", "Git pull", "Git pull" ],
            \ [ "&Push\t:Git push", "Git push", "Git push" ],
			\ ['--',''],
            \ [ "&Open Files\tCtrl-p", "GFiles", "GFiles" ],
            \ [ "Changed &Files\t:GFiles?", "GFiles?", "Git fzf files" ],
			\ ['--',''],
            \ [ "Create &branch", "call feedkeys(':Git checkout -b ')", "" ],
            \ [ "&Checkout branch\t:GBranches", "GBranches", "Show list of branches" ],
            \ [ "Set upstream branch", "execute 'Git push origin -u '.fugitive#head()", "Git push" ],
			\ ['--',''],
            \ [ "&Write and Commit", "call feedkeys(':Gwrite\<cr>:Gcommit\<cr>')", "Git write and then commit" ],
            \ [ "Co&mmit\t:Gcommit", "Gcommit", "Git commit" ],
			\ ['--',''],
            \ [ "Blame\t:Gblame", "Gblame", "Git blame" ],
            \ [ "Commits\t:Commits", "Commits!", "Git commits with fzf" ],
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ["Set &Spell \t%{&spell? 'Off':'On'}", 'set spell!', 'Enable spell checking'],
			\ ["Set L&ist \t%{&list? 'Off':'On'}", 'set list!', 'Show hidden characters'],
			\ ["Set &Wrap \t%{&wrap? 'Off':'On'}", 'set wrap!', 'Wrap lines'],
			\ ["Set &Background \t%{&background == 'dark' ? 'Light':'Dark'}", 'call ToggleBackground()', 'Change background'],
			\ ['--',''],
            \ [ "List &all\t:options", "vert options", ":options" ],
			\ ])

" register HELP menu with weight 10000
call quickui#menu#install('Hel&p', [
			\ ["&Search help\t:helpgrep", 'call feedkeys(":helpgrep ")', ''],
			\ ['--',''],
			\ ["&Cheatsheet\t:help index", 'vert help index', ''],
			\ ["T&ips\t:help tips", 'vert help tips', ''],
			\ ['--',''],
			\ ["&Tutorial\t:help tutor", 'vert help tutor', ''],
			\ ["&Quick Reference\t:help quickref", 'vert help quickref', ''],
			\ ['--',''],
			\ ["&Randow Tip\t:RandomVimTip", ':RandomVimTip', 'show random Vim Wiki Tip'],
			\ ], 10000)

function! ReloadConfig()
    let local_bg = &background
    source ~/.config/nvim/init.vim
    if local_bg == "dark"
        set background=dark
        call QuickThemeChange("gruvbox")
    else
        set background=light
        call QuickThemeChange("gruvbox light")
    endif
    echo "vimrc reloaded"
endfunction

function! ToggleBackground()
    if &background == "dark"
        set background=light
        call QuickThemeChange("gruvbox light")
    else
        set background=dark
        call QuickThemeChange("gruvbox")
    endif
endfunction

let content = [
            \ ["Re&name\t<space>rn", 'normal 1 rn' ],
            \ ["&Actions\t<space>a", 'normal 1 a' ],
            \ ["&Quick fix\t<space>qf", 'normal 1 qf' ],
            \ ['-'],
            \ ["&Go to Defintion\tgd", 'normal gd' ],
            \ ["Show &References\t<space>gr", 'normal 1 gr'],
            \ ["Show &Implementation\t<space>gi", 'normal 1 gi'],
            \ ["Show T&ype Defintion\t<space>gy", 'normal 1 gy'],
            \ ['-'],
            \ ["&Translate", 'TranslateW'],
            \ ["&Find in Project", 'exec "silent! grep " . expand("<cword>") | copen' ],
            \ ['-'],
            \ ["&Documentation\tK", 'normal K' ],
            \ ["&Helpfull version", 'exec "HelpfulVersion ".expand("<cword>")', '', 'vim' ],
            \ ]

" set cursor to the last position
let opts = {'index':g:quickui#context#cursor}

nmap <C-k> :call quickui#tools#clever_context('k', content, opts)<CR>
vmap <C-k> :call quickui#tools#clever_context('k', content, opts)<CR>

let g:quickui_color_scheme = 'gruvbox'
let g:quickui_border_style = 2

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" hit space twice to open menu
noremap <leader>m :call quickui#menu#open()<cr>
noremap <leader><leader> :call quickui#menu#open()<cr>

" Section: Plugin options

let g:fugitive_gitlab_domains = ['https://git.crona.local']

let g:translator_target_lang = 'ru'
let g:translator_window_max_width = 0.4

let g:floaterm_position = 'top'
let g:floaterm_autoinsert = 1

" xcode like git gutter signs
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_modified_removed = '┃'
let g:gitgutter_sign_removed = '•'
let g:gitgutter_sign_removed_first_line = '•' 

tnoremap <C-x><C-t> <C-\><C-N> :FloatermToggle<CR>
nmap <C-x><C-t> :FloatermToggle<CR>

" Use a floating window to show the off-screen match.
let g:matchup_matchparen_offscreen = {'method': 'popup'}
" only the tag name will be highlighted, not the rest of the line
let g:matchup_matchpref = {'html': {'tagnameonly': 1}}

let g:startify_disable_at_vimenter = 1
let g:startify_bookmarks = [ {'c': '~/.dotfiles/vimrc'}, '~/.dotfiles/zshrc', '~/.dotfiles/tmux.conf', '~/projects/kkrm', '~/projects/invitro_store', '~/projects/review_kkrm' ]
let g:startify_session_persistence = 1
let g:startify_session_autoload = 1
let g:startify_change_to_vcs_root = 1
let g:startify_custom_header = []
let g:startify_enable_unsafe = 1
let g:startify_lists = [
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ ]


augroup mygroupstartify
    autocmd!
    autocmd User Startified setlocal cursorline
augroup end

" theme
set background=dark
let g:gruvbox_sign_column = "bg0"
let g:gruvbox_invert_selection = 0
colorscheme gruvbox

" fix rust colors until https://github.com/morhetz/gruvbox/pull/334
hi! link rustFuncCall GruvboxBlue
hi! link rustCommentLineDoc GruvboxFg3
hi! link rustLifetime GruvboxAqua

" made change hunk color blue
hi! link GitGutterChange GruvboxBlue

" quick ui menu background
highlight QuickBG guibg=bg ctermbg=bg

" change folds colors
hi Folded ctermbg=NONE cterm=bold guibg=NONE

" do not show backgroun in current cursor line number
hi CursorLineNr ctermbg=bg guibg=bg

" fix cursorline highlight breaking on operators
hi Operator ctermbg=NONE guibg=NONE

" hide end of buffer '~' symbol
hi EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg

hi Quote ctermbg=NONE guibg=NONE

" File plugins settings
"
"Let the input go up and the search list go down
let $FZF_DEFAULT_OPTS = '--reverse --no-info --cycle'
let g:coc_fzf_opts = ['--reverse', '--no-info', '--cycle']

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'}

"Open FZF and choose floating window
if v:version >= 802 || has('nvim')
    let g:fzf_layout = { 'window': { 'width': 0.5, 'height': 0.4, 'yoffset': 0 } }
endif

" Empty value to disable preview window altogether
let g:fzf_preview_window = ''

" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'


" jump to existing window if possible
let g:fzf_buffers_jump = 1

" Ctrl+P open search for git files
nmap <C-p> :GFiles<CR>
" Ctrl+B open buffer list
nmap <C-b> :Buffers<CR>

" Space+P search for commands
map <Leader>p :Commands<CR>
map <Leader>cp :CocFzfList<CR>

" delete all buffers, except current one
" %bd - delete all buffers (puts you in empty buffer)
" e#  - open previous buffer
" bd# - delete previous buffer (deletes empty buffer)
" command! Bonly %bd <Bar> e# <Bar> bd#
" Same as tabonly, but for buffers
command! Bonly Bdelete other

" highlight libs
let g:used_javascript_libs = 'underscore,angularjs,angularui,angularuirouter,jquery'
" disable concealing for json files
let g:vim_json_syntax_conceal = 0

" run dispatch only in headless mode
let g:dispatch_handlers = ['headless']

" disable binds for dispatch
let g:dispatch_no_maps = 1

" format rust files on save by calling cargo format via :RustFmt
let g:rustfmt_autosave = 1
" Use leader ket for camel case
let g:camelcasemotion_key = '<leader>'
" elixir, format files on save
let g:mix_format_on_save = 1

let g:lightline = {
	\ 'enable': { 'tabline': 1 },
    \ 'tabline_separator': { 'left': "", 'right': "" },
    \ 'tabline_subseparator': { 'left': "", 'right': "" },
	\ 'colorscheme': 'gruvbox',
	\ 'active': {
	\   'left': [ [ 'gitbranch' ],
	\             [ 'readonly', 'filename'], ['modified'] ],
    \ 'right': [ [ 'filetype' ],
    \            [ 'percent' ],
    \            ['cocstatus' ]]
	\ },
	\ 'component_function': {
    \   'filetype': 'MyFileType',
    \   'filename': 'MyFileName',
	\   'gitbranch': 'fugitive#head',
	\   'cocstatus': 'coc#status'
	\ },
	\ }

let g:lightline.inactive = {
    \ 'left': [ ['gitbranch'], [ 'filename' ] ],
    \ 'right': [ [ 'filetype' ],
    \            [ 'percent' ] ] }

" show icon folowed by file name
function! MyFileType(...)
    let ft = strlen(&filetype) ?  WebDevIconsGetFileTypeSymbol() : ''

    return strlen(ft) ? ft . ' ' . &filetype : &filetype
endfunction

" show icon folowed by file name
function! MyFileName(...)
    let name = expand('%:t') !=# '' ? @% : '[No Name]'
    let ft = strlen(&filetype) ?  WebDevIconsGetFileTypeSymbol() : ''

    return strlen(ft) ? ft . ' ' . name : name
endfunction

let g:lightline.subseparator = { 'left': '⎜', 'right': '⎜' }

" hide close button in the tabline
let g:lightline.tabline = {
    \ 'left': [ [ 'tabs' ] ],
    \ 'right': [ [] ] }

let g:coc_status_error_sign = 'E'
let g:coc_status_warning_sign = 'W'

call lightline#init()
call lightline#colorscheme()
call lightline#update()

let g:lightline#colorscheme#gruvbox#palette.tabline.middle = [['#282828', '#282828', '235', '243']]

" Section: COC.VIM CONFIG

" this extensions will be installed
let g:coc_global_extensions = ["coc-rust-analyzer", "coc-tsserver", "coc-json", "coc-html", "coc-css", "coc-python", "coc-angular", "coc-elixir", "coc-eslint", "coc-yaml", "coc-explorer", "coc-emmet", "coc-vimlsp"]

hi CocExplorerNormalFloatBorder ctermbg=bg ctermbg=bg
hi CocExplorerNormalFloat ctermbg=bg

" Ctrl+f show explorer
nmap <C-f> :CocCommand explorer --position=floating<CR>

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
" inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'vert h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroupft
  autocmd!
  " detect filetypes
  autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript
  autocmd BufNewFile,BufRead *.json.ejs set filetype=json
  autocmd BufNewFile,BufRead *.html.ejs set filetype=html
  " correct comment highlight for jsonc
  autocmd FileType json syntax match Comment +\/\/.\+$+
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocActionAsync('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
" nmap <leader>ac  <Plug>(coc-codeaction)
nmap <leader>ac  :<C-u>CocFzfList actions<cr>
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocActionAsync('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocFzfList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocFzfList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocFzfList symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>

" vim:set foldmethod=expr foldexpr=getline(v\:lnum)=~'^\"\ Section\:'?'>1'\:'=':
