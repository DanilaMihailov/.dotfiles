-- автокомплит, go to definition (LSP, Mason, nvim-cmp)
-- подсветка синтакса (Treesitter)
-- поиск по файлам (telescope, neo-tree)
-- интеграция с гит (fugitive, gitsigns, telescope)
-- автоформатирование (conform, lsp)
--
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
--
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- vim.o.keymap = 'russian-jcukenwin' -- allow use russian keys for moves and stuff
--
-- allows using motions in russian language
vim.opt.langmap =
  'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

-- helps gf to find files
-- ** - all files from root
-- .  - relative from current
-- ,, - relative from current in same dir
vim.opt.path = vim.opt.path + '**,.,,'

vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_node_provider = false

vim.o.shell = '/bin/zsh' -- use zsh as default shell

-- use ripgrep for :grep command
-- if vim.fn.executable 'rg' == 1 then
--   vim.o.grepprg = 'rg --vimgrep --hidden'
-- end

vim.cmd [[
augroup mygroupft
  autocmd!
  " detect filetypes
  autocmd BufNewFile,BufRead *.js.ejs set filetype=javascript
  autocmd BufNewFile,BufRead *.json.ejs set filetype=json
  autocmd BufNewFile,BufRead *.html.ejs set filetype=html
augroup end
]]

vim.o.sessionoptions =
  'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.cmd.colorscheme 'retrobox' -- default colorscheme, overriden by plugins

-- Make searching better
vim.opt.gdefault = true -- Never have to type /g at the end of search / replace again

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.g.show_diagnostic_virutal_text = true
-- Diagnostic keymaps
vim.diagnostic.config {
  severity_sort = true,
  virtual_text = vim.g.show_diagnostic_virutal_text,
}

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)
vim.keymap.set('n', '<leader>td', function()
  vim.g.show_diagnostic_virutal_text = not vim.g.show_diagnostic_virutal_text
  vim.diagnostic.config { virtual_text = vim.g.show_diagnostic_virutal_text }
end, { desc = '[T]oggle [D]iagnostics' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- folds using treesitter
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false -- do not fold by default
vim.opt.foldtext = '' -- "transparent folds - just text with syntax highlight"
vim.opt.fillchars = 'fold: '

-- Switch between tabs
vim.keymap.set('n', '<A-l>', function()
  vim.api.nvim_feedkeys('gt', 'n', true)
end, { desc = 'Next tab' })

vim.keymap.set('n', '<A-h>', function()
  vim.api.nvim_feedkeys('gT', 'n', true)
end, { desc = 'Previous tab' })

local termgroup = vim.api.nvim_create_augroup('mytermgroup', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  group = termgroup,
  desc = 'Hide line numbers in terminal',
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.cursorline = false
  end,
})

-- vim.opt.wildmode = 'longest:full,list:longest,full' -- complete longest string
-- vim.o.wildignorecase = true -- ignore file names and dirs case when completing

-- Jump to last edit position on opening file
-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
vim.cmd [[
augroup mygrouplastposition
    autocmd!
    au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup end
]]

vim.keymap.set('t', '<C-W>N', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set('t', '<C-W>n', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set(
  't',
  '<C-W>',
  '<C-\\><C-N><C-w>',
  { desc = 'Move out of terminal as if it is just a window' }
)

-- vim.keymap.set('n', '<leader>-', ':wincmd _<cr>:wincmd \\|<cr>', { desc = 'Zoom on pane' })
-- vim.keymap.set('n', '<leader>=', ':wincmd =<cr>', { desc = 'Rebalance panes' })

-- Search results centered please
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = 'n, but centered' })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = 'N, but centered' })
vim.keymap.set('n', '*', '*zz', { silent = true, desc = '*, but centered' })
vim.keymap.set('n', '#', '#zz', { silent = true, desc = '#, but centered' })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true, desc = 'g*, but centered' })

vim.keymap.set(
  'n',
  '<C-x><C-f>',
  ':e <C-R>=expand("%:p:h") . "/" <CR>',
  { desc = 'Open new file adjacent to current file like emacs' }
)
