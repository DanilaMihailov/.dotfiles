local config = require 'code_review.config'
local session_store = require 'code_review.core.session'
local util = require 'code_review.util'

local M = {}

local function note_range_from_opts(opts)
  if opts and opts.range and opts.range > 0 then
    return opts.line1, opts.line2
  end

  local line = vim.fn.line '.'
  return line, line
end

local function normalize_range(start_line, end_line)
  if start_line > end_line then
    return end_line, start_line
  end
  return start_line, end_line
end

local function buffer_path(root, buf)
  local path = vim.api.nvim_buf_get_name(buf or 0)
  if path == '' then
    error 'Current buffer has no file path'
  end
  return util.relpath(root, path)
end

local function capture_anchor(buf, start_line, end_line)
  local context = config.get().review.context_lines
  local last = vim.api.nvim_buf_line_count(buf)
  local before_start = math.max(1, start_line - context)
  local after_end = math.min(last, end_line + context)

  return {
    lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false),
    context_before = vim.api.nvim_buf_get_lines(buf, before_start - 1, start_line - 1, false),
    context_after = vim.api.nvim_buf_get_lines(buf, end_line, after_end, false),
  }
end

local function note_by_id(session, id)
  for _, note in ipairs(session.notes or {}) do
    if note.id == id then
      return note
    end
  end
  return nil
end

function M.add_from_buffer(buf, start_line, end_line, body)
  local session, root = session_store.require_current()
  start_line, end_line = normalize_range(start_line, end_line)
  body = util.trim(body)

  if body == '' then
    return nil
  end

  local now = util.now()
  local note = {
    id = util.new_id 'note',
    status = 'open',
    path = buffer_path(root, buf),
    start_line = start_line,
    end_line = end_line,
    body = body,
    created_at = now,
    updated_at = now,
    anchor = capture_anchor(buf, start_line, end_line),
    remote = {},
  }

  table.insert(session.notes, note)
  session.updated_at = now
  session_store.save()

  return note
end

function M.add_from_current_buffer(opts, body)
  local start_line, end_line = normalize_range(note_range_from_opts(opts))
  return M.add_from_buffer(0, start_line, end_line, body)
end

function M.update(note_id, body)
  local session = session_store.require_current()
  local note = note_by_id(session, note_id)
  if not note then
    return nil
  end

  note.body = util.trim(body)
  note.updated_at = util.now()
  session.updated_at = note.updated_at
  session_store.save()

  return note
end

function M.delete(note_id)
  local session = session_store.require_current()
  for index, note in ipairs(session.notes or {}) do
    if note.id == note_id then
      table.remove(session.notes, index)
      session.updated_at = util.now()
      session_store.save()
      return note
    end
  end
  return nil
end

function M.set_status(note_id, status)
  local session = session_store.require_current()
  local note = note_by_id(session, note_id)
  if not note then
    return nil
  end

  note.status = status
  note.updated_at = util.now()
  session.updated_at = note.updated_at
  session_store.save()

  return note
end

function M.find_at_current_line()
  local session, root = session_store.require_current()
  local path = buffer_path(root)
  local line = vim.fn.line '.'

  for _, note in ipairs(session.notes or {}) do
    if
      note.path == path
      and note.status ~= 'resolved'
      and line >= note.start_line
      and line <= note.end_line
    then
      return note
    end
  end

  return nil
end

local function sequence_matches(lines, start_index, needle)
  if #needle == 0 then
    return false
  end

  for offset, line in ipairs(needle) do
    if lines[start_index + offset - 1] ~= line then
      return false
    end
  end

  return true
end

local function find_sequence(lines, needle)
  if #needle == 0 or #needle > #lines then
    return nil
  end

  for index = 1, #lines - #needle + 1 do
    if sequence_matches(lines, index, needle) then
      return index
    end
  end

  return nil
end

function M.remap(session, root)
  local changed = false

  for _, note in ipairs(session.notes or {}) do
    if note.status ~= 'resolved' and note.anchor and note.anchor.lines then
      local path = util.joinpath(root, note.path)
      local lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or nil

      if not lines then
        note.status = 'stale'
        changed = true
      elseif sequence_matches(lines, note.start_line, note.anchor.lines) then
        if note.status == 'stale' then
          note.status = 'open'
          changed = true
        end
      else
        local new_start = find_sequence(lines, note.anchor.lines)
        if new_start then
          note.start_line = new_start
          note.end_line = new_start + #note.anchor.lines - 1
          note.status = 'open'
        else
          note.status = 'stale'
        end
        note.updated_at = util.now()
        changed = true
      end
    end
  end

  if changed then
    session.updated_at = util.now()
    session_store.save()
  end

  return changed
end

return M
