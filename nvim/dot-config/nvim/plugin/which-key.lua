vim.pack.add {
  {
    src = 'https://github.com/folke/which-key.nvim',
    version = vim.version.range '3.x',
  },
}

local wk = require 'which-key'

wk.setup()

wk.add {
  { '<leader><leader>', group = '[ ] Additional commands' },
  { '<leader><leader>b', group = '[B]uffer commands' },
  { '<leader><leader>g', group = '[G]it commands' },
  { '<leader><leader>s', group = '[S]ession commands' },
  { '<leader>d', group = '[D]ebug' },
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>h', group = 'Git [H]unk' },
  { '<leader>r', group = '[R]un' },
  -- { '<leader>rt', group = '[R]un Tests' },
  { '<leader>s', group = '[S]earch' },
  { '<leader>t', group = '[T]oggle' },
  -- { '<leader>w', group = '[W]orkspace' },
}

-- visual mode
wk.add { '<leader>h', desc = 'Git [H]unk', mode = 'v' }

wk.add {
  '<leader>?',
  function()
    require('which-key').show { global = false }
  end,
  desc = 'Buffer Local Keymaps (which-key)',
}
