vim.pack.add {
  {
    src = 'https://github.com/folke/snacks.nvim',
    version = vim.version.range '2.x',
  },
}

local snacks = require 'snacks'

snacks.setup {
  picker = {
    layout = { position = 'bottom', preset = 'ivy' },
  },
}

vim.keymap.set('n', '<leader><space>', function()
  snacks.picker.smart()
end, { desc = 'Smart Find Files' })
