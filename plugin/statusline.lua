local custom_gruvbox = require'lualine.themes.gruvbox'

custom_gruvbox.insert = custom_gruvbox.normal
custom_gruvbox.visual = custom_gruvbox.normal
custom_gruvbox.replace = custom_gruvbox.normal
custom_gruvbox.command = custom_gruvbox.normal

require('lualine').setup({
    options = {
        globalstatus = true,
        theme = custom_gruvbox,
        icons_enabled = false,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
    },
    sections = {
        lualine_a = {'branch'},
        lualine_b = {'diagnostics'},
        lualine_c = {{'filename', path = 1}},
        lualine_x = {'lsp_progress', 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    tabline = {
         lualine_a = {{'tabs', mode = 2}}
    }
})
