vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig', version = vim.version.range '2.x' },
}

vim.lsp.enable 'ruff' -- python linter
vim.lsp.enable 'ty' -- python lsp
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'expert' -- elixir lsp
