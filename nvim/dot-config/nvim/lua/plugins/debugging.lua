return {
  -- { 'mfussenegger/nvim-dap', dependencies = { 'igorlfs/nvim-dap-view' } },
  {
    'igorlfs/nvim-dap-view',
    dependencies = {
      {
        'mfussenegger/nvim-dap',
        branch = 'master',
        config = function()
          local dap = require 'dap'

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
              vim.notify(
                'Debugging terminated: ' .. program,
                vim.log.levels.WARN,
                { title = 'DAP' }
              )
            end
          end
        end,
      },
      {
        'mfussenegger/nvim-dap-python',
        config = function()
          local dap_py = require 'dap-python'
          dap_py.setup 'uv'
        end,
      },
    },
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {
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
    },
    keys = {
      -- Basic debugging keymaps, feel free to change to your liking!
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Start/Continue',
      },
      {
        '<leader>ds',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<leader>dn',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<leader>du',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      {
        '<leader>dh',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'Debug: Hover',
      },
      {
        '<leader>dq',
        function()
          require('dap').terminate()
        end,
        desc = 'Debug: Terminate',
      },
      {
        '<leader>dr',
        function()
          local dap = require 'dap'
          if dap.session() then
            dap.restart()
          else
            dap.run_last()
          end
        end,
        desc = 'Debug: Restart',
      },
      {
        '<leader>dm',
        function()
          require('dap-python').test_method()
        end,
        desc = 'Debug: Test method',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      {
        '<leader>dt',
        function()
          require('dap-view').toggle()
        end,
        desc = 'Debug: See last session result.',
      },
    },
  },
}

-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

-- return {
--   -- NOTE: Yes, you can install new plugins here!
--   'mfussenegger/nvim-dap',
--   -- NOTE: And you can specify dependencies as well
--   dependencies = {
--     -- Creates a beautiful debugger UI
--     'rcarriga/nvim-dap-ui',
--
--     -- Required dependency for nvim-dap-ui
--     'nvim-neotest/nvim-nio',
--
--     -- Installs the debug adapters for you
--     'mason-org/mason.nvim',
--     'jay-babu/mason-nvim-dap.nvim',
--
--     -- Add your own debuggers here
--     'mfussenegger/nvim-dap-python',
--     -- 'leoluz/nvim-dap-go',
--   },
--   keys = {
--     -- Basic debugging keymaps, feel free to change to your liking!
--     {
--       '<leader>dc',
--       function()
--         require('dap').continue()
--       end,
--       desc = 'Debug: Start/Continue',
--     },
--     {
--       '<leader>ds',
--       function()
--         require('dap').step_into()
--       end,
--       desc = 'Debug: Step Into',
--     },
--     {
--       '<leader>dn',
--       function()
--         require('dap').step_over()
--       end,
--       desc = 'Debug: Step Over',
--     },
--     {
--       '<leader>du',
--       function()
--         require('dap').step_out()
--       end,
--       desc = 'Debug: Step Out',
--     },
--     {
--       '<leader>db',
--       function()
--         require('dap').toggle_breakpoint()
--       end,
--       desc = 'Debug: Toggle Breakpoint',
--     },
--     {
--       '<leader>dB',
--       function()
--         require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
--       end,
--       desc = 'Debug: Set Breakpoint',
--     },
--     -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
--     {
--       '<leader>dt',
--       function()
--         require('dapui').toggle()
--       end,
--       desc = 'Debug: See last session result.',
--     },
--   },
--   config = function()
--     local dap = require 'dap'
--     local dapui = require 'dapui'
--
--     require('mason-nvim-dap').setup {
--       -- Makes a best effort to setup the various debuggers with
--       -- reasonable debug configurations
--       automatic_installation = true,
--
--       -- You can provide additional configuration to the handlers,
--       -- see mason-nvim-dap README for more information
--       handlers = {},
--
--       -- You'll need to check that you have the required things installed
--       -- online, please don't ask me how to install them :)
--       ensure_installed = {
--         -- Update this to ensure that you have the debuggers for the langs you want
--         'delve',
--       },
--     }
--
--     -- Dap UI setup
--     -- For more information, see |:help nvim-dap-ui|
--     dapui.setup {
--       -- Set icons to characters that are more likely to work in every terminal.
--       --    Feel free to remove or use ones that you like more! :)
--       --    Don't feel like these are good choices.
--       icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
--       controls = {
--         icons = {
--           pause = '⏸',
--           play = '▶',
--           step_into = '⏎',
--           step_over = '⏭',
--           step_out = '⏮',
--           step_back = 'b',
--           run_last = '▶▶',
--           terminate = '⏹',
--           disconnect = '⏏',
--         },
--       },
--     }
--
--     -- Change breakpoint icons
--     -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
--     -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
--     -- local breakpoint_icons = vim.g.have_nerd_font
--     --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--     --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
--     -- for type, icon in pairs(breakpoint_icons) do
--     --   local tp = 'Dap' .. type
--     --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--     --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
--     -- end
--
--     dap.listeners.after.event_initialized['dapui_config'] = dapui.open
--     dap.listeners.before.event_terminated['dapui_config'] = dapui.close
--     dap.listeners.before.event_exited['dapui_config'] = dapui.close
--
--     local dap_python = require 'dap-python'
--
--     dap_python.setup 'uv'
--     dap_python.test_runner = 'pytest'
--
--     -- Install golang specific config
--     -- require('dap-go').setup {
--     --   delve = {
--     --     -- On Windows delve must be run attached or it crashes.
--     --     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
--     --     detached = vim.fn.has 'win32' == 0,
--     --   },
--     -- }
--   end,
-- }
