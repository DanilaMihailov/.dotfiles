return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/noice.nvim' },
  config = function()
    local custom_gruvbox = require 'lualine.themes.gruvbox'
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
      { 'filetype', icon_only = true },
    }

    local ok_n, noice = pcall(require, 'noice')
    if ok_n then
      local noice_comps = {
        -- {
        --   noice.api.status.message.get_hl,
        --   cond = noice.api.status.message.has,
        -- },
        {
          noice.api.status.command.get,
          cond = noice.api.status.command.has,
          color = { fg = '#ff9e64' },
        },
        {
          noice.api.status.mode.get,
          cond = noice.api.status.mode.has,
          color = { fg = '#ff9e64' },
        },
        {
          noice.api.status.search.get,
          cond = noice.api.status.search.has,
          color = { fg = '#ff9e64' },
        },
      }
      line_x = vim.iter({ noice_comps, line_x }):flatten():totable()
    end

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
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1, 1)
            end,
            separator = { left = '', right = '' },
          },
        },
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = line_x,
        lualine_y = {
          clients_lsp,
          'progress',
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = { fg = '#ff9e64' },
          },
        },
        lualine_z = {
          {
            'tabs',
            mode = 0,
            max_length = vim.o.columns / 2,
          },
          { 'location', separator = { left = '', right = '' } },
        },
      },
      -- tabline = {
      --   lualine_a = {
      --     { 'tabs', mode = 2, max_length = vim.o.columns, separator = { left = '', right = '' } },
      --   },
      -- },
      extensions = { 'quickfix', 'fugitive', 'nvim-tree', 'oil', 'mason', 'lazy', 'man', 'trouble' },
      -- winbar = {
      --   lualine_a = { 'filename', 'diagnostics' },
      -- },
      -- inactive_winbar = {
      --   lualine_a = { 'filename', 'diagnostics' },
      -- },
    }
  end,
}
