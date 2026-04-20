vim.pack.add { 'https://github.com/Asheq/close-buffers.vim' }

vim.keymap.set(
  'n',
  '<leader><leader>bo',
  '<CMD>Bdelete other<cr>',
  { desc = '[B]uffer Delete [O]ther' }
)
vim.keymap.set(
  'n',
  '<leader><leader>bh',
  '<cmd>Bdelete hidden<cr>',
  { desc = '[B]uffer Delete [H]idden' }
)
