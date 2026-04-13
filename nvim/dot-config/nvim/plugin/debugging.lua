vim.pack.add {
  -- nvim-dap MUST be on master, release tags are way out of date
  { src = 'https://codeberg.org/mfussenegger/nvim-dap', version = 'master' },
  { src = 'https://codeberg.org/mfussenegger/nvim-dap-python', version = 'master' },
  { src = 'https://github.com/igorlfs/nvim-dap-view', version = vim.version.range '1.x' },
}

local dap = require 'dap'
local dap_py = require 'dap-python'
local dap_view = require 'dap-view'

local function shorten_path(path)
  if not path or path == '' then
    return ''
  end
  local cwd = vim.fn.getcwd()
  if path:find(cwd, 1, true) == 1 then
    return path:sub(#cwd + 2)
  end
  return path
end

local function prepare_args(args)
  if not args then
    return ''
  end

  return vim.iter(args):map(shorten_path):totable()
end

dap.listeners.before.event_process['dap_notification'] = function()
  local session = dap.session()
  local cwd = session.config.cwd or vim.fn.getcwd()

  if session then
    local program = session.config.module or 'python'
    local args = table.concat(prepare_args(session.config.args or {}), ' ')
    local file = shorten_path(session.config.program)
    vim.notify(
      'Starting: ' .. program .. file .. ' ' .. args,
      vim.log.levels.INFO,
      { title = 'DAP' }
    )
  end
end

dap.listeners.after.event_exited['dap_notification'] = function(_, body)
  local session = dap.session()
  if session and body then
    local program = session.config.module or 'python'
    local exit_code = body.exitCode or 'N/A'
    vim.notify(
      'Program exited: ' .. program .. ' (exit code: ' .. exit_code .. ')',
      exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR,
      { title = 'DAP' }
    )
    if exit_code ~= 0 then
      require('dap-view').open()
    end
  end
end

dap.listeners.after.event_terminated['dap_notification'] = function(_, body)
  local session = dap.session()
  if session then
    local program = session.config.module or 'python'
    vim.notify('Debugging terminated: ' .. program, vim.log.levels.WARN, { title = 'DAP' })
  end
end

dap_py.setup 'uv'

dap_view.setup {
  winbar = {
    default_section = 'console',
    sections = {
      'watches',
      'scopes',
      'exceptions',
      'breakpoints',
      'threads',
      'repl',
      'console',
    },
    controls = {
      enabled = true,
    },
  },
}
-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<leader>dc', function()
  require('dap').continue()
end, { desc = 'Debug: Start/Continue' })

vim.keymap.set('n', '<leader>ds', function()
  require('dap').step_into()
end, { desc = 'Debug: Step Into' })

vim.keymap.set('n', '<leader>dn', function()
  require('dap').step_over()
end, { desc = 'Debug: Step Over' })

vim.keymap.set('n', '<leader>du', function()
  require('dap').step_out()
end, { desc = 'Debug: Step Out' })

vim.keymap.set('n', '<leader>db', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

vim.keymap.set('n', '<leader>dB', function()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Breakpoint' })

vim.keymap.set('n', '<leader>dh', function()
  require('dap.ui.widgets').hover()
end, { desc = 'Debug: Hover' })

vim.keymap.set('n', '<leader>dq', function()
  require('dap').terminate()
end, { desc = 'Debug: Terminate' })

vim.keymap.set('n', '<leader>dr', function()
  local dap = require 'dap'
  if dap.session() then
    dap.restart()
  else
    dap.run_last()
  end
end, { desc = 'Debug: Restart' })

vim.keymap.set('n', '<leader>dm', function()
  require('dap-python').test_method()
end, { desc = 'Debug: Test method' })

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set('n', '<leader>dt', function()
  require('dap-view').toggle()
end, { desc = 'Debug: See last session result.' })
