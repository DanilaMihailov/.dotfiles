vim.pack.add {
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
vim.opt.background = 'dark'

local function running_in_linux_tty()
  if vim.env.TERM == 'linux' then
    return true
  end

  if vim.env.TMUX and vim.fn.executable 'tmux' == 1 then
    local tty = vim.fn.system {
      'tmux',
      'display-message',
      '-p',
      '#{client_tty}',
    }

    return vim.v.shell_error == 0
      and tty:match '^/dev/tty%d+%s*$' ~= nil
  end

  return false
end


if running_in_linux_tty() then
  vim.opt.termguicolors = false
  vim.cmd.colorscheme 'retrobox'
else
  vim.cmd.colorscheme 'gruvbox'
end

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
  'SnacksPickerDir', -- The scrollbar background
}

for _, group in ipairs(groups) do
  -- Force link to 'Normal' to match your main Gruvbox background
  vim.api.nvim_set_hl(0, group, { link = 'Normal' })
end

require('mini.icons').setup()
