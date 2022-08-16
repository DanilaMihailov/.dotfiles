require('telescope').setup({
  defaults = {
    layout_strategy = "vertical",
    dynamic_preview_title = true,
    preview = false,
    sorting_strategy = "ascending",
    layout_config = {
        prompt_position = "top",
      vertical = { width = 0.5 }
      -- other layout configuration here
    },
    -- other defaults configuration here
  },
  extensions = {
    file_browser = {
        layout_strategy = "vertical",
        grouped = true,
        select_buffer = true,
        initial_mode = "normal",

    }
}
  -- other configuration values here
})

require("telescope").load_extension "file_browser"

local telescope = require('telescope.builtin')
vim.keymap.set("n", "<C-p>", telescope.git_files, { desc = "Search files with telescope" })
vim.keymap.set("n", "<C-b>", telescope.buffers, { desc = "Search open buffers with telescope" })

-- vim.keymap.set("n", "<C-f>", function ()
--     require "telescope".extensions.file_browser.file_browser({grouped = true, select_buffer = true})
-- end)

