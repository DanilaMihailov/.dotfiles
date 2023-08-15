-- local servers = { 'sumneko_lua', 'rust_analyzer', 'tsserver', "emmet_ls", "elixirls", "cssls", "html", "jsonls", "yamlls", "eslint", "bashls", "omnisharp_mono" }
local servers = { 'rust_analyzer', 'tsserver', "emmet_ls", "elixirls", "cssls", "html", "jsonls", "yamlls", "eslint", "bashls", "omnisharp_mono", "svelte" }

require("mason").setup({
    ui = {
        border = "rounded"
    }
})
require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_installation = true,
})

local function extend(origin, new)
    for key, val in pairs(new) do
        origin[key] = val
    end
    return origin
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, extend(opts, { desc = "Show diagnostic float" }))
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, extend(opts, { desc = "Go to previous diagnostic" }))
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, extend(opts, { desc = "Go to next diagnostic" }))
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, extend(opts, { desc = "Set location list with diagnostic" }))

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, extend(bufopts, { desc = "Go to declaration" }))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, extend(bufopts, { desc = "Go to definition" }))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, extend(bufopts, { desc = "Hover under cursor" }))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, extend(bufopts, { desc = "Go to implementation" }))
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, extend(bufopts, { desc = "Show signature help" }))
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, extend(bufopts, { desc = "Add workspace folder" }))
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
        extend(bufopts, { desc = "Remove workspace folder" }))

    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, extend(bufopts, { desc = "List workspace folders" }))

    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, extend(bufopts, { desc = "Show type definition" }))
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, extend(bufopts, { desc = "Rename" }))
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, extend(bufopts, { desc = "Code action" }))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, extend(bufopts, { desc = "Show references" }))
    vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, extend(bufopts, { desc = "Format" }))
end

for _i, serv in ipairs(servers) do
    require('lspconfig')[serv].setup {
        on_attach = on_attach
    }
end

-- require('lspconfig')["sumneko_lua"].setup {
--     on_attach = on_attach,
--     settings = {
--         Lua = {
--             runtime = {
--                 -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--                 version = 'LuaJIT',
--             },
--             diagnostics = {
--                 -- Get the language server to recognize the `vim` global
--                 globals = { 'vim' },
--             },
--             workspace = {
--                 -- Make the server aware of Neovim runtime files
--                 library = vim.api.nvim_get_runtime_file("", true),
--             },
--             -- Do not send telemetry data containing a randomized but unique identifier
--             telemetry = {
--                 enable = false,
--             },
--         },
--     },
-- }
