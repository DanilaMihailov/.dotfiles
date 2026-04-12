vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  {
    src = 'https://github.com/nvim-mini/mini.icons',
    version = 'stable',
  },
  'https://github.com/folke/lazydev.nvim',
}

require('mini.icons').setup()
