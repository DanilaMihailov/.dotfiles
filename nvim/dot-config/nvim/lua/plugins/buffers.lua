return { -- Bdelete [other, hidden, this]
  'Asheq/close-buffers.vim',
  cmd = 'Bdelete',
  keys = {
    {
      '<leader><leader>bo',
      '<CMD>Bdelete other<cr>',
      desc = '[B]uffer Delete [O]ther',
    },
    {
      '<leader><leader>bh',
      '<cmd>Bdelete hidden<cr>',
      desc = '[B]uffer Delete [H]idden',
    },
  },
}
