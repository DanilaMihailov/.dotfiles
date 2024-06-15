local utils = require 'mihd.utils'

vim.keymap.set('n', '<leader><leader>gp', function()
  utils.runjob_with_notify({ 'git', 'push' }, 'Git push')
end, { desc = '[G]it [P]ush' })

vim.keymap.set('n', '<leader><leader>gu', function()
  utils.runjob_with_notify({ 'git', 'pull' }, 'Git pull')
end, { desc = '[G]it P[u]ll' })

vim.keymap.set('n', '<leader><leader>gb', function()
  vim.fn.feedkeys ':Git checkout -b '
end, { desc = '[G]it Create [B]ranch' })

vim.keymap.set('n', '<leader><leader>gs', function()
  local head = vim.api.nvim_call_function('fugitive#Head', {})
  utils.runjob_with_notify({ 'git', 'push', 'origin', '-u', head }, 'Set upstream branch')
  -- vim.fn.execute('Git push origin -u ' .. head)
end, { desc = '[G]it [S]et upstream' })
