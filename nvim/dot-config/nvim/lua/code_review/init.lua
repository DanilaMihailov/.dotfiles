local config = require 'code_review.config'
local editor = require 'code_review.ui.editor'
local export_markdown = require 'code_review.export.markdown'
local git_files = require 'code_review.providers.files.git'
local gitsigns_diff = require 'code_review.providers.diff.gitsigns'
local notes = require 'code_review.core.notes'
local notes_buffer = require 'code_review.ui.notes_buffer'
local quickfix = require 'code_review.ui.quickfix'
local session_store = require 'code_review.core.session'
local util = require 'code_review.util'

local M = {}

local function command_mode(opts)
  local mode = opts.args ~= '' and opts.args or config.get().review.default_mode
  if mode ~= 'branch' and mode ~= 'worktree' then
    error 'Expected review mode "branch" or "worktree"'
  end
  return mode
end

local function start_session(mode)
  local ok, session, root = pcall(function()
    return session_store.start(mode)
  end)
  if not ok then
    util.notify(session, vim.log.levels.ERROR)
    return nil
  end

  gitsigns_diff.apply(session)
  notes.remap(session, root)

  local files_ok, files_or_error = pcall(git_files.changed_files, session, root)
  if not files_ok then
    util.notify(files_or_error, vim.log.levels.ERROR)
    return nil
  end

  local count = quickfix.populate(files_or_error, root)
  util.notify(string.format('Review started: %s file%s', count, count == 1 and '' or 's'))

  return session
end

function M.start(opts)
  start_session(command_mode(opts or { args = '' }))
end

function M.annotate(opts)
  local ok, err = pcall(session_store.require_current)
  if not ok then
    local session = start_session(config.get().review.default_mode)
    if not session then
      return
    end
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local start_line = opts and opts.range and opts.range > 0 and opts.line1 or vim.fn.line '.'
  local end_line = opts and opts.range and opts.range > 0 and opts.line2 or start_line

  editor.open {
    name = 'Code Review Note',
    message = 'Write note and :wq to save',
    on_submit = function(body)
      local note_ok, note_or_error =
        pcall(notes.add_from_buffer, source_buf, start_line, end_line, body)
      if not note_ok then
        util.notify(note_or_error, vim.log.levels.ERROR)
        return
      end
      if note_or_error then
        util.notify('Added note for ' .. note_or_error.path .. ':' .. note_or_error.start_line)
      end
    end,
  }
end

function M.notes()
  local ok, err = pcall(notes_buffer.open)
  if not ok then
    util.notify(err, vim.log.levels.ERROR)
  end
end

function M.copy(opts)
  local ok, session_or_error = pcall(session_store.require_current)
  if not ok then
    util.notify(session_or_error, vim.log.levels.ERROR)
    return
  end

  export_markdown.copy(session_or_error, {
    include_resolved = opts and opts.bang == true,
  })
end

function M.resolve()
  local ok, note_or_error = pcall(notes_buffer.set_note_under_cursor_status, 'resolved')
  if ok and note_or_error then
    util.notify('Resolved note ' .. note_or_error.id)
    return
  end

  local line_ok, note = pcall(notes.find_at_current_line)
  if line_ok and note then
    notes.set_status(note.id, 'resolved')
    util.notify('Resolved note ' .. note.id)
    return
  end

  util.notify('No unresolved note under cursor', vim.log.levels.WARN)
end

function M.reopen()
  local ok, note_or_error = pcall(notes_buffer.set_note_under_cursor_status, 'open')
  if ok and note_or_error then
    util.notify('Reopened note ' .. note_or_error.id)
    return
  end

  util.notify('Open the notes buffer and place cursor on a resolved note', vim.log.levels.WARN)
end

function M.close()
  local ok, session_or_error = pcall(session_store.close_current)
  if not ok then
    util.notify(session_or_error, vim.log.levels.ERROR)
    return
  end

  vim.cmd 'cclose'
  util.notify('Closed review session ' .. session_or_error.id)
end

function M.reset_base()
  gitsigns_diff.reset()
  vim.cmd 'cclose'
end

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command('CodeReviewStart', M.start, {
    nargs = '?',
    complete = function()
      return { 'branch', 'worktree' }
    end,
    desc = 'Start local code review',
  })

  vim.api.nvim_create_user_command('CodeReviewAnnotate', M.annotate, {
    range = true,
    desc = 'Annotate current line or range',
  })

  vim.api.nvim_create_user_command('CodeReviewNotes', M.notes, {
    desc = 'Open review notes',
  })

  vim.api.nvim_create_user_command('CodeReviewCopy', M.copy, {
    bang = true,
    desc = 'Copy unresolved review notes',
  })

  vim.api.nvim_create_user_command('CodeReviewResolve', M.resolve, {
    desc = 'Resolve note under cursor',
  })

  vim.api.nvim_create_user_command('CodeReviewReopen', M.reopen, {
    desc = 'Reopen note under cursor in notes buffer',
  })

  vim.api.nvim_create_user_command('CodeReviewClose', M.close, {
    desc = 'Close current review session',
  })

  vim.api.nvim_create_user_command('CodeReviewResetBase', M.reset_base, {
    desc = 'Reset review diff base',
  })
end

return M
