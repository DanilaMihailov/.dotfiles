local M = {}

M.runjob_with_notify = function(cmd, title)
  vim.notify('Doing ' .. vim.fn.join(cmd, ' ') .. '...', vim.log.levels.INFO, {
    title = title,
  })
  local logs = {}
  local function handle_out(ch_id, data)
    if data == nil then
      return
    end
    for _, v in ipairs(data) do
      if v ~= nil then
        table.insert(logs, v)
      end
    end
  end
  vim.fn.jobstart(cmd, {
    stderr_buffered = true,
    stdout_buffered = true,
    on_stdout = handle_out,
    on_stderr = handle_out,
    on_exit = function()
      vim.notify(vim.fn.join(logs, '\n'), vim.log.levels.INFO, {
        title = title,
      })
    end,
  })
end

return M
