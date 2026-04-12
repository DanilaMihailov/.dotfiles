vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  {
    src = 'https://github.com/nvim-mini/mini.icons',
    version = 'stable',
  },
  'https://github.com/folke/lazydev.nvim',
  {
    src = 'https://github.com/ellisonleao/gruvbox.nvim',
    version = vim.version.range '2.x',
  },
}

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

local groups = {
  'SnacksPicker',
  'SnacksPickerInput',
  'SnacksPickerList',
  'SnacksPickerPreview',
  'SnacksPickerBorder', -- The border background
  'SnacksPickerScrollBar', -- The scrollbar background
}

for _, group in ipairs(groups) do
  -- Force link to 'Normal' to match your main Gruvbox background
  vim.api.nvim_set_hl(0, group, { link = 'Normal' })
end

require('mini.icons').setup()
