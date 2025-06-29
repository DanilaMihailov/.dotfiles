-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

vim.keymap.set('n', 'y<C-g>', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local cwd = vim.uv.cwd()
  if not cwd then
    return
  end
  local relPath = '.' .. bufname:gsub(cwd, '') .. ':' .. vim.fn.line '.'
  vim.notify('Copied path to clipboard\n' .. relPath, vim.log.levels.INFO)
  vim.fn.setreg(vim.v.register, relPath)
end, { desc = 'Yank relative file path' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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
