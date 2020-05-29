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

" do not redrow while macros execute
set lazyredraw

set updatetime=100 " delay for vim update (used by gitgutter and coc.vim)
set hidden " TextEdit might fail if hidden is not set.
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

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

" show vim highlight group under cursor
nnoremap <leader>hi :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Make searching better
set gdefault      " Never have to type /g at the end of search / replace again
set ignorecase    " case insensitive searching (unless specified)
set smartcase     " use case sensitive, if have different cases in search string

" Jump to start and end of line using the home row keys
map H ^
map L $

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
Plug 'morhetz/gruvbox'
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
Plug 'neovimhaskell/haskell-vim'

" Motion and helpers
Plug 'easymotion/vim-easymotion' " Space+Space+Motion
Plug 'mattn/emmet-vim' " Emmet support Ctrl+y Ctrl+,
Plug 'tpope/vim-surround' " Surrond with braces ysB
Plug 'tpope/vim-repeat' " enable repeat for tpope's plugins
Plug 'tomtom/tcomment_vim' " gcc to comment line
Plug 'jiangmiao/auto-pairs' " auto pair open brackets
Plug 'bkad/CamelCaseMotion' " move by camel case words with Space + Motion

" Autocomplete, linting, LSP
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Misc
Plug 'itchyny/lightline.vim' " Status line
Plug 'https://github.com/machakann/vim-highlightedyank' " Highlight yanked text
Plug 'myusuf3/numbers.vim' " toggle line numbers intelligently
Plug 'mhinz/vim-mix-format' " format elixir files on save
Plug 'majutsushi/tagbar' " show ctags in sidebar
call plug#end()

" theme
set background=dark
let g:gruvbox_italic=1
colorscheme gruvbox
" colorscheme solarized
" colorscheme codedark
 
hi SignColumn ctermbg=bg
hi GruvboxGreenSign ctermbg=bg
hi GruvboxRedSign ctermbg=bg
hi GruvboxBlueSign ctermbg=bg
hi GruvboxAquaSign ctermbg=bg
hi GruvboxYellowSign ctermbg=bg
hi GruvboxOrangeSign ctermbg=bg
hi CursorLineNr ctermbg=bg

hi CocInfoSign ctermfg=blue

" fix cursorline highlight breaking on operators
hi Operator ctermbg=NONE

" remove line under tabbar
" hi TabLineFill cterm=NONE
" hi TabLineSel cterm=NONE ctermbg=11 ctermfg=0
" hi TabLine cterm=NONE

" hi VertSplit ctermbg=0 ctermfg=0
"
" hide end of buffer '~' symbol
hi EndOfBuffer ctermbg=bg ctermfg=bg

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
endfunction

" Ctrl+P open search for git files
map <C-p> :GFiles<CR>
" Space+P search for commands
map <Leader>p :Commands<CR>
" Ctrl+B show sidebar
map <C-b> :NERDTreeToggle<CR>

" ignore files for NERDTree
let NERDTreeIgnore = ['\.pyc$']
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

autocmd BufWinEnter NERD_tree* setlocal signcolumn=no

" highlight libs
let g:used_javascript_libs = 'underscore,angularjs,angularui,angularuirouter,jquery'
" disable concealing for json files
let g:vim_json_syntax_conceal = 0

autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript
autocmd BufNewFile,BufRead *.json.ejs set filetype=json

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
	\ 'colorscheme': 'gruvbox',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus' ] ]
	\ },
	\ 'component_function': {
	\   'gitbranch': 'fugitive#head',
	\   'cocstatus': 'coc#status'
	\ },
	\ }


" COC.VIM CONFIG
" :CocInstall coc-rust-analyzer coc-tsserver coc-json coc-html coc-css coc-python coc-angular coc-elixir coc-eslint coc-yaml


let g:coc_status_error_sign = 'E'
let g:coc_status_warning_sign = 'W'

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
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
" nmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
" nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
