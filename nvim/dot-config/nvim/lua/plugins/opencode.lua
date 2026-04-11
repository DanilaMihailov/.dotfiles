return {
  -- dir = '~/personal/opencode.nvim',
  'sudo-tee/opencode.nvim',
  config = function()
    require('opencode').setup {
      default_mode = 'plan',
      ui = {
        input_height = 0.08,
        cost_format = '%.2f₽',
        output = {
          tools = {
            show_output = true, -- Show tools output [diffs, cmd output, etc.] (default: true)
            show_reasoning_output = false, -- Show reasoning/thinking steps output (default: true)
          },
        },
      },
      keymap = {
        input_window = {
          ['<tab>'] = { 'switch_mode', mode = { 'n', 'i' } },
          ['<C-cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },
          ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },
          ['<C-n>'] = { 'next_prompt_history', mode = { 'n', 'i' } },
          ['<C-p>'] = { 'prev_prompt_history', mode = { 'n', 'i' } },
          ['<C-t>'] = { 'cycle_variant', mode = { 'n', 'i' } }, -- Cycle through model variants
          ['<C-x>l'] = { 'select_session', mode = { 'n', 'i' } }, -- Select and load a opencode session
          ['<C-x>m'] = { 'configure_provider', mode = { 'n', 'i' } }, -- Quick provider and model switch from predefined list
          ['<C-x>n'] = { 'open_input_new_session', mode = { 'n', 'i' } }, -- Opens and focuses on input window on insert mode. Creates a new session
        },
        output_window = {
          ['<C-t>'] = { 'cycle_variant', mode = { 'n', 'i' } }, -- Cycle through model variants
          ['<C-x>l'] = { 'select_session' }, -- Select and load a opencode session
          ['<C-x>m'] = { 'configure_provider' }, -- Quick provider and model switch from predefined list
          ['<C-x>n'] = { 'open_input_new_session' }, -- Opens and focuses on input window on insert mode. Creates a new session
        },
      },
      debug = {
        show_ids = false,
      },
      context = {
        diagnostics = {
          enabled = false,
        },
        current_file = {
          enabled = false,
        },
      },
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    -- Optional, for file mentions and commands completion, pick only one
    'saghen/blink.cmp',
    -- 'hrsh7th/nvim-cmp',

    -- Optional, for file mentions picker, pick only one
    -- 'folke/snacks.nvim',
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
    -- 'nvim_mini/mini.nvim',
  },
}
