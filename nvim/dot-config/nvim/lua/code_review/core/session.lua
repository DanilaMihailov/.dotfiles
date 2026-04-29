local config = require 'code_review.config'
local storage = require 'code_review.core.storage'
local util = require 'code_review.util'

local M = {
  root = nil,
  state = nil,
}

local function current_branch(root)
  local result = util.run_git(root, { 'rev-parse', '--abbrev-ref', 'HEAD' })
  if result.ok then
    return util.trim(result.stdout)
  end
  return 'unknown'
end

local function rev_parse(root, ref)
  local result = util.run_git(root, { 'rev-parse', ref })
  if result.ok then
    return util.trim(result.stdout)
  end
  return nil
end

local function detect_base_branch(root)
  local preferred = config.get().review.base
  if preferred and preferred ~= 'auto_main_master' then
    return preferred
  end

  for _, branch in ipairs { 'main', 'master' } do
    local local_ref =
      util.run_git(root, { 'show-ref', '--verify', '--quiet', 'refs/heads/' .. branch })
    if local_ref.ok then
      return branch
    end

    local remote_ref =
      util.run_git(root, { 'show-ref', '--verify', '--quiet', 'refs/remotes/origin/' .. branch })
    if remote_ref.ok then
      return 'origin/' .. branch
    end
  end

  return 'master'
end

local function merge_base(root, base_ref)
  local fork_point = util.run_git(root, { 'merge-base', '--fork-point', base_ref, 'HEAD' })
  if fork_point.ok and util.trim(fork_point.stdout) ~= '' then
    return util.trim(fork_point.stdout)
  end

  local normal = util.run_git(root, { 'merge-base', base_ref, 'HEAD' })
  if normal.ok and util.trim(normal.stdout) ~= '' then
    return util.trim(normal.stdout)
  end

  return rev_parse(root, base_ref)
end

local function make_session_id(mode, branch, base_sha)
  if mode == 'worktree' then
    return 'worktree:' .. branch
  end
  return table.concat({ 'branch', branch, base_sha or 'unknown' }, ':')
end

local function find_session(state, id)
  for _, session in ipairs(state.sessions) do
    if session.id == id then
      return session
    end
  end
  return nil
end

function M.load(root)
  M.root = root or util.repo_root()
  M.state = storage.load(M.root)
  return M.state
end

function M.save()
  if M.root and M.state then
    storage.save(M.root, M.state)
  end
end

function M.start(mode)
  local root = util.repo_root()
  local state = M.load(root)
  mode = mode or config.get().review.default_mode
  if mode ~= 'branch' and mode ~= 'worktree' then
    error('Unknown code review mode: ' .. mode)
  end

  local branch = current_branch(root)
  local base_ref = nil
  local base_sha = nil
  if mode == 'branch' then
    base_ref = detect_base_branch(root)
    base_sha = merge_base(root, base_ref)
    if not base_sha then
      error('Could not determine review base for ' .. base_ref)
    end
  end

  local id = make_session_id(mode, branch, base_sha)
  local session = find_session(state, id)
  local now = util.now()

  if not session then
    session = {
      id = id,
      mode = mode,
      status = 'open',
      branch = branch,
      base_ref = base_ref,
      base_sha = base_sha,
      head_sha = rev_parse(root, 'HEAD'),
      created_at = now,
      updated_at = now,
      notes = {},
    }
    table.insert(state.sessions, session)
  else
    session.status = 'open'
    session.branch = branch
    session.base_ref = base_ref
    session.base_sha = base_sha
    session.head_sha = rev_parse(root, 'HEAD')
    session.updated_at = now
    session.notes = session.notes or {}
  end

  state.current_session_id = session.id
  M.save()

  return session, root
end

function M.current()
  local root = M.root or util.repo_root()
  local state = M.load(root)
  if not state.current_session_id then
    return nil, root
  end
  return find_session(state, state.current_session_id), root
end

function M.require_current()
  local session, root = M.current()
  if not session then
    error 'No active review session. Run :CodeReviewStart first.'
  end
  session.notes = session.notes or {}
  return session, root
end

function M.close_current()
  local session = M.require_current()
  session.status = 'closed'
  session.updated_at = util.now()
  M.state.current_session_id = nil
  M.save()
  return session
end

return M
