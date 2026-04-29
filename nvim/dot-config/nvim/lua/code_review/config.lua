local M = {}

local defaults = {
  storage = {
    backend = 'json_state',
  },
  review = {
    default_mode = 'worktree',
    base = 'auto_main_master',
    include_untracked = 'working_tree_only',
    context_lines = 2,
  },
  providers = {
    files = 'git',
    diff = 'gitsigns',
    clipboard = 'system',
  },
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
end

function M.get()
  return M.options
end

return M
