local editor = require 'code_review.ui.editor'
local export_markdown = require 'code_review.export.markdown'
local notes = require 'code_review.core.notes'
local session_store = require 'code_review.core.session'
local util = require 'code_review.util'

local M = {
  line_notes = {},
}

local function range_label(note)
  if note.start_line == note.end_line then
    return tostring(note.start_line)
  end
  return string.format('%s-%s', note.start_line, note.end_line)
end

local function get_note(session, id)
  for _, note in ipairs(session.notes or {}) do
    if note.id == id then
      return note
    end
  end
  return nil
end

local function note_under_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.fn.line '.'
  local note_id = M.line_notes[buf] and M.line_notes[buf][line]
  if not note_id then
    return nil
  end

  local session = session_store.require_current()
  return get_note(session, note_id)
end

local function jump_to_note()
  local note = note_under_cursor()
  if not note then
    return
  end

  local _, root = session_store.require_current()
  vim.cmd('edit ' .. vim.fn.fnameescape(util.joinpath(root, note.path)))
  vim.api.nvim_win_set_cursor(0, { note.start_line, 0 })
  vim.cmd 'normal! zz'
end

local function edit_note()
  local note = note_under_cursor()
  if not note then
    return
  end

  editor.open {
    name = 'Code Review Edit ' .. note.id,
    initial = note.body or '',
    message = 'Edit note and :wq to save',
    on_submit = function(body)
      notes.update(note.id, body)
      M.open()
    end,
  }
end

local function delete_note()
  local note = note_under_cursor()
  if not note then
    return
  end

  notes.delete(note.id)
  M.open()
end

local function toggle_resolved()
  local note = note_under_cursor()
  if not note then
    return
  end

  notes.set_status(note.id, note.status == 'resolved' and 'open' or 'resolved')
  M.open()
end

local function refresh_notes()
  local session, root = session_store.require_current()
  notes.remap(session, root)
  M.open()
end

local function copy_notes()
  local session = session_store.require_current()
  export_markdown.copy(session)
end

local function add_note_lines(lines, metadata, note)
  local start_line = #lines + 1
  table.insert(
    lines,
    string.format(
      '### [%s] %s:%s',
      note.status or 'open',
      note.path or '<unknown>',
      range_label(note)
    )
  )
  table.insert(lines, '')

  for _, line in ipairs(vim.split(note.body or '', '\n', { plain = true })) do
    table.insert(lines, line)
  end

  if note.anchor and note.anchor.lines and #note.anchor.lines > 0 then
    table.insert(lines, '')
    table.insert(lines, '```')
    vim.list_extend(lines, note.anchor.lines)
    table.insert(lines, '```')
  end

  table.insert(lines, '')

  for line = start_line, #lines do
    metadata[line] = note.id
  end
end

function M.open()
  local session = session_store.require_current()
  local buf_name = 'code-review://notes'
  local existing = nil

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):match(vim.pesc(buf_name) .. '$') then
      existing = buf
      break
    end
  end

  local buf
  if existing then
    buf = existing
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
      vim.cmd 'botright vnew'
      vim.api.nvim_win_set_buf(0, buf)
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    vim.cmd 'botright vnew'
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, buf_name)
  end

  vim.bo[buf].modifiable = true
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'markdown'
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = 'no'
  vim.wo.wrap = true

  local lines = {
    '# Code Review Notes',
    '',
    string.format('Session: `%s`', session.id),
    string.format('Mode: `%s`', session.mode),
    '',
  }

  local metadata = {}
  local rendered = vim.deepcopy(session.notes or {})
  util.sort_notes(rendered)

  if #rendered == 0 then
    table.insert(lines, '_No notes yet._')
    table.insert(lines, '')
  else
    for _, note in ipairs(rendered) do
      add_note_lines(lines, metadata, note)
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  M.line_notes[buf] = metadata

  local map_opts = { buffer = buf, silent = true }
  vim.keymap.set(
    'n',
    '<CR>',
    jump_to_note,
    vim.tbl_extend('force', map_opts, { desc = 'Jump to note' })
  )
  vim.keymap.set('n', 'e', edit_note, vim.tbl_extend('force', map_opts, { desc = 'Edit note' }))
  vim.keymap.set('n', 'd', delete_note, vim.tbl_extend('force', map_opts, { desc = 'Delete note' }))
  vim.keymap.set(
    'n',
    'r',
    toggle_resolved,
    vim.tbl_extend('force', map_opts, { desc = 'Resolve or reopen note' })
  )
  vim.keymap.set(
    'n',
    'R',
    refresh_notes,
    vim.tbl_extend('force', map_opts, { desc = 'Refresh note anchors' })
  )
  vim.keymap.set(
    'n',
    'y',
    copy_notes,
    vim.tbl_extend('force', map_opts, { desc = 'Copy unresolved notes' })
  )

  vim.bo[buf].modifiable = false
end

function M.set_note_under_cursor_status(status)
  local note = note_under_cursor()
  if note then
    notes.set_status(note.id, status)
    M.open()
    return note
  end
  return nil
end

return M
