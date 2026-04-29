local util = require 'code_review.util'

local M = {}

local function storage_dir()
  return util.joinpath(vim.fn.stdpath 'state', 'code-review.nvim')
end

function M.path_for_repo(root)
  return util.joinpath(storage_dir(), util.hash(root) .. '.json')
end

function M.empty_state(root)
  return {
    version = 1,
    repo_root = root,
    current_session_id = nil,
    sessions = {},
  }
end

function M.load(root)
  local path = M.path_for_repo(root)
  local state = util.read_json(path) or M.empty_state(root)

  state.version = state.version or 1
  state.repo_root = state.repo_root or root
  state.sessions = state.sessions or {}

  return state
end

function M.save(root, state)
  state.version = state.version or 1
  state.repo_root = root
  util.write_json(M.path_for_repo(root), state)
end

return M
