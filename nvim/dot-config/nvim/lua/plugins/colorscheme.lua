return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    local gruvbox = require 'gruvbox'
    gruvbox.setup {
      contrast = 'soft',
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
    vim.cmd.colorscheme 'gruvbox'
    vim.opt.background = 'dark'
    vim.cmd [[
        hi FoldColumn guibg=NONE
      ]]
  end,
}
