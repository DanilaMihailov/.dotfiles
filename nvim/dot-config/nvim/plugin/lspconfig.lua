vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig', version = vim.version.range '2.x' },
}


vim.lsp.config("tsc", {
  cmd = { "tsc", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    "bun.lock",
    ".git",
  },
})

vim.lsp.enable 'ruff' -- python linter
vim.lsp.enable 'ty' -- python lsp
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'tsc'
vim.lsp.enable 'expert' -- elixir lsp
vim.lsp.enable 'jsonls'
-- vim.lsp.enable 'eslint'
vim.lsp.enable 'biome'

vim.lsp.config("qmlls", {
  cmd = { "qmlls6" },
})
vim.lsp.enable 'qmlls'
