-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.laststatus = 3

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
--
-- vim.o.keymap = 'russian-jcukenwin' -- allow use russian keys for moves and stuff
-- allows using motions in russian language
vim.opt.langmap =
  'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчнях;abcdefghijklmnopqrstuvwxyz['

-- helps gf to find files
-- ** - all files from root
-- .  - relative from current
-- ,, - relative from current in same dir
vim.opt.path = vim.opt.path + '**,.,,'

-- vim.opt.showtabline = 0

vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_node_provider = false

vim.o.shell = '/bin/zsh' -- use zsh as default shell

-- для легаси в kkrm
vim.filetype.add {
  pattern = {
    ['.*%.js%.ejs'] = 'javascript',
    ['.*%.py%.example'] = 'python',
    ['.*%.html%.ejs'] = 'html',
    ['.*%.json%.ejs'] = 'json',
  },
}

vim.o.sessionoptions =
  'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.cmd.colorscheme 'retrobox' -- default colorscheme, overriden by plugins

-- Make searching better
vim.opt.gdefault = true -- Never have to type /g at the end of search / replace again

-- Make line numbers default
vim.opt.number = true
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
vim.opt.signcolumn = 'number'

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

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

vim.g.show_diagnostic_virutal_lines = true
-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  -- virtual_text = {
  --   virt_text_hide = !vim.g.show_diagnostic_virutal_text
  --   source = 'if_many',
  --   spacing = 2,
  --   format = function(diagnostic)
  --     local diagnostic_message = {
  --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
  --       [vim.diagnostic.severity.WARN] = diagnostic.message,
  --       [vim.diagnostic.severity.INFO] = diagnostic.message,
  --       [vim.diagnostic.severity.HINT] = diagnostic.message,
  --     }
  --     return diagnostic_message[diagnostic.severity]
  --   end,
  -- },
}

-- folds using treesitter
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false -- do not fold by default
vim.opt.foldtext = '' -- "transparent folds - just text with syntax highlight"
vim.opt.fillchars = 'fold: '
vim.opt.fillchars = 'eob: ' -- hide end of buffer '~' symbol

-- vim.opt.spell = true
-- vim.opt.spelllang = 'en,ru'

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

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- Use Russian Ctrl+х as Esc
vim.keymap.set({ 'n', 'i', 'v', 't' }, '<C-х>', '<Esc>', { desc = 'Russian Ctrl-х as Esc' })
vim.keymap.set({ 'n', 'i', 'v', 't' }, '<C-[>', '<Esc>', { desc = 'Ensure Ctrl-[ is also Esc' })

vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)

vim.keymap.set('n', '<leader>td', function()
  vim.g.show_diagnostic_virutal_lines = not vim.g.show_diagnostic_virutal_lines
  vim.diagnostic.config { virtual_lines = vim.g.show_diagnostic_virutal_lines }
end, { desc = 'Toggle [D]iagnostics' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

local function get_relative_bufpath()
  local bufname = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(bufname, '.git') or vim.uv.cwd()
  if not root then
    return nil
  end

  return vim.fs.relpath(root, bufname) or bufname
end

vim.keymap.set('n', 'y<C-g>', function()
  local relpath = get_relative_bufpath()
  if not relpath then
    return
  end

  local value = relpath .. ':' .. vim.fn.line '.'

  vim.fn.setreg(vim.v.register, value)
  vim.notify('Copied path to clipboard\n' .. value, vim.log.levels.INFO)
end, { desc = 'Yank relative file path' })

vim.keymap.set('n', '<leader>ys', function()
  local relpath = get_relative_bufpath()
  if not relpath then
    return
  end

  local line_nr = vim.fn.line '.'
  local value = relpath .. ':' .. line_nr .. '\n' .. vim.fn.getline(line_nr)

  vim.fn.setreg(vim.v.register, value)
  vim.notify('Copied path and line to clipboard\n' .. value, vim.log.levels.INFO)
end, { desc = 'Yank relative file path with line text' })

vim.keymap.set('x', '<leader>ys', function()
  local relpath = get_relative_bufpath()
  if not relpath then
    return
  end

  local visual_type = vim.fn.visualmode()
  local a = vim.fn.getpos 'v'
  local b = vim.fn.getpos '.'
  local start_pos, end_pos = a, b

  if a[2] > b[2] or (a[2] == b[2] and a[3] > b[3]) then
    start_pos, end_pos = b, a
  end

  local selected = vim.fn.getregion(start_pos, end_pos, { type = visual_type })
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local line_range = start_line == end_line and tostring(start_line) or (start_line .. '-' .. end_line)
  local value = relpath .. ':' .. line_range .. '\n' .. table.concat(selected, '\n')

  vim.fn.setreg(vim.v.register, value)
  vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'x', false)
  vim.notify('Copied path and selection to clipboard\n' .. value, vim.log.levels.INFO)
end, { desc = 'Yank relative file path with selected text' })

vim.keymap.set('n', 'gh', '_', { desc = 'Move cursor to the begining of line (_)' })
vim.keymap.set('n', 'gl', '$', { desc = 'Move cursor to the end of line ($)' })

vim.keymap.set('n', '<leader>`', '<C-^>', { desc = 'Switch to other buffer (C-^)' })

vim.keymap.set('t', '<C-W>N', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set('t', '<C-W>n', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set(
  't',
  '<C-W>',
  '<C-\\><C-N><C-w>',
  { desc = 'Move out of terminal as if it is just a window' }
)

vim.keymap.set('n', '<leader>-', ':wincmd _<cr>:wincmd \\|<cr>', { desc = 'Zoom on pane' })
vim.keymap.set('n', '<leader>=', ':wincmd =<cr>', { desc = 'Rebalance panes' })

-- Search results centered please
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = 'n, but centered' })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = 'N, but centered' })
vim.keymap.set('n', '*', '*zz', { silent = true, desc = '*, but centered' })
vim.keymap.set('n', '#', '#zz', { silent = true, desc = '#, but centered' })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true, desc = 'g*, but centered' })

local spell_on_choice = vim.schedule_wrap(function(_, idx)
  if type(idx) == 'number' then
    vim.cmd('normal! ' .. idx .. 'z=')
  end
end)

local spellsuggest_select = function()
  if vim.v.count > 0 then
    spell_on_choice(nil, vim.v.count)
    return
  end
  local cword = vim.fn.expand '<cword>'
  local prompt = 'Change ' .. vim.inspect(cword) .. ' to:'
  vim.ui.select(vim.fn.spellsuggest(cword, vim.o.lines), { prompt = prompt }, spell_on_choice)
end

vim.keymap.set('n', 'z=', spellsuggest_select, { desc = 'Shows spelling suggestions' })
vim.keymap.set('n', '<leader>ts', function()
  vim.opt.spell = not vim.opt.spell
end, { desc = 'Toggle spell check' })
