vim.g.gruvbox_sign_column = "bg0"
vim.g.gruvbox_invert_selection = false
vim.cmd("colorscheme gruvbox")


-- fix rust colors until https://github.com/morhetz/gruvbox/pull/334
vim.cmd("hi! link rustFuncCall GruvboxBlue")
vim.cmd("hi! link rustCommentLineDoc GruvboxFg3")
vim.cmd("hi! link rustLifetime GruvboxAqua")

-- made change hunk color blue
vim.cmd("hi! link GitGutterChange GruvboxBlue")

-- quick ui menu background
vim.cmd("highlight QuickBG guibg=bg ctermbg=bg")

-- change folds colors
vim.cmd("hi Folded ctermbg=NONE cterm=bold guibg=NONE")

-- do not show backgroun in current cursor line number
vim.cmd("hi CursorLineNr ctermbg=bg guibg=bg")

-- fix cursorline highlight breaking on operators
vim.cmd("hi Operator ctermbg=NONE guibg=NONE")

-- hide end of buffer '~' symbol
vim.cmd("hi EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg")

vim.cmd("hi Quote ctermbg=NONE guibg=NONE")
