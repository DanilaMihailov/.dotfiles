return {
  'nvim-lualine/lualine.nvim',
  -- event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local custom_gruvbox = require 'lualine.themes.gruvbox'
    custom_gruvbox.normal.a.gui = ''
    custom_gruvbox.normal.b = custom_gruvbox.normal.a
    custom_gruvbox.normal.c = custom_gruvbox.normal.a
    custom_gruvbox.insert = custom_gruvbox.normal
    custom_gruvbox.visual = custom_gruvbox.normal
    custom_gruvbox.replace = custom_gruvbox.normal
    custom_gruvbox.command = custom_gruvbox.normal

    -- LSP clients attached to buffer
    local clients_lsp = function()
      local bufnr = vim.api.nvim_get_current_buf()

      local clients = vim.lsp.get_clients { bufnr = bufnr }
      if next(clients) == nil then
        return ''
      end

      local c = {}
      for _, client in pairs(clients) do
        table.insert(c, client.name)
      end
      return '\u{f085}  ' .. table.concat(c, ' ')
    end

    local line_x = {
      { 'filetype', icon_only = true, colored = false },
    }

    require('lualine').setup {
      options = {
        globalstatus = true,
        theme = 'auto',
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {},
        lualine_b = { 'branch', { 'diagnostics', colored = false } },
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = line_x,
        lualine_y = {
          clients_lsp,
          -- 'lsp_status',
          'progress',
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
          },
        },
        lualine_z = {
          { 'location' },
        },
      },
      -- tabline = {
      --   lualine_a = {
      --     { 'tabs', mode = 2, max_length = vim.o.columns, separator = { left = '', right = '' } },
      --   },
      -- },
      extensions = { 'quickfix', 'oil', 'mason', 'lazy', 'man' },
      -- winbar = {
      --   lualine_a = { 'filename', 'diagnostics' },
      -- },
      -- inactive_winbar = {
      --   lualine_a = { 'filename', 'diagnostics' },
      -- },
    }
  end,
}
