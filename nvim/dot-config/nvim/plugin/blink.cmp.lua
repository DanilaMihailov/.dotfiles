vim.pack.add {
  {
    src = 'https://github.com/Saghen/blink.cmp',
    version = vim.version.range '1.x',
  },
}

local blink = require 'blink.cmp'

--- @module 'blink.cmp'
--- @type blink.cmp.Config
blink.setup {
  keymap = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    preset = 'default',
    ['<c-l>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },

    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  completion = {
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    -- Display a preview of the selected item on the current line
    ghost_text = { enabled = true },
  },

  sources = {
    default = { 'lsp', 'buffer', 'path', 'snippets', 'lazydev' },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      buffer = {
        opts = {
          -- get all buffers, even ones like neo-tree
          get_bufnrs = vim.api.nvim_list_bufs,
        },
      },
    },
  },

  -- snippets = { preset = 'luasnip' },

  -- See :h blink-cmp-config-fuzzy for more information
  fuzzy = { implementation = 'prefer_rust_with_warning' },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}
