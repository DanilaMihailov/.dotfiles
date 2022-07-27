-- Basic vim maps, plugin related maps should be in separate files

-- leader key, mostly used for plugins
vim.g.mapleader = " "

vim.keymap.set("v", "<C-h>", ":nohlsearch<cr>", { desc = "Stop search highlight"})
vim.keymap.set("n", "<C-h>", ":nohlsearch<cr>", { desc = "Stop search highlight"})

vim.keymap.set("t", "<C-W>N", "<C-\\><C-n>", { desc = "Change terminal mode to normal as in vim"})
vim.keymap.set("t", "<C-W>n", "<C-\\><C-n>", { desc = "Change terminal mode to normal as in vim"})

vim.keymap.set("t", "<C-W>", "<C-\\><C-N><C-w>", { desc = "Move out of terminal as if it is just a window"})


-- Movement in insert mode (not really working)
vim.keymap.set("i", "<C-h>", "<C-o>h", { desc = "Move left in insert mode"})
vim.keymap.set("i", "<C-l>", "<C-o>l", { desc = "Move right in insert mode"})
vim.keymap.set("i", "<C-j>", "<C-o>j", { desc = "Move down in insert mode"})
vim.keymap.set("i", "<C-k>", "<C-o>k", { desc = "Move up in insert mode"})

-- recall the command-line whose beginning matches the current command-line
vim.keymap.set("c", "<c-n>", "<down>", { desc = "Next command"})
vim.keymap.set("c", "<c-p>", "<up>", { desc = "Previous command"})

-- navigate by display lines
vim.keymap.set("n", "j", "gj", { desc = "Go down by display lines"})
vim.keymap.set("n", "k", "gk", { desc = "Go up by display lines"})

-- make Y act like D
vim.keymap.set("n", "Y", "y$", { desc = "Yank to the end of the line"})
vim.keymap.set("v", "Y", "y$", { desc = "Yank to the end of the line"})

vim.keymap.set("n", "<leader>-", ":wincmd _<cr>:wincmd \\|<cr>", { desc = "Zoom on pane"})
vim.keymap.set("n", "<leader>=", ":wincmd =<cr>", { desc = "Rebalance panes"})

-- Search results centered please
vim.keymap.set("n", "n", "nzz", { silent = true, desc = "n, but centered"})
vim.keymap.set("n", "N", "Nzz", { silent = true, desc = "N, but centered"})
vim.keymap.set("n", "*", "*zz", { silent = true, desc = "*, but centered"})
vim.keymap.set("n", "#", "#zz", { silent = true, desc = "#, but centered"})
vim.keymap.set("n", "g*", "g*zz", { silent = true, desc = "g*, but centered"})

vim.keymap.set("n", "<C-x><C-f>", ':e <C-R>=expand("%:p:h") . "/" <CR>', { desc = "Open new file adjacent to current file like emacs"})
