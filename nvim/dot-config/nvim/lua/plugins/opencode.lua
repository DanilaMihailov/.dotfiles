return {
  'sudo-tee/opencode.nvim',
  config = function()
    require('opencode').setup {
      default_mode = 'plan',
      ui = {
        input_height = 0.08,
      },
      keymap = {
        input_window = {
          ['<tab>'] = { 'switch_mode', mode = { 'n', 'i' } },
          ['<C-cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },
          ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },
          ['<C-n>'] = { 'next_prompt_history', mode = { 'n', 'i' } },
          ['<C-p>'] = { 'prev_prompt_history', mode = { 'n', 'i' } },
        },
      },
      debug = {
        show_ids = false,
      },
    }

    local util = require('opencode.util')
    ---@diagnostic disable-next-line: duplicate-set-field
    util.format_cost = function(c)
      return c and c > 0 and string.format('₽%.2f', c) or nil
    end
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
