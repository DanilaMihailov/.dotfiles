vim.pack.add {
  {
    src = 'https://github.com/folke/snacks.nvim',
    version = vim.version.range '2.x',
  },
}

local snacks = require 'snacks'

snacks.setup {
  picker = {
    layout = { position = 'bottom', preset = 'ivy_custom' },
    layouts = {
      ivy_custom = {
        layout = {
          box = 'vertical',
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.4,
          border = 'top',
          title = ' {title} {live} {flags}',
          title_pos = 'left',
          { win = 'input', height = 1, border = 'none' },
          {
            border = 'none',
            box = 'horizontal',
            { win = 'list', border = 'none' },
            { win = 'preview', border = 'none', title = '{preview}', width = 0.6 },
          },
        },
      },
    },
  },
}

vim.keymap.set('n', '<leader>sf', function()
  snacks.picker.smart()
end, { desc = 'Smart Find Files' })

vim.keymap.set('n', '<leader>sb', function()
  snacks.picker.buffers()
end, { desc = 'Buffers' })

vim.keymap.set('n', '<leader>:', function()
  snacks.picker.command_history()
end, { desc = 'Command History' })

-- find
vim.keymap.set('n', '<leader>sb', function()
  snacks.picker.buffers()
end, { desc = 'Buffers' })

vim.keymap.set('n', '<leader>sn', function()
  snacks.picker.files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Find Config File' })

vim.keymap.set('n', '<leader>ff', function()
  snacks.picker.files()
end, { desc = 'Find Files' })

vim.keymap.set('n', '<leader><leader>gf', function()
  snacks.picker.git_files()
end, { desc = 'Find Git Files' })

vim.keymap.set('n', '<leader>sR', function()
  snacks.picker.recent()
end, { desc = 'Recent' })

-- git
vim.keymap.set('n', '<leader><leader>gb', function()
  snacks.picker.git_branches()
end, { desc = 'Git Branches' })
vim.keymap.set('n', '<leader><leader>gl', function()
  snacks.picker.git_log()
end, { desc = 'Git Log' })
vim.keymap.set('n', '<leader><leader>gL', function()
  snacks.picker.git_log_line()
end, { desc = 'Git Log Line' })
vim.keymap.set('n', '<leader><leader>gs', function()
  snacks.picker.git_status()
end, { desc = 'Git Status' })
vim.keymap.set('n', '<leader><leader>gS', function()
  snacks.picker.git_stash()
end, { desc = 'Git Stash' })
vim.keymap.set('n', '<leader><leader>gd', function()
  snacks.picker.git_diff()
end, { desc = 'Git Diff (Hunks)' })

-- Grep
vim.keymap.set('n', '<leader>/', function()
  snacks.picker.lines()
end, { desc = 'Buffer Lines' })
vim.keymap.set('n', '<leader>sG', function()
  snacks.picker.grep_buffers()
end, { desc = 'Grep Open Buffers' })
vim.keymap.set('n', '<leader>sg', function()
  snacks.picker.grep()
end, { desc = 'Grep' })
vim.keymap.set({ 'n', 'x' }, '<leader>sw', function()
  snacks.picker.grep_word()
end, { desc = 'Visual selection or word' })

-- search
vim.keymap.set('n', '<leader>sc', function()
  snacks.picker.command_history()
end, { desc = 'Command History' })
vim.keymap.set('n', '<leader>sC', function()
  snacks.picker.commands()
end, { desc = 'Commands' })
vim.keymap.set('n', '<leader>sd', function()
  snacks.picker.diagnostics()
end, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>sD', function()
  snacks.picker.diagnostics_buffer()
end, { desc = 'Buffer Diagnostics' })
vim.keymap.set('n', '<leader>sh', function()
  snacks.picker.help()
end, { desc = 'Help Pages' })
vim.keymap.set('n', '<leader>sH', function()
  snacks.picker.highlights()
end, { desc = 'Highlights' })
vim.keymap.set('n', '<leader>sj', function()
  snacks.picker.jumps()
end, { desc = 'Jumps' })
vim.keymap.set('n', '<leader>sk', function()
  snacks.picker.keymaps()
end, { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>sl', function()
  snacks.picker.loclist()
end, { desc = 'Location List' })
vim.keymap.set('n', '<leader>sm', function()
  snacks.picker.marks()
end, { desc = 'Marks' })
vim.keymap.set('n', '<leader>sM', function()
  snacks.picker.man()
end, { desc = 'Man Pages' })
vim.keymap.set('n', '<leader>sq', function()
  snacks.picker.qflist()
end, { desc = 'Quickfix List' })
vim.keymap.set('n', '<leader>sr', function()
  snacks.picker.resume()
end, { desc = 'Resume' })
vim.keymap.set('n', '<leader>su', function()
  snacks.picker.undo()
end, { desc = 'Undo History' })
vim.keymap.set('n', '<leader>uC', function()
  snacks.picker.colorschemes()
end, { desc = 'Colorschemes' })

-- LSP
vim.keymap.set('n', 'gd', function()
  snacks.picker.lsp_definitions()
end, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gD', function()
  snacks.picker.lsp_declarations()
end, { desc = 'Goto Declaration' })
vim.keymap.set('n', 'gr', function()
  snacks.picker.lsp_references()
end, { nowait = true, desc = 'References' })
vim.keymap.set('n', 'gI', function()
  snacks.picker.lsp_implementations()
end, { desc = 'Goto Implementation' })
vim.keymap.set('n', 'gy', function()
  snacks.picker.lsp_type_definitions()
end, { desc = 'Goto T[y]pe Definition' })
vim.keymap.set('n', 'gai', function()
  snacks.picker.lsp_incoming_calls()
end, { desc = 'C[a]lls Incoming' })
vim.keymap.set('n', 'gao', function()
  snacks.picker.lsp_outgoing_calls()
end, { desc = 'C[a]lls Outgoing' })
vim.keymap.set('n', 'gO', function()
  snacks.picker.lsp_symbols()
end, { desc = 'LSP Symbols' })
vim.keymap.set('n', '<leader>sS', function()
  snacks.picker.lsp_workspace_symbols()
end, { desc = 'LSP Workspace Symbols' })
