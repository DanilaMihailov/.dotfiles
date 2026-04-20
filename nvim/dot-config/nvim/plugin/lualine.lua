vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }

local custom_gruvbox = require 'lualine.themes.gruvbox'
custom_gruvbox.normal.a.gui = ''
custom_gruvbox.normal.b = custom_gruvbox.normal.a
custom_gruvbox.normal.c = custom_gruvbox.normal.a
custom_gruvbox.insert = custom_gruvbox.normal
custom_gruvbox.visual = custom_gruvbox.normal
custom_gruvbox.replace = custom_gruvbox.normal
custom_gruvbox.command = custom_gruvbox.normal

require('lualine').setup {
  options = {
    globalstatus = true,
    theme = 'auto',
    icons_enabled = true,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'branch' },
    lualine_b = { { 'diagnostics', colored = false, always_visible = false } },
    lualine_c = {
      { 'filename', path = 1, color = { gui = 'bold' } },
    },
    lualine_x = {
      'lsp_status',
      -- {
      --   require('lazy.status').updates,
      --   cond = require('lazy.status').has_updates,
      -- },
    },
    lualine_y = { { 'filetype', colored = false } },
    lualine_z = {
      { 'location', 'progress' },
    },
  },
  extensions = { 'quickfix', 'oil', 'mason', 'lazy', 'man' },
}
