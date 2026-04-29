local util = require 'code_review.util'

local M = {}

local function range_label(note)
  if note.start_line == note.end_line then
    return tostring(note.start_line)
  end
  return string.format('%s-%s', note.start_line, note.end_line)
end

local function note_context(note)
  if not note.anchor or not note.anchor.lines or #note.anchor.lines == 0 then
    return nil
  end
  return table.concat(note.anchor.lines, '\n')
end

function M.render(session, opts)
  opts = opts or {}
  local include_resolved = opts.include_resolved == true
  local notes = {}

  for _, note in ipairs(session.notes or {}) do
    if include_resolved or note.status ~= 'resolved' then
      table.insert(notes, note)
    end
  end

  util.sort_notes(notes)

  local blocks = {}

  for _, note in ipairs(notes) do
    local block = {
      string.format('%s:%s', note.path, range_label(note)),
      util.trim(note.body or ''),
    }

    local context = note_context(note)
    if context then
      vim.list_extend(block, vim.split(context, '\n', { plain = true }))
    end

    table.insert(blocks, table.concat(block, '\n'))
  end

  return table.concat(blocks, '\n\n')
end

function M.copy(session, opts)
  local text = M.render(session, opts)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  util.notify 'Copied review notes to clipboard'
  return text
end

return M
