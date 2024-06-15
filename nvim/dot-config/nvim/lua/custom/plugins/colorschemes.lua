return {

  {
    'folke/tokyonight.nvim',
    config = function()
      require('tokyonight').setup {
        transparent = true,
      }
      -- vim.cmd.colorscheme 'tokyonight'
    end,
  },
  {
    'olimorris/onedarkpro.nvim',
    priority = 1000, -- Ensure it loads first
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        transparent_background = true,
      }
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },

  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      local gruvbox = require 'gruvbox'
      gruvbox.setup {
        -- palette_overrides = {
        --   dark0_hard = '#1c1c1c',
        -- },
        contrast = 'hard',
        -- dim_inactive = false,
        transparent_mode = true,
        inverse = true,
        overrides = {
          LspSignatureActiveParameter = { link = 'Visual' },
          SignColumn = { bg = 'NONE' },
          DiffText = { bg = gruvbox.palette.faded_blue, fg = 'None' },
          GruvboxRedSign = { bg = 'NONE' },
          GruvboxYellowSign = { bg = 'NONE' },
          GruvboxBlueSign = { bg = 'NONE' },
          GruvboxAquaSign = { bg = 'NONE' },
          GruvboxGreenSign = { bg = 'NONE' },
        },
      }
      -- vim.cmd.colorscheme 'gruvbox'
      vim.opt.background = 'dark'
      vim.cmd [[
        hi FoldColumn guibg=NONE
      ]]
    end,
  },
}
