local util = require 'code_review.util'

local M = {}

local function set_editor_options(buf)
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'markdown'
end

function M.open(opts)
  opts = opts or {}
  vim.cmd 'botright split'

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, opts.name or ('Code Review Note ' .. vim.uv.hrtime()))
  set_editor_options(buf)

  local initial = opts.initial or ''
  if initial ~= '' then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial, '\n', { plain = true }))
  end

  util.notify(opts.message or 'Write note and :wq to save')

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    once = true,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local body = util.trim(table.concat(lines, '\n'))

      if body ~= '' and opts.on_submit then
        opts.on_submit(body)
      end

      vim.bo[buf].modified = false
      vim.cmd 'close'
    end,
  })
end

return M
