require('telescope').setup({
  defaults = {
    layout_strategy = "vertical",
    dynamic_preview_title = true,
    layout_config = {
      vertical = { width = 0.5 }
      -- other layout configuration here
    },
    -- other defaults configuration here
  },
  -- other configuration values here
})

local telescope = require('telescope.builtin')
vim.keymap.set("n", "<C-p>", telescope.git_files, { desc = "Search files with telescope" })
vim.keymap.set("n", "<C-b>", telescope.buffers, { desc = "Search open buffers with telescope" })
