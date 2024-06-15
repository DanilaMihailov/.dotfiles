return {
  cmd = 'Neotest',
  keys = { '<leader>rt' },
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
    'nvim-neotest/neotest-plenary',
    'jfpedroza/neotest-elixir',
  },
  config = function()
    local neotest = require 'neotest'
    require('neotest').setup {
      adapters = {
        require 'neotest-python',
        require 'neotest-plenary',
        require 'neotest-elixir',
      },
    }
    vim.keymap.set('n', '<leader>rtt', function()
      neotest.summary.open()
      neotest.run.run()
    end, { desc = 'Run Nearest [T]est' })

    vim.keymap.set('n', '<leader>rto', function()
      neotest.output_panel.toggle()
    end, { desc = 'Toggle [O]output Panel' })

    vim.keymap.set('n', '<leader>rts', function()
      neotest.summary.toggle()
    end, { desc = 'Toggle [S]ummary' })
  end,
}
