local config = require 'code_review.config'
local util = require 'code_review.util'

local M = {}

local function parse_name_status(output)
  local files = {}

  for line in output:gmatch '[^\r\n]+' do
    local parts = vim.split(line, '\t', { plain = true })
    local status = parts[1]

    if status and status ~= '' then
      local entry = {
        status = status:sub(1, 1),
        path = parts[2],
        old_path = nil,
      }

      if entry.status == 'R' or entry.status == 'C' then
        entry.old_path = parts[2]
        entry.path = parts[3]
      end

      if entry.path and entry.path ~= '' then
        table.insert(files, entry)
      end
    end
  end

  return files
end

local function add_untracked(root, files, seen)
  local result = util.run_git(root, { 'ls-files', '--others', '--exclude-standard' })
  if not result.ok then
    return
  end

  for path in result.stdout:gmatch '[^\r\n]+' do
    if path ~= '' and not seen[path] then
      table.insert(files, { status = 'A', path = path, old_path = nil, untracked = true })
      seen[path] = true
    end
  end
end

function M.changed_files(session, root)
  local args
  if session.mode == 'branch' then
    args = { 'diff', '--name-status', '--find-renames', session.base_sha, '--' }
  else
    args = { 'diff', '--name-status', '--find-renames', 'HEAD', '--' }
  end

  local result = util.run_git(root, args)
  if not result.ok then
    error(util.trim(result.stderr) ~= '' and util.trim(result.stderr) or 'git diff failed')
  end

  local files = parse_name_status(result.stdout)
  local seen = {}
  for _, file in ipairs(files) do
    seen[file.path] = true
  end

  if
    session.mode == 'worktree' and config.get().review.include_untracked == 'working_tree_only'
  then
    add_untracked(root, files, seen)
  end

  table.sort(files, function(a, b)
    return a.path < b.path
  end)

  return files
end

return M
