local M = {}

function M.populate(files, root)
  local items = {}

  for _, file in ipairs(files) do
    local text = file.status
    if file.untracked then
      text = 'untracked'
    elseif file.old_path then
      text = string.format('%s from %s', file.status, file.old_path)
    end

    table.insert(items, {
      filename = vim.fs.joinpath(root, file.path),
      lnum = 1,
      col = 1,
      text = text,
    })
  end

  vim.fn.setqflist({}, 'r', {
    title = 'Code Review Files',
    items = items,
  })

  if #items > 0 then
    vim.cmd 'copen'
  else
    vim.cmd 'cclose'
  end

  return #items
end

return M
