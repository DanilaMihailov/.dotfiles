require('lualine').setup({
    options = {
        theme = 'gruvbox',
        icons_enabled = false,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
    },
    sections = {
        lualine_x = {"lsp_progress"}
    },
    tabline = {
         lualine_a = {{'tabs', mode = 2}}
    }
})
