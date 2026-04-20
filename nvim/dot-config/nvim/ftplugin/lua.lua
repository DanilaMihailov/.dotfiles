if not vim.g.lazydev_is_setup then
  vim.notify('Setting up lazydev', vim.log.levels.INFO, { title = '' })
  require('lazydev').setup {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  }
  vim.g.lazydev_is_setup = true
end
