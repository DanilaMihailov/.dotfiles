vim.pack.add({{
src = 'https://github.com/stevearc/oil.nvim',
version = vim.version.range('2.x')
}})

local oil = require('oil')

oil.setup(
---@type oil.setupOpts
{
    win_options = {
      signcolumn = 'yes:2',
      winbar = '%F',
    },
    skip_confirm_for_simple_edits = true,
    delete_to_trash = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ['<C-p>'] = {
        desc = 'Open preview in horizontal split',
        callback = function()
          local oil = require 'oil'
          local util = require 'oil.util'
          local entry = oil.get_cursor_entry()
          if not entry then
            vim.notify('Could not find entry under cursor', vim.log.levels.ERROR)
            return
          end
          local winid = util.get_preview_win()
          if winid then
            local cur_id = vim.w[winid].oil_entry_id
            if entry.id == cur_id then
              vim.api.nvim_win_close(winid, true)
              return
            end
          end
          oil.open_preview {
            horizontal = true,
            split = 'belowright',
          }
        end,
      },
      ['<C-y>'] = {
        desc = 'Copy relative path to clipboard',
        callback = function()
          local oil = require 'oil'
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          local cwd = vim.uv.cwd()
          if not entry or not dir or not cwd then
            return
          end
          local relPath = '.' .. dir:gsub(cwd, '') .. entry.name
          vim.notify('Copied path to clipboard\n' .. relPath, vim.log.levels.INFO)
          vim.fn.setreg(vim.v.register, relPath)
        end,
      },
      ['<C-q>'] = 'actions.send_to_qflist',
    },
  }
)

vim.keymap.set('n', '-', oil.open, { desc = 'Open parent directory' })

vim.keymap.set('n', '_', function()
oil.open(vim.uv.cwd())
end, { desc = 'Open CWD' })
