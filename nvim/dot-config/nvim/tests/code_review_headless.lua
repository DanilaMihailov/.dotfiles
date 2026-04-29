local export_markdown = require 'code_review.export.markdown'
local notes = require 'code_review.core.notes'

local function assert_contains(haystack, needle)
  assert(
    haystack:find(needle, 1, true) ~= nil,
    string.format('expected output to contain %q\n%s', needle, haystack)
  )
end

local function assert_not_contains(haystack, needle)
  assert(
    haystack:find(needle, 1, true) == nil,
    string.format('expected output not to contain %q\n%s', needle, haystack)
  )
end

local rendered = export_markdown.render {
  branch = 'feature/review',
  mode = 'branch',
  base_ref = 'master',
  base_sha = 'abc123',
  notes = {
    {
      status = 'open',
      path = 'app.lua',
      start_line = 10,
      end_line = 11,
      body = 'Fix this branch.',
      anchor = { lines = { 'if value then', '  return value', 'end' } },
    },
    {
      status = 'resolved',
      path = 'done.lua',
      start_line = 1,
      end_line = 1,
      body = 'Already fixed.',
      anchor = { lines = { 'return true' } },
    },
    {
      status = 'stale',
      path = 'stale.lua',
      start_line = 3,
      end_line = 3,
      body = 'Check remap.',
      anchor = { lines = { 'old_line()' } },
    },
  },
}

assert_contains(rendered, 'app.lua:10-11')
assert_contains(rendered, 'Fix this branch.')
assert_contains(rendered, 'if value then')
assert_contains(rendered, 'stale.lua:3')
assert_not_contains(rendered, 'Already fixed.')
assert_not_contains(rendered, '# Code review notes')
assert_not_contains(rendered, '```')

local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
vim.fn.writefile({ 'one', 'two', 'target', 'line', 'three' }, vim.fs.joinpath(root, 'file.lua'))

local session = {
  notes = {
    {
      status = 'open',
      path = 'file.lua',
      start_line = 1,
      end_line = 2,
      anchor = { lines = { 'target', 'line' } },
    },
    {
      status = 'open',
      path = 'missing.lua',
      start_line = 1,
      end_line = 1,
      anchor = { lines = { 'gone' } },
    },
  },
}

notes.remap(session, root)

assert(session.notes[1].status == 'open', 'expected moved note to stay open')
assert(session.notes[1].start_line == 3, 'expected moved note to remap to line 3')
assert(session.notes[1].end_line == 4, 'expected moved note to remap to line 4')
assert(session.notes[2].status == 'stale', 'expected missing file note to become stale')
