-- Basic vim options, plugin related options should be in separate files

vim.o.modelineexpr = true -- allow use of modeline at the start of the file, e.g. for folds

vim.o.number = true -- show line numbers
vim.o.relativenumber = true -- show relative line numbers (may be slow)
vim.o.clipboard = 'unnamed' -- copy to system clipboard
vim.o.keymap = 'russian-jcukenwin' -- allow use russian keys for moves and stuff
vim.o.iminsert = 0
vim.o.imsearch = 0
vim.o.cursorline = true -- show cursor line
vim.o.backspace = 'indent,eol,start' -- backspace over indent, eol, start
vim.opt.termguicolors = true

vim.o.laststatus = 3 -- global status line

vim.o.background = 'dark'

vim.o.encoding = 'utf-8'

vim.opt.listchars = 'tab:> ,trail:-,extends:>,precedes:<,nbsp:+'

vim.opt.formatoptions:append { 'j' } -- Delete comment character when joining commented lines

-- allows using motions in russian language
vim.opt.langmap='ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

-- when splitting windows, they will appear to the right, or below
vim.o.splitbelow = true
vim.o.splitright = true

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appear/become resolved.
vim.o.signcolumn = 'yes'

vim.o.lazyredraw = true -- do not redrow while macros execute

vim.o.scrolloff = 8

vim.o.cmdheight = 2 -- Better display for messages
vim.o.showtabline = 1 -- always show tab line
vim.opt.showmode = false -- do not show mode, as it i shown by light line

vim.o.hidden = true -- allow hidden buffers (TextEdit might fail if hidden is not set)

vim.opt.shortmess:append { c = true } -- Don't pass messages to |ins-completion-menu|.

-- backups and undo dirs
vim.o.backupdir = '/tmp//'
vim.o.directory = '/tmp//'
vim.o.undodir = '/tmp//'
vim.o.backup = true	-- keep a backup file (restore to previous version)

if vim.fn.has('persistent_undo') == 1 then
    vim.o.undofile = true	-- keep an undo file (undo changes after closing)
end

-- indentation rules
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.autoindent = true

-- Make searching better
vim.o.gdefault   = true    -- Never have to type /g at the end of search / replace again
vim.o.ignorecase = true    -- case insensitive searching (unless specified)
vim.o.smartcase  = true    -- use case sensitive, if have different cases in search string

-- helps gf to find files
-- ** - all files from root
-- .  - relative from current
-- ,, - relative from current in same dir
vim.opt.path = vim.opt.path + '**,.,,'

vim.o.mouse = 'a' -- enable mouse for all modes
vim.o.inccommand = 'split' -- show split with results when substitute

vim.o.shell = '/bin/zsh' -- use zsh as default shell

-- use ripgrep for :grep command
if vim.fn.executable('rg') == 1 then
    vim.o.grepprg = 'rg --vimgrep --hidden'
end

local termgroup = vim.api.nvim_create_augroup('mytermgroup', {clear = true})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  group = termgroup,
  desc = 'Hide line numbers in terminal',
  callback = function()
      vim.opt_local.relativenumber = false
      vim.opt_local.number = false
      vim.opt_local.signcolumn = 'no'
      vim.opt_local.cursorline = false
  end
})

vim.opt.wildmode = 'longest:full,list:longest,full' -- complete longest string
vim.o.wildignorecase = true -- ignore file names and dirs case when completing

-- Jump to last edit position on opening file
-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
vim.cmd [[
if has("autocmd")
    augroup mygrouplastposition
        autocmd!
        au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    augroup end
endif
]]

vim.cmd [[
 au TextYankPost * silent! lua vim.highlight.on_yank()
]]

vim.cmd [[
augroup mygroupft
  autocmd!
  " detect filetypes
  autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript
  autocmd BufNewFile,BufRead *.json.ejs set filetype=json
  autocmd BufNewFile,BufRead *.html.ejs set filetype=html
augroup end
]]
