-- all git integrations live here (signs, status, diffview)
return {
  -- keeping for git blame
  { 'tpope/vim-fugitive', cmd = { 'Git' } },

  { -- better diff/merge tool
    'sindrets/diffview.nvim',
    ---@type DiffViewOptions
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    opts = {
      enhanced_diff_hl = true,
    },
    init = function()
      vim.opt.fillchars:append { diff = '╱' }
    end,
  },
  { -- git status, branch, commit, merge, etc
    'NeogitOrg/neogit',
    -- dir = '~/personal/nvim-plugins/neogit/',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim', -- optional
    },
    ---@type NeogitConfig
    opts = {
      disable_hint = true,
      git_services = {
        ['gitlab.clabs.net'] = 'https://gitlab.clabs.net/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}&merge_request[target_branch]=master',
      },
      disable_context_highlighting = true,
      graph_style = 'unicode',
      kind = 'split',
      -- disable_line_numbers = false,
      -- disable_relative_line_numbers = false,
      signs = {
        hunk = { '', '' },
        item = { '', '' },
        section = { '', '' },
      },
      commit_editor = {
        kind = 'split',
        show_staged_diff = false,
      },
      sections = {
        untracked = {
          folded = true,
        },
        unmerged_upstream = {
          folded = true,
        },
      },
      status = {
        HEAD_folded = true,
        show_head_commit_hash = false,
        mode_padding = 1,
        mode_text = {
          M = 'M',
          N = 'N',
          A = 'A',
          D = 'D',
          C = 'C',
          U = 'U',
          R = 'R',
          DD = 'DD',
          AU = 'AU',
          UD = 'UD',
          UA = 'UA',
          DU = 'DU',
          AA = 'AA',
          UU = 'UU',
          ['?'] = '?',
        },
      },
    },
    cmd = { 'Neogit', 'NeogitClose', 'G' },
    config = function(plug, opts)
      local neogit = require 'neogit'
      neogit.setup(opts)
      -- override fugitive command (use :Git for fugitive)
      vim.api.nvim_create_user_command('G', function()
        neogit.open()
      end, {})

      vim.api.nvim_create_user_command('NeogitClose', function()
        neogit.close()
      end, {})

      vim.cmd [[
        hi! link NeogitSectionHeader @attribute
        hi! link NeogitSectionHeaderCount @number
        hi! link NeogitTagDistance @number
        hi! link NeogitStatusHEAD @label
        hi! link NeogitChangeUntrackeduntracked @operator
        hi! link NeogitObjectId @string.special.symbol
        hi! link NeogitFilePath @string.special.path

        hi! link NeogitDiffAdd @diff.plus
        hi! link NeogitDiffAdditions @diff.plus
        hi! link NeogitDiffAddHighlight @diff.plus

        hi! link NeogitDiffDelete @diff.minus
        hi! link NeogitDiffDeletions @diff.minus
        hi! link NeogitDiffDeleteHighlight @diff.minus

        hi! link NeogitWinSeparator WinSeparator
      ]]
    end,
  },
  { -- gutters, hunks
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    ---@type Gitsigns.Config
    opts = {
      -- current_line_blame = true,
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

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
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
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
          { desc = '[T]oggle git show [b]lame line' }
        )
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
    init = function()
      vim.cmd [[hi! link GitSignsCurrentLineBlame @comment]]
    end,
  },
}
