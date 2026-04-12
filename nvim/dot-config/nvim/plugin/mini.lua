vim.pack.add {
  {
    src = 'https://github.com/nvim-mini/mini.nvim',
    version = vim.version.range '0.x',
  },
}

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [']quote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup { n_lines = 500 }

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

require('mini.bracketed').setup()

require('mini.move').setup {
  mappings = {
    up = '[e',
    down = ']e',

    line_up = '[e',
    line_down = ']e',
  },
}

require('mini.pairs').setup()
require('mini.sessions').setup {
  autoread = true,
  autowrite = true,
  file = '.mini-session.vim',
}

local win_config = function()
  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
  return {
    anchor = 'SE',
    col = vim.o.columns,
    row = vim.o.lines - pad,
    border = '',
    title = '',
  }
end
require('mini.notify').setup {
  window = { config = win_config },
  -- show it in lualine
  lsp_progress = {
    enable = false,
  },
}
vim.notify = require('mini.notify').make_notify()

-- Create command to show history
vim.api.nvim_create_user_command('Notifications', function()
  require('mini.notify').show_history()
end, { desc = 'Show notification history' })

vim.keymap.set('n', '<leader><leader>ss', function()
  MiniSessions.select()
end, { desc = '[S]elect Sessions' })

vim.keymap.set('n', '<leader><leader>sw', function()
  MiniSessions.write '.mini-session.vim'
end, { desc = '[W]rite Sessions' })

vim.keymap.set('n', '<leader><leader>sr', function()
  MiniSessions.read()
end, { desc = '[R]ead Last Session' })
