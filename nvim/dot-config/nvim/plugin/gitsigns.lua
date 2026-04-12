vim.pack.add {
  {
    src = 'https://github.com/lewis6991/gitsigns.nvim',
    version = vim.version.range '2.x',
  },
}

local gitsigns = require 'gitsigns'

local function qf_unique_files()
  local qf_list = vim.fn.getqflist()
  local unique_list = {}
  local seen = {}

  for _, entry in ipairs(qf_list) do
    if not seen[entry.bufnr] then
      table.insert(unique_list, entry)
      seen[entry.bufnr] = true
    end
  end

  vim.fn.setqflist(unique_list, 'r')
end

---@type Gitsigns.Config
gitsigns.setup {
  signcolumn = false,
  numhl = true,
  -- current_line_blame = true,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    -- Toggles
    map(
      'n',
      '<leader>tb',
      gitsigns.toggle_current_line_blame,
      { desc = 'Toggle git show [b]lame line' }
    )
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = 'Toggle git show [D]eleted' })

    map('n', '<leader>hq', function()
      gitsigns.setqflist 'all'
    end, { desc = 'Quickfix list with all hunks' })

    vim.api.nvim_create_user_command('ReviewSimple', function()
      local base_branch = vim.fn.system 'git show-ref --verify --quiet refs/heads/main'
      base_branch = vim.v.shell_error == 0 and 'main' or 'master'

      -- Try merge-base --fork-point first (better for rebased branches), fall back to merge-base
      local mb = vim.fn.system {
        'git',
        'merge-base',
        '--fork-point',
        'HEAD',
        base_branch,
      }
      if not mb or mb == '' or vim.v.shell_error ~= 0 then
        mb = vim.fn.system { 'git', 'merge-base', 'HEAD', base_branch }
      end

      vim.notify('Reviewing against ' .. mb)

      gitsigns.change_base(vim.trim(mb), true)
      gitsigns.toggle_signs(true)
      gitsigns.setqflist('all', {}, function(err)
        if not err then
          qf_unique_files()
        end
      end)
      vim.opt.signcolumn = 'yes'
    end, { desc = 'Review against main' })

    vim.api.nvim_create_user_command('ReviewSimpleDone', function()
      gitsigns.change_base(nil, true)
      gitsigns.toggle_signs(false)
      vim.opt.signcolumn = 'number'
      vim.cmd 'cclose'
    end, { desc = 'Review against main' })

    vim.api.nvim_create_user_command('ReviewMR', function()
      require('gitlab_review').review_mr()
    end, { desc = 'Select and review a GitLab MR' })

    vim.api.nvim_create_user_command('GDraft', function(opts)
      require('gitlab_review').create_draft_note(opts.range > 0)
    end, { desc = 'Create a GitLab draft note', range = true })
  end,
}

vim.cmd [[hi! link GitSignsCurrentLineBlame @comment]]
