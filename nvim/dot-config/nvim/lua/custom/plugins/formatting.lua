--- Passed to vim.lsp.buf.format
---@param client vim.lsp.Client
---@return boolean
local formatFilter = function(client)
  -- biome is used to format js and json files
  return client.name ~= 'tsserver' and client.name ~= 'jsonls'
end
return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true, filter = formatFilter }
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
      -- отключает автоформат для директории kkrm
      if vim.fn.getcwd(-1, -1):find 'kkrm' then
        return false
      end
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        filter = formatFilter,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      gleam = { 'gleam' },
      toml = { 'taplo' },
      markdown = { 'prettier' },
      python = function()
        -- ruff only works with python3
        if vim.fn.getcwd(-1, -1):find 'kkrm' then
          return { 'autopep8', 'docformatter', 'isort' }
        else
          return { 'ruff_fix', 'ruff_format' }
        end
      end,
      html = { 'prettier' },
      javascript = { 'prettier' },
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
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
