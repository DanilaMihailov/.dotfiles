vim.pack.add {
  'https://github.com/NeogitOrg/neogit',
}

local neogit = require 'neogit'

neogit.setup {
  disable_hint = true,
  git_services = {
    ['gitlab.clabs.net'] = {
      pull_request = 'https://gitlab.clabs.net/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}',
      commit = 'https://gitlab.clabs.net/${owner}/${repository}/-/commit/${oid}',
      tree = 'https://gitlab.clabs.net/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads',
    },
  },
  disable_context_highlighting = true,
  graph_style = 'unicode',
  kind = 'split',
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
}

vim.api.nvim_create_user_command('G', function()
  neogit.open()
end, {})

vim.cmd [[
hi! link NeogitSectionHeader @attribute
hi! link NeogitSectionHeaderCount @number
hi! link NeogitTagDistance @number
hi! link NeogitStatusHEAD @label
hi! link NeogitChangeUntrackeduntracked @operator
hi! link NeogitObjectId @string.special.symbol
hi! link NeogitFilePath @string.special.path

"hi! link NeogitDiffAdd @diff.plus
"hi! link NeogitDiffAdditions @diff.plus
"hi! link NeogitDiffAddHighlight @diff.plus

"hi! link NeogitDiffDelete @diff.minus
"hi! link NeogitDiffDeletions @diff.minus
"hi! link NeogitDiffDeleteHighlight @diff.minus

hi! link NeogitWinSeparator WinSeparator
]]
