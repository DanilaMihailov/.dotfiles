return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    local gruvbox = require 'gruvbox'
    gruvbox.setup {
      -- contrast = 'soft',
      overrides = {
        LspSignatureActiveParameter = { link = 'Visual' },
        SignColumn = { bg = 'NONE' },
        DiffText = { bg = gruvbox.palette.faded_blue, fg = 'None' },
        -- DiffAdd = { bg = gruvbox.palette.dark_green, fg = 'None' },
        -- DiffDelete = { bg = gruvbox.palette.dark_red, fg = 'None' },
        -- DiffChange = { bg = gruvbox.palette.dark_aqua, fg = 'None' },
        GruvboxRedSign = { bg = 'NONE' },
        GruvboxYellowSign = { bg = 'NONE' },
        GruvboxBlueSign = { bg = 'NONE' },
        GruvboxAquaSign = { bg = 'NONE' },
        GruvboxGreenSign = { bg = 'NONE' },
      },
    }
    vim.cmd.colorscheme 'gruvbox'
    vim.opt.background = 'dark'
    vim.cmd [[
        hi FoldColumn guibg=NONE
        hi! link Delimiter GruvboxFg1
      ]]
  end,
}
