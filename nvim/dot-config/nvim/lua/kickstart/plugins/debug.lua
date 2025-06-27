-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    {
      'mfussenegger/nvim-dap-python',
      config = function()
        require('dap-python').setup './.run-venv/bin/python'
        require('dap-python').test_runner = 'pytest'
      end,
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local wk = require 'which-key'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = false,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        -- "debugpy" ?
      },
    }

    -- table.insert(require('dap').configurations.python, {
    --   type = 'python',
    --   request = 'launch',
    --   name = 'Start all tests',
    --   program = '-m debugpy --listen 5678 --wait-for-client -m pytest -n 0',
    --   cwd = 'server',
    --   -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    -- })

    vim.keymap.set(
      'n',
      '<leader><leader>dt',
      require('dap-python').test_method,
      { desc = 'Test method' }
    )
    -- nnoremap <silent> <leader>dn :lua ()<CR>
    -- nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
    -- vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<leader><leader>dc', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<leader><leader>ds', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<leader><leader>dn', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<leader><leader>dS', dap.step_out, { desc = 'Debug: Step Out' })

    vim.keymap.set({ 'n', 'v' }, '<leader><leader>dh', function()
      require('dap.ui.widgets').hover()
    end, { desc = 'Hover' })
    vim.keymap.set({ 'n', 'v' }, '<leader><leader>dp', function()
      require('dap.ui.widgets').preview()
    end, { desc = 'Preview' })

    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define(
      'DapBreakpointCondition',
      { text = '', texthl = '', linehl = '', numhl = '' }
    )
    vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = '', numhl = '' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set(
      'n',
      '<leader><leader>dr',
      dapui.toggle,
      { desc = 'Debug: See last session result.' }
    )

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
