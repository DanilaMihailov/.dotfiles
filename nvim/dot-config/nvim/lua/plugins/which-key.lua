return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
  config = function() -- This is the function that runs, AFTER loading
    local wk = require 'which-key'
    wk.setup()

    wk.add {
      { '<leader><leader>', group = '[ ] Additional commands' },
      { '<leader><leader>b', group = '[B]uffer commands' },
      { '<leader><leader>g', group = '[G]it commands' },
      { '<leader><leader>d', group = '[D]ebug' },
      { '<leader><leader>s', group = '[S]ession commands' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>r', group = '[R]un' },
      { '<leader>rt', group = '[R]un Tests' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>w', group = '[W]orkspace' },
    }

    -- visual mode
    wk.add { '<leader>h', desc = 'Git [H]unk', mode = 'v' }
  end,
}
