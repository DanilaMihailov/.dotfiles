return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>tf',
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
      end,
      mode = '',
      desc = '[T]oggle [F]ormat on Save',
    },
  },
  opts = {
    log_level = vim.log.levels.DEBUG,
    notify_on_error = true,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      gleam = { 'gleam' },
      toml = { 'taplo' },
      markdown = { 'prettier' },
      python = function()
        return { 'ruff_fix', 'ruff_format' }
      end,
      html = { 'prettier' },
      htmlangular = { 'prettier' },
      htmldjango = { 'djlint' },
      javascript = { 'prettier' },
      sh = { 'beautysh' },
    },
    formatters = {
      eslint_d = {
        prepend_args = { '-c', 'eslint.config.js' },
      },
      prettier = {
        inherit = false,
        command = 'prettier',
        args = function(_, ctx)
          local parser = nil
          -- kkrm shenanigans
          local ft_to_parser = {
            ['.js.ejs'] = 'babel',
            ['.html.ejs'] = 'html',
          }
          for key, value in pairs(ft_to_parser) do
            if ctx.filename:find(key) then
              parser = { '--parser', value }
            end
          end
          return parser or { '--stdin-filepath', '$FILENAME' }
        end,
        -- NOTE: range_args not really working for prettier
        -- https://github.com/stevearc/conform.nvim/pull/322
        range_args = nil,
      },
      beautysh = {
        prepend_args = { '-i', 2 },
      },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
