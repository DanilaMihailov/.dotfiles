return {
  -- lazy = true,
  -- dir = '~/personal/nvim-plugins/love2d.nvim',
  'S1M0N38/love2d.nvim',
  -- cmd = 'LoveRun',
  opts = {
    path_to_love_bin = '/Applications/love.app/Contents/MacOS/love',
  },
  config = function()
    vim.keymap.set('n', '<leader>vr', function()
      vim.keymap.del('n', '<leader>vr')
      require('love2d').setup { path_to_love_bin = '/Applications/love.app/Contents/MacOS/love' }
      vim.keymap.set('n', '<leader>vv', '<cmd>LoveRun<cr>', { desc = 'Run LÖVE' })
      vim.keymap.set('n', '<leader>vs', '<cmd>LoveStop<cr>', { desc = 'Stop LÖVE' })
    end, { desc = 'Start LÖVE plugn' })
  end,
  -- keys = {
  --   { '<leader>v', desc = 'LÖVE' },
  --   { '<leader>vv', '<cmd>LoveRun<cr>', desc = 'Run LÖVE' },
  --   { '<leader>vs', '<cmd>LoveStop<cr>', desc = 'Stop LÖVE' },
  -- },
}
