return {
  'olimorris/codecompanion.nvim',
  enabled = false,
  opts = {
    interactions = {
      chat = {
        adapter = 'opencode',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}
