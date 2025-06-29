return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  config = function()
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

    require('mini.pairs').setup()
    require('mini.sessions').setup {
      autoread = true,
      autowrite = true,
      file = '',
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
    }
    vim.notify = require('mini.notify').make_notify()

    vim.keymap.set('n', '<leader><leader>ss', function()
      MiniSessions.select()
    end, { desc = '[S]elect Sessions' })

    vim.keymap.set('n', '<leader><leader>sr', function()
      MiniSessions.read()
    end, { desc = '[R]ead Last Session' })
  end,
}
