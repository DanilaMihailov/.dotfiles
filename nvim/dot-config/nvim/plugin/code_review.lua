require('code_review').setup()

vim.keymap.set({ 'n', 'x' }, '<leader>ca', '<cmd>CodeReviewAnnotate<CR>', {
  desc = 'Code review annotate',
})

vim.keymap.set('n', '<leader>cn', '<cmd>CodeReviewNotes<CR>', {
  desc = 'Code review notes',
})

vim.keymap.set('n', '<leader>cy', '<cmd>CodeReviewCopy<CR>', {
  desc = 'Code review copy notes',
})
